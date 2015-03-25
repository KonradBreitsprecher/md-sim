

set global_sigma 0.336

set channel_width 10.
set pore_length 12.09
set pore_width 0.66
set upper_smoothing_radius 1.5
set lower_smoothing_radius 0.5
set pore_sidewidth 3.24
set pore_mouth [expr $pore_length+$global_sigma]

set gap [expr $channel_width*0.0]

set box_l_x [expr $pore_width + 2.*$pore_sidewidth]
set box_l_y $box_l_x
set box_l_z [expr $pore_length + $channel_width + $gap]

puts "Box: $box_l_x $box_l_y $box_l_z"

#setmd box_l $box_l_x $box_l_y $box_l_z
setmd box_l 7.212121212 7.14 23.13131313131
setmd time_step 0.005 
setmd skin 0.5
thermostat langevin 1 1 

part 0 pos [expr 0.5*$box_l_x] [expr 0.5*$box_l_y] [expr 0] q 1 fix 1 1 1 type 0
part 1 pos 0 0 0 q -1 fix 1 1 1 type 0

#puts "Tune P3M"
#puts [ inter coulomb 1 p3m tunev2 mesh 4 accuracy 1e-2 ]

#set vmd_output "yes"
#if { $vmd_output == "yes" } {
#  prepare_vmd_connection "test" 10000 
#  after 1000
#  imd positions
#}

puts "Load External Potential"
external_potential tabulated file "mesh.dat" scale [list 1]


for { set i 0 } { $i < 1000 } { incr i } {
  set z [expr $box_l_z*$i/1000]
  part 0 pos [expr 0.5*$box_l_x] [expr 0.5*$box_l_y] $z
  integrate 1
  imd positions
  puts "z: $z   F: [part 0 print f]"
}

 




