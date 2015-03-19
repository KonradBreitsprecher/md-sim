
set box_l_x 4
set box_l_y 4
set box_l_z 4

puts "Box: $box_l_x $box_l_y $box_l_z"

setmd box_l $box_l_x $box_l_y $box_l_z
setmd time_step 0.005 
setmd skin 2
thermostat off

part 0 pos [expr 0.5*$box_l_x] [expr 0.5*$box_l_y] [expr 0] q 1 fix 1 1 1 type 0
part 1 pos 0 0 0 q -1 fix 1 1 1 type 0

puts "Load External Potential"
external_potential tabulated file "simpleLattice.dat" scale [list 1]


for { set i 0 } { $i < 1000 } { incr i } {
  set z [expr $box_l_z*$i/1000]
  part 0 pos [expr 0.5*$box_l_x] [expr 0.5*$box_l_y] $z
  integrate 1
  imd positions
  puts "z: $z   F: [part 0 print f]"
}

 




