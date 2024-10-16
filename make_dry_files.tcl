mol load psf ../../Run/NAMD_input.psf pdb ../../Run/NAMD_input.pdb

set a [atomselect top "not protein"]
set l [lsort -unique [$a get segid]]

package require psfgen
readpsf ../../Run/NAMD_input.psf
coordpdb  ../../Run/NAMD_input.pdb

foreach s $l {
delatom $s
}

writepsf dry.psf
writepdb dry.pdb