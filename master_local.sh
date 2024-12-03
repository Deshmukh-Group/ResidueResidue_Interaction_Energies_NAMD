#!/bin/bash
# ========================================================================================
# Script to calculate the residue-residue interaction energies for a protein using NAMD
# Created by: Swarnadeep Seth
# Last modified: 2024-09-27
# ========================================================================================
# Usage: bash master.sh
# ========================================================================================

# Create a folder to store output data
output_dir="residue_pair_data"
mkdir -p "$output_dir"

# Calculate the residue pairs that are within 20 angstroms of each other
#python3 calc_interact_res_pairs.py dry.psf dry_stride_5.dcd 20 0.6

# Loop through residue pairs from residue_pairs.dat
while IFS=',' read -r res1 res2; do
    if [[ "$res1" != "Residue1" ]]; then  # Skip the header line
        echo "Processing residue pair: $res1 and $res2"

        # Create a subfolder for the current residue pair
        pair_dir="${output_dir}/pair_${res1}_${res2}"
        mkdir -p "$pair_dir"

        # Prep the NAMD run files for the current residue pair
        python3 prep_namd_run.py dry.pdb dry_stride_5.dcd $res1 $res2

        # Run NAMD and save log in the pair-specific directory
        ~/Softwares/NAMD_2.14_Linux-x86_64-multicore/namd2 "${res1}_${res2}-temp.namd" > "${pair_dir}/${res1}_${res2}_energies.log"

        # Extract the energies from the log file
        grep -E "^ENERGY:|^PAIR INTERACTION:" "${pair_dir}/${res1}_${res2}_energies.log" | awk '
        /^ENERGY:/ {
            timestep=$2; elect=$7; vdw=$8; total=$12;
            printf "%s,%s,%s,%s\n", timestep, vdw, elect, total;
        }' > "${pair_dir}/${res1}_${res2}_energy_steps.csv"

        # Calculate the average energies and append to the final file
        awk -F, '  
        BEGIN {     
            sum_vdw = 0; sum_elect = 0; sum_total = 0; n = 0;
        }
        {           # For each line in the file
            sum_vdw += $2; sum_elect += $3; sum_total += $4; n++;
        }
        END {       
            printf "%s,%s,%.4f,%.4f,%.4f\n", '"$res1"', '"$res2"', sum_vdw/n, sum_elect/n, sum_total/n;
        }' "${pair_dir}/${res1}_${res2}_energy_steps.csv" >> "${output_dir}/res_res_energy.dat"
    fi
done < residue_pairs.dat
