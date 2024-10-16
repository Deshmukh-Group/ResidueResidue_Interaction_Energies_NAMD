import sys
import MDAnalysis as mda
import numpy as np
from scipy.spatial.distance import cdist

# Take arguments from the command line
topology_path = sys.argv[1]
trajectory_path = sys.argv[2]
cutoff = float(sys.argv[3])
percentage_cutoff = float(sys.argv[4])

print(f"Topology file: {topology_path}")
print(f"Trajectory file: {trajectory_path}")
print(f"Cutoff distance: {cutoff} Å")
print(f"Percentage cutoff: {percentage_cutoff}")

# Load the PSF and DCD files
u = mda.Universe(topology_path, trajectory_path)

# Set to store counts of residue pairs across frames
pair_counts = {}
pair_distances = {}
total_frames = len(u.trajectory)

# Iterate through each frame in the trajectory
for ts in u.trajectory:
    # Get all residues in the system
    residues = u.residues

    # Calculate the center of mass (COM) of each residue
    com = np.array([residue.atoms.center_of_mass() for residue in residues])

    # Calculate the pairwise distance matrix between residues
    dist_matrix = cdist(com, com)

    # Identify residue pairs that are within cutoff (excluding self-pairs)
    close_pairs = np.argwhere((dist_matrix < cutoff) & (dist_matrix > 0))

    # Count the occurrence of each unique pair and store distances
    for pair in close_pairs:
        res1, res2 = pair
        res1_id = residues[res1].resid
        res2_id = residues[res2].resid

        # Sort the pair to avoid duplicates like (A, B) and (B, A)
        sorted_pair = tuple(sorted((res1_id, res2_id)))
        distance = dist_matrix[res1, res2]

        # Increment pair count
        if sorted_pair in pair_counts:
            pair_counts[sorted_pair] += 1
        else:
            pair_counts[sorted_pair] = 1

        # Store distances
        if sorted_pair not in pair_distances:
            pair_distances[sorted_pair] = []
        pair_distances[sorted_pair].append(distance)

# Determine the threshold for the minimum number of frames a pair must appear in
min_frames = percentage_cutoff * total_frames / 100

# Create a set for unique residue pairs meeting the criteria
unique_pairs_global = {pair for pair, count in pair_counts.items() if count >= min_frames}

# Write the unique residue pairs to a file after processing all frames
with open('residue_pairs.dat', 'w') as f:
    f.write("Residue1,Residue2\n")  # Header
    for res1, res2 in sorted(unique_pairs_global):
        f.write(f"{res1},{res2}\n")

print(f"Unique residue pairs saved to residue_pairs.dat")

# Write residue pairs with average and std distances to another file
with open('residue_pairs_distances.csv', 'w') as f_dist:
    f_dist.write("Residue1,Residue2,Average_Distance,Std_Deviation\n")  # Header
    for pair in sorted(unique_pairs_global):
        res1, res2 = pair
        distances = pair_distances[pair]
        avg_distance = np.mean(distances)
        std_distance = np.std(distances)
        f_dist.write(f"{res1},{res2},{avg_distance:.4f},{std_distance:.3f}\n")

print(f"Residue pairs with average distances and std deviations saved to residue_pairs_distances.csv")
