import sys

def modify_beta_column(pdb_file, res1, res2, output_pdb):
    """
    Modify the beta column in the PDB file for two residues and save to a new PDB file.
    """
    with open(pdb_file, 'r') as f_in, open(output_pdb, 'w') as f_out:
        for line in f_in:
            if line.startswith(('ATOM', 'HETATM')):
                res_num = int(line[22:26].strip())
                if res_num == res1:
                    new_line = line[:60] + '  1.00' + line[66:]
                elif res_num == res2:
                    new_line = line[:60] + '  2.00' + line[66:]
                else:
                    new_line = line
                f_out.write(new_line)
            else:
                f_out.write(line)

def generate_namd_config(res1, res2, dcd_file):
    """
    Generate a NAMD configuration script based on the provided PDB and parameters.
    """
    namd_script = f"""
structure ./dry.psf
paraTypeCharmm on
parameters ./par_all36m_prot.prm
numsteps 1
switching off
exclude scaled1-4
outputname {res1}_{res2}-temp
temperature 0
COMmotion yes
cutoff 12
dielectric 1
switchdist 10.0
pairInteraction on
pairInteractionGroup1 1
pairInteractionFile ./{res1}_{res2}-temp.pdb
pairInteractionGroup2 2
coordinates ./{res1}_{res2}-temp.pdb
set ts 0
coorfile open dcd ./{dcd_file}
while {{ ![coorfile read] }} {{
    firstTimeStep $ts
    run 0
    incr ts 1
}}
coorfile close
"""
    # Save the NAMD script to a file
    namd_filename = f"{res1}_{res2}-temp.namd"
    with open(namd_filename, 'w') as f:
        f.write(namd_script)

    print(f"NAMD configuration saved to {namd_filename}")

if __name__ == "__main__":
    # Define the input PDB file, DCD file, residues, and output file name
    pdb_file = sys.argv[1]
    dcd_file = sys.argv[2]
    res1 = int(sys.argv[3])
    res2 = int(sys.argv[4])

    output_file = f'{res1}_{res2}-temp.pdb'

    # Call the function to modify the beta column and write the new file
    modify_beta_column(pdb_file, res1, res2, output_file)

    # Generate the NAMD configuration file
    generate_namd_config(res1, res2, dcd_file)

    print(f"File '{output_file}' created with beta values updated for residues {res1} and {res2}.")
    
