set box_xy 10
set box_z 10
setmd box_l $box_xy $box_xy $box_z
setmd time_step 0.001;
setmd skin 0.4;
setmd periodic 1 1 1
thermostat off
set ni 50
for {set i 0} { $i < $ni  } {incr i} {
    set posx [expr $box_xy*[t_random]]
    set posy [expr $box_xy*[t_random]]
    set posz [expr 5]
    part $i pos $posx $posy $posz q 1 type 0
}
for {set j $i} { $j < [expr 2*$ni] } {incr j} {
    set posx [expr $box_xy*[t_random]]
    set posy [expr $box_xy*[t_random]]
    set posz [expr 5]
    part $j pos $posx $posy $posz q -1 type 1
}


set path_meshL "/auto.anoa/home/konrad/Documents/Tcl-Scripts/constraint_mesh/left_electrode.stl"
set path_meshR "/auto.anoa/home/konrad/Documents/Tcl-Scripts/constraint_mesh/right_electrode.stl"

constraint mesh type 2 file $path_meshL offset 0 0 0 bins 100 100 100
constraint mesh type 2 file $path_meshR offset 0 0 0 bins 100 100 100

inter 0 2 lennard-jones 10.0 1.0 4 auto
inter 1 2 lennard-jones 10.0 1.0 4 auto
#inter 0 1 lennard-jones 10.0 1.0 4 auto
#inter 0 1 lennard-jones 10.0 1.0 4 auto

prepare_vmd_connection "vmd" 30000 1 1

thermostat langevin 1.0 1.0

while {1==1} {
	integrate 1
	imd positions
#puts [part 0 print pos]
}

