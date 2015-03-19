
set outputPath "testOutput/"
file mkdir $outputPath

# A few MD parameters

# Set tcl variable first:
set time_step 0.005
# Then tell Espresso, that this is the time step:
setmd time_step $time_step

# The skin is an a parameter of the verlet list algorithm
set skin 0.5
setmd skin $skin 

# We use the langevin equation with temperature 1 and friction 1:
set temperature 0.1
set gamma 1
thermostat langevin $temperature $gamma


## Lets set up the geometry that we want at the end
## Unit of length is nanometer

#These are the sizes we want at the end (including the repulsive distance due to wall/ion repulsion
set global_sigma 0.33

set channel_width [expr 10.]
set pore_length 12.09
set pore_width 0.66
set upper_smoothing_radius 1.5
set lower_smoothing_radius 0.5
set pore_sidewidth 3.24
#set pore_mouth [expr $pore_length+$global_sigma]
set pore_mouth [expr $pore_length]

set gap [expr $channel_width*0.0]

set box_l_x [expr $pore_width + 2.*$pore_sidewidth]
set box_l_y $box_l_x
set box_l_z [expr $pore_length + $channel_width + $gap]

setmd box_l $box_l_x $box_l_y $box_l_z
puts "Box: $box_l_x $box_l_y $box_l_z"

set volume [expr $box_l_y*$box_l_x*$channel_width + $pore_length*$box_l_y*$pore_width]

set volume_fraction 0.05

## How many ions?
#set n_ion_pairs [ expr int(floor($density*$volume)) ]
set n_ion_pairs [ expr int(floor(3.*$volume*$volume_fraction/([PI]*$global_sigma**3))) ]

puts "simulating $n_ion_pairs ion pairs"
## ion size
set plus_ion_radius [expr $global_sigma*0.5]
set minus_ion_radius [expr $global_sigma*0.5]
#Bjerrum length in vacuum
set l_B 5.6 

#ICC type: 0 by default
set plus_ion_type 1
set minus_ion_type 2
set wall_type 3

set lj_epsilon 1.
#set WCA_factor 1.12246
set WCA_factor 1.

# The LJ sigma between ions and wall
set wall_sigma $global_sigma

set q_c 1.0
set q_a -1.0

set voltage 20.
set scale [list 0 [ expr $voltage * $q_c ] [ expr $voltage * $q_a ]]


# create the wall
#constraint slitpore pore_mouth [ expr $pore_mouth - $wall_sigma ] \
#           	    channel_width [ expr $channel_width+2*$wall_sigma] \
#	            pore_width [ expr $pore_width + 2*$wall_sigma] \
#         	    pore_length [ expr $pore_length + 0*$wall_sigma ] \
#	            upper_smoothing_radius [ expr $upper_smoothing_radius -$wall_sigma ] \
#	            lower_smoothing_radius [ expr $lower_smoothing_radius + $wall_sigma ] \
#	            type $wall_type

constraint slitpore pore_mouth [ expr $pore_mouth] \
           	    channel_width [ expr $channel_width] \
	            pore_width [ expr $pore_width] \
         	    pore_length [ expr $pore_length] \
	            upper_smoothing_radius [ expr $upper_smoothing_radius] \
	            lower_smoothing_radius [ expr $lower_smoothing_radius] \
	            type $wall_type



# ion-ion interaction
inter $plus_ion_type $plus_ion_type lennard-jones $lj_epsilon [ expr $plus_ion_radius + $plus_ion_radius ] [ expr $WCA_factor * ( $plus_ion_radius + $plus_ion_radius) ] 
inter $minus_ion_type $minus_ion_type lennard-jones $lj_epsilon [ expr $minus_ion_radius + $minus_ion_radius ] [ expr $WCA_factor * ( $minus_ion_radius + $minus_ion_radius) ] 
inter $minus_ion_type $plus_ion_type lennard-jones $lj_epsilon [ expr $minus_ion_radius + $plus_ion_radius ] [ expr $WCA_factor * ( $minus_ion_radius + $plus_ion_radius) ] 
## ion wall interaction
inter $plus_ion_type $wall_type lennard-jones $lj_epsilon $wall_sigma [ expr $WCA_factor*$wall_sigma ]
inter $minus_ion_type $wall_type lennard-jones $lj_epsilon $wall_sigma [ expr $WCA_factor*$wall_sigma ]

# Lets put the ions in
# plus ions will be numbered 0 .. n_ion_pairs-1 and minus ions n_ion_pairs .. 2*n_ion_pairs-1
set partcounter 0
for { set  i 0 } { $i < $n_ion_pairs } { incr i } {
  set ok 0 
  while { !$ok } {
    set x [ expr [ t_random ] * $box_l_x ]
    set y [ expr [ t_random ] * $box_l_y ]
    set z [ expr [ t_random ] * $box_l_z ]
  
    if { [ constraint mindist_position $x $y $z ] > 1.1*$wall_sigma } { 
      set ok 1
    }
  }
  part $partcounter pos $x $y $z type $plus_ion_type q $q_c
  incr partcounter
}

for { set  i 0 } { $i < $n_ion_pairs } { incr i } {
  set ok 0 
  while { !$ok } {
    set x [ expr [ t_random ] * $box_l_x ]
    set y [ expr [ t_random ] * $box_l_y ]
    set z [ expr [ t_random ] * $box_l_z ]
  
    if { [ constraint mindist_position $x $y $z ] > 1.1*$wall_sigma } { 
      set ok 1
    }
  }
  part $partcounter pos $x $y $z type $minus_ion_type q $q_a
  incr partcounter
}

inter forcecap individual

# Now we increase the sigma of all lennard-jones interactions until they
# are blown to full size:
set initialsigma [ analyze mindist ]
if { $plus_ion_radius > $minus_ion_radius } {
    set maxsigma [ expr 2*$plus_ion_radius ] 
} else {
    set maxsigma [ expr 2*$minus_ion_radius ] 
}
set currentsigma $initialsigma 
# We have to scale the time_step, too
set currenttime_step [ expr $time_step *$currentsigma / $maxsigma ]
while { $currentsigma < $maxsigma } {
    puts "Next warmup round with $currentsigma"
    setmd time_step $currenttime_step
    
    if { $currentsigma < 2*$plus_ion_radius } {
        inter $plus_ion_type $plus_ion_type lennard-jones $lj_epsilon $currentsigma [ expr $WCA_factor * ( $plus_ion_radius + $plus_ion_radius) ] 0.25 
    }
    if { $currentsigma < $plus_ion_radius + $minus_ion_radius} {
        inter $plus_ion_type $minus_ion_type lennard-jones $lj_epsilon $currentsigma [ expr $WCA_factor * ( $plus_ion_radius + $minus_ion_radius) ] 0.25 
    }
    if { $currentsigma < 2*$minus_ion_radius } {
        inter $minus_ion_type $minus_ion_type lennard-jones $lj_epsilon $currentsigma [ expr $WCA_factor * ( $minus_ion_radius + $minus_ion_radius) ] 0.25 
    }
    integrate 10
    # We integrate until the temperature is OK, so that the Langevin thermostat
    # removes the heat.
    while {  [ expr [ analyze energy kinetic ] /3/$n_ion_pairs ] > [expr $temperature*1.01] } {
        puts "LJ warmup: T = [ expr [ analyze energy kinetic ] /3/$n_ion_pairs ]" 
        integrate 10
    }
    set currentsigma [ expr $currentsigma * 1.05 ]
    set currenttime_step [ expr $currenttime_step * 1.05 ]
}



## Lets restore original interactions and time step
inter $plus_ion_type $plus_ion_type lennard-jones $lj_epsilon [ expr $plus_ion_radius + $plus_ion_radius ] [ expr $WCA_factor * ( $plus_ion_radius + $plus_ion_radius) ] 
inter $minus_ion_type $minus_ion_type lennard-jones $lj_epsilon [ expr $minus_ion_radius + $minus_ion_radius ] [ expr $WCA_factor * ( $minus_ion_radius + $minus_ion_radius) ] 
inter $minus_ion_type $plus_ion_type lennard-jones $lj_epsilon [ expr $minus_ion_radius + $plus_ion_radius ] [ expr $WCA_factor * ( $minus_ion_radius + $plus_ion_radius) ] 
setmd time_step $time_step


puts "Tune P3M, init ICC"

if {1==0} {

	#set d  [expr $wall_sigma*0.5]
	set d  [expr $wall_sigma*0]
	set res [expr $plus_ion_radius+$minus_ion_radius]
	dielectric slitpore pore_mouth [ expr $pore_mouth - $d ] \
		 	    channel_width [ expr $channel_width+2*$d] \
			    pore_width [ expr $pore_width + 2*$d] \
			    pore_length [ expr $pore_length + 0*$d ] \
			    upper_smoothing_radius [ expr $upper_smoothing_radius -$d ] \
			    lower_smoothing_radius [ expr $lower_smoothing_radius + $d ] \
			    res $res eps 1000



	puts [ inter coulomb $l_B p3m tunev2 accuracy 1e-2 ]

	iccp3m $n_induced_charges epsilons $icc_epsilons normals $icc_normals areas $icc_areas sigmas $icc_sigmas relax 0.7 max_iterations 50 convergence 0.01 first_id [ expr 2*$n_ion_pairs ]
}

puts [ inter coulomb $l_B p3m tunev2 accuracy 1e-3 ]

#SimBoxParticles
set ds 0.1
set bx [expr $box_l_x-$ds]
set by [expr $box_l_y-$ds]
set bz [expr $box_l_z-$ds]

part [setmd n_part] pos $ds $ds $ds fix 1 1 1 type 5
part [setmd n_part] pos $bx $ds $ds fix 1 1 1 type 5
part [setmd n_part] pos $ds $by $ds fix 1 1 1 type 5
part [setmd n_part] pos $bx $by $ds fix 1 1 1 type 5

part [setmd n_part] pos $ds $ds $bz fix 1 1 1 type 5
part [setmd n_part] pos $bx $ds $bz fix 1 1 1 type 5
part [setmd n_part] pos $ds $by $bz fix 1 1 1 type 5
part [setmd n_part] pos $bx $by $bz fix 1 1 1 type 5



set vmd_output "yes"
if { $vmd_output == "yes" } {
  prepare_vmd_connection "test" 10000 
  after 1000
  imd positions
}

setmd time_step 0.001
#set temp_current [ expr [ analyze energy kinetic ] /3.0/$n_ion_pairs ]
for { set  i 0 } { $i < 10 } { incr i } {
	integrate 100
	#set temp_current [ expr [ analyze energy kinetic ] /3.0/$n_ion_pairs ]
        puts "Electro warmup: $i / 10" 
	imd positions
}
setmd time_step $time_step

#puts n_induced_charges
#puts $n_induced_charges
#
#puts icc_epsilons
#puts $icc_epsilons
#
#puts icc_normals
#puts $icc_normals
#
#puts icc_sigmas
#puts $icc_sigmas
#

#set density_map_resolution 0.2
#set plus_dens [ observable new density_profile xbins [ expr int(floor( $box_l_x / $density_map_resolution)) ] zbins  [ expr int(floor( $box_l_z / $density_map_resolution)) ]  type $plus_ion_type ] 
#set minus_dens [ observable new density_profile xbins [ expr int(floor( $box_l_x / $density_map_resolution)) ] zbins  [ expr int(floor( $box_l_z / $density_map_resolution)) ]  type $minus_ion_type ] 
#set plus_dens_av [ observable new average $plus_dens ]
#set minus_dens_av [ observable new average $minus_dens ]
#observable $plus_dens_av autoupdate 0.1
#observable $minus_dens_av autoupdate 0.1

# after warmup

#iccp3m $n_induced_charges epsilons $icc_epsilons normals $icc_normals areas $icc_areas sigmas $icc_sigmas  convergence 1e-0 first_id [ expr 2*$n_ion_pairs ]

puts "Load External Potential"


external_potential tabulated file "mesh.dat" scale $scale


#set ofile [ open "${outputPath}forces.dat" "w" ]
#set lj_epsilon 0.
#set plus_ion_radius 0.
#set minus_ion_radius 0.
#inter $plus_ion_type $plus_ion_type lennard-jones $lj_epsilon [ expr $plus_ion_radius + $plus_ion_radius ] [ expr $WCA_factor * ( $plus_ion_radius + $plus_ion_radius) ] 
#inter $minus_ion_type $minus_ion_type lennard-jones $lj_epsilon [ expr $minus_ion_radius + $minus_ion_radius ] [ expr $WCA_factor * ( $minus_ion_radius + $minus_ion_radius) ] 
#inter $minus_ion_type $plus_ion_type lennard-jones $lj_epsilon [ expr $minus_ion_radius + $plus_ion_radius ] [ expr $WCA_factor * ( $minus_ion_radius + $plus_ion_radius) ] 
#thermostat off
#integrate 1
#for { set i 0 } { $i < [ setmd n_part ] } { incr i } {
#  puts $ofile [ part $i print pos f ]
#}
#exit


for { set i 0 } { $i < 1000000 } { incr i } {
  integrate 10
  imd positions
  puts "temperature is [ expr [ analyze energy kinetic ] /3/$n_ion_pairs ]" 
  puts "ICC needed [ iccp3m no_iterations ] iterations in the last step"
}

 




