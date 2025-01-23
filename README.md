# ResidueResidue_Interaction_Energies_NAMD

This repository provides a pipeline for identifying and analyzing residue-residue interactions in molecular dynamics (MD) trajectories. The workflow includes distance-based residue pair selection, computation of average interaction distances, and subsequent energy calculations using NAMD.

---

## Features
1. **Residue Pair Identification**: Detects residue pairs based on a distance cutoff across trajectory frames.
2. **Interaction Statistics**: Calculates the average distance and standard deviation for residue pairs meeting criteria.
3. **Parallel Energy Calculation**: Efficiently calculates interaction energies for residue pairs using NAMD in a parallelized manner.
4. **Customizable Parameters**: Adjustable distance cutoff and frame percentage thresholds for filtering residue pairs.

---

## Prerequisites

### Software Requirements
- **Python 3.8+** with the following libraries:
  - [MDAnalysis](https://www.mdanalysis.org/)
  - NumPy
  - SciPy
- **NAMD**: For residue pair energy calculations.
- **GNU Parallel**: To run energy calculations in parallel.
- **SLURM**: For submitting jobs on HPC clusters.

### Environment Setup
1. Create and activate a `conda` virtual environment:
   ```bash
   conda create -n residue_analysis python=3.8 mdanalysis numpy scipy -y
   conda activate residue_analysis

### Input Files
**Topology File:** Protein structure file without waters and ions (e.g., dry.psf).
**Trajectory File:** Molecular dynamics trajectory file without waters and ions (e.g., dry.dcd).
**Parameter File:** CHARMM parameter file (e.g., par_all36m_prot.prm).

### Usage
  1. Residue Pair Detection
  - Run the Python script to identify residue pairs within a specified distance cutoff:
  - python3 calc_interact_res_pairs.py <topology.psf> <trajectory.dcd> <cutoff_distance> <percentage_cutoff>
  - Example: python3 calc_interact_res_pairs.py dry.psf dry.dcd 20 60
  
  Arguments:
  - <topology.psf>: Path to the topology file.
  - <trajectory.dcd>: Path to the trajectory file.
  - <cutoff_distance>: Distance cutoff in Ångstroms.
  - <percentage_cutoff>: Minimum percentage of trajectory frames a residue pair must meet the cutoff.
  
  Outputs:
  residue_pairs.dat: List of residue pairs meeting criteria.
  residue_pairs_distances.csv: Residue pairs with average distances and standard deviations.
  
  2. Energy Calculation with NAMD
  - Use the provided SLURM script to calculate interaction energies for residue pairs in parallel:
  - sbatch energy_calculation.sh

### Script Details:
Splits residue_pairs.dat into groups for parallel processing.

For each residue pair:
Prepares NAMD input files.
Runs NAMD to compute interaction energies.
Aggregates energy statistics into res_res_energy.dat.

Output Files
- residue_pairs.dat: Contains residue pairs identified within the cutoff.
- residue_pairs_distances.csv: Average distances and standard deviations for residue pairs.
- res_res_energy.dat: Summary of interaction energies:
Columns: Residue1, Residue2, Average_VDW, Average_Electrostatics, Average_Total_Energy.
Group-Specific Logs:
- Per-residue pair interaction energy steps (*_energy_steps.csv).
  
### SLURM Script Configuration
Before submitting the SLURM script, update the following:

 - Partition: Replace normal_q with your cluster's partition name.
 - Account: Replace swarnadeep with your HPC account name.
 - Number of Tasks: Ensure --ntasks matches the number of CPU cores available.

###  License
This repository is licensed under the MIT License. See LICENSE for details.

###  Contributions
Contributions are welcome! Please open an issue or submit a pull request for feature enhancements or bug fixes.
