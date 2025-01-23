# ResidueResidue_Interaction_Energies_NAMD

# Residue Pair Interaction Analysis Pipeline

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
