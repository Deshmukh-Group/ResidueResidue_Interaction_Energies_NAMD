#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=90
#SBATCH --partition=normal_q
#SBATCH -A swarnadeep
#SBATCH -t 24:00:00

# Remove any existing files
rm -r group_residue_pairs_group_*
rm residue_pairs_group_*
rm slurm-*
rm res_res_energy.dat

# Define paths and files
pairs_file="residue_pairs.dat"  # File with residue pairs

# Load required modules (if necessary)
module load Anaconda3
source activate docking

# Calculate the residue pairs that are within 20 angstroms of each other
# python3 calc_interact_res_pairs.py dry.psf dry.dcd 20 0.6

# Define the number of groups to split the residue pairs into (same as number of cores: ntasks)
num_groups=$SLURM_NTASKS

# Split residue pairs into groups
split -l $(($(wc -l < "$pairs_file") / num_groups + 1)) "$pairs_file" residue_pairs_group_

# Function to run NAMD for a given group of residue pairs
run_namd_group() {
  group_file=$1
  group_name=$(basename "$group_file")

  mkdir -p "group_$group_name"
  cd "group_$group_name"

  # Loop through each residue pair in the group and process
  while IFS=',' read -r res1 res2; do
      if [[ "$res1" != "Residue1" ]]; then  # Skip the header
          echo "Processing residue pair: $res1 and $res2"

          # Copy the prep_namd_run.py, $pdb_file. $psf_file, and $dcd_file to the current directory
          cp ../prep_namd_run.py .
          cp ../dry.pdb .
          cp ../dry.dcd .
          cp ../dry.psf .
          cp ../par_all36m_prot.prm .

          # Prep NAMD run files for the current residue pair
          python3 prep_namd_run.py dry.pdb dry.dcd $res1 $res2

          # Run NAMD for the current residue pair
          ~/Softwares/NAMD_2.14_Linux-x86_64-multicore/namd2 +p1 "${res1}_${res2}-temp.namd" > "${res1}_${res2}_energies.log"

          # Extract and process the energies
          grep -E "^ENERGY:|^PAIR INTERACTION:" "${res1}_${res2}_energies.log" | awk '
          /^ENERGY:/ {
              timestep=$2; elect=$7; vdw=$8; total=$12;
              printf "%s,%s,%s,%s\n", timestep, vdw, elect, total;
          }' > "${res1}_${res2}_energy_steps.csv"

          # Calculate average energies and append to summary file
          awk -F, '  
          BEGIN {     
              sum_vdw = 0; sum_elect = 0; sum_total = 0; n = 0;
          }
          {           # For each line in the file
              sum_vdw += $2; sum_elect += $3; sum_total += $4; n++;
          }
          END {       
              printf "%s,%s,%.4f,%.4f,%.4f\n", '"$res1"', '"$res2"', sum_vdw/n, sum_elect/n, sum_total/n;
          }' "${res1}_${res2}_energy_steps.csv" >> ../res_res_energy.dat
      fi
  done < "../$group_file"

  cd ..
}

# Export function for parallel use
export -f run_namd_group

# Run each group of residue pairs in parallel across cores
parallel -j $SLURM_NTASKS run_namd_group ::: residue_pairs_group_*

exit;