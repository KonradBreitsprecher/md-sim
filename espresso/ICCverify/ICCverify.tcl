t_random seed 

#---------------------------------------------------------
#-------------------------------INPUT--------------------------------
#---------------------------------------------------------

puts "ARGS:  VOLTAGE PATH_LEFT_ELECTRODE PATH_RIGHT_ELECTRODE EXTERNAL_POTENTIAL DATA_OUTPUT"

#ARG1: VOLTAGE
set UBat_V [lindex $argv 0]

#ARG2: PATH TO LEFT ELECTRODE
set left_electrode [lindex $argv 1]

#ARG3: PATH TO RIGHT ELECTRODE
set right_electrode [lindex $argv 2]

#ARG4: EXTERNAL POTENTIAL INPUT/OUTPUT PATH
set ext_pot_path [lindex $argv 3]

#ARG5: DATA OUTPUT PATH
set path [lindex $argv 4]

#CREATE PATH FOR RUNIDENT
file mkdir $path

#---------------------------------------------------------
#-------------------------------BOX----------------------------------
#---------------------------------------------------------

set box_x 10
set box_y 10
set box_z 30

setmd box_l $box_x $box_y $box_z
setmd periodic 1 1 1
#cellsystem layered 1
#setmd min_global_cut 10

#cellsystem domain_decomposition -no_verlet_list

#---------------------------------------------------------
#----------------------------THERMOSTAT------------------------------
#---------------------------------------------------------

#Thermostat / Verlet parameters
set SI_temperature 400.0
set kb_kjmol 0.0083145
set temperature [expr $SI_temperature*$kb_kjmol]
set gamma       1.0

#thermostat langevin $temperature $gamma
thermostat off

#---------------------------------------------------------
#----------------------------TIMESCALE-------------------------------
#---------------------------------------------------------

set skin 0.4
#ns
set time_scale 1.0e-4 

set time_step_fs 2.0
set time_step [expr $time_step_fs / ($time_scale*1e6) ]

setmd skin $skin 
setmd time_step $time_step

#---------------------------------------------------------
#-----------------------------CONSTANTS-----------------------------
#---------------------------------------------------------

#AVOGADRO NUMBER
set N_A 6.022141e23
#VACUUM PERMITTIVITY
#(kJ * Angstrom) / ((elementary charge)^2 * N_A)
set epsilon_0 5.728e-5
#BJERRUM length
set l_b [expr 1.67101e-5/$SI_temperature*1e10]
#(au) to ANGSTROM
set au_to_angs 0.529177211

#---------------------------------------------------------
#-------------------------------TYPES---------------------------------
#---------------------------------------------------------

set icc_wall_type 0
set testcharge_type 1


#---------------------------------------------------------
#-------------------------MESH WALLS------------------------------
#---------------------------------------------------------
global icc_areas icc_normals icc_epsilons icc_sigmas

set UBat [expr $UBat_V/0.01036427]

set stl_files [list $left_electrode $right_electrode]
set pots [list [expr -$UBat*0.5] [expr $UBat*0.5]]
set types [list $icc_wall_type $icc_wall_type]
#set bins [list 100 100 150]
set bins_per_angstrom 10
#set bins [list [expr $box_x*$bins_per_angstrom] [expr $box_y*$bins_per_angstrom] [expr $box_z*$bins_per_angstrom]]
set bins [list [expr $box_x*$bins_per_angstrom] 1 [expr $box_z*$bins_per_angstrom]]
#puts [meshToParticles [lindex $stl_files 0] 0 [lindex $types 0]]
#puts [meshToParticles [lindex $stl_files 1] [setmd n_part] [lindex $types 1]]
set num_particles [mesh_capacitor_icc 0 $stl_files $pots $types $bins $ext_pot_path] 

set iccParticles [setmd n_part]
set iccParticlesLeft [lindex $num_particles 0]
set iccParticlesRight [lindex $num_particles 1]
puts "ICC PARTS LEFT: $iccParticlesLeft"
puts "ICC PARTS RIGHT: $iccParticlesRight"

# [expr int($iccParticles/2)]

for {set i 0} {$i < $iccParticles} {incr i} { 
	lappend icclist $i
}

#-----------------------
puts "\n--> Test Charge"
#-----------------------

set tq_margin 0.01
set tq_ds 0.01
set testrange_z_start [expr 0.0 + $tq_margin]
set testrange_z_end [expr 20.0 - $tq_margin+1e-6]
set tq_ID [setmd n_part]
set tq_x [expr $box_x/2]
set tq_y [expr $box_y/2]
set tq 1
set tq_Fint 0
part $tq_ID pos $tq_x $tq_y $testrange_z_start fix 1 1 1 q $tq type $testcharge_type

#-----------------------
puts "\n--> Electrostatics"
#-----------------------

puts "Tune P3M"
puts [inter coulomb $l_b p3m tunev2 accuracy 1e-4]

puts "Load External Potential"
external_potential tabulated file $ext_pot_path scale [list 0 $tq]

puts "Switch on ICC"
puts [iccp3m $iccParticles epsilons $icc_epsilons normals $icc_normals areas $icc_areas sigmas $icc_sigmas ext_field 0.0 0.0 0.0 eps_out 1.0 relax 0.7 max_iterations 100 convergence 1e-4]

set obs_force [open "$path/testcharge_force.dat" "w"]
set obs_schargeL [open "$path/s_charge_L.dat" "w"]
set obs_schargeR [open "$path/s_charge_R.dat" "w"]
set obs_schargeL_t [open "$path/s_charge_t_all_L.dat" "w"]
set obs_schargeR_t [open "$path/s_charge_t_all_R.dat" "w"]

#-----------------------
puts "\n-->Starting integration"
#-----------------------

integrate 10
set n_step 25

for {set tq_z $testrange_z_start} {$tq_z <= $testrange_z_end} {set tq_z [expr $tq_z+$tq_ds]} {
	
	part $tq_ID pos $tq_x $tq_y $tq_z

	imd positions

	#Integrate
	integrate 1

	#Measurements
	set tq_F [lindex [part $tq_ID print F] 2]
    set tq_Fint [expr $tq_Fint + $tq_F*$tq_ds*0.01036427]	
	puts $obs_force "$tq_z $tq_F $tq_Fint"

	set md_time_ns [expr $time_scale * [setmd time]]

    set iccChargeLeft 0
	set charges ""
	for {set i 0} {$i < $iccParticlesLeft} {incr i} { 
		set qa [part $i print q]
		set iccChargeLeft [expr $iccChargeLeft + $qa] 
		if {$charges==""} {
			set charges $qa
		} else {
			set charges "$charges $qa"
		}
	}
	set cl "$md_time_ns $iccChargeLeft"
	puts $obs_schargeL $cl
	flush $obs_schargeL
	puts $obs_schargeL_t $charges

	set iccChargeRight 0
	set charges ""
	for {set j $i} {$j < $iccParticles} {incr j} { 
		set qa [part $j print q]
		set iccChargeRight [expr $iccChargeRight + $qa]
		if {$charges==""} {
			set charges $qa
		} else {
			set charges "$charges $qa"
		}
	}
	set cr "$md_time_ns [expr $iccChargeRight]"
	puts $obs_schargeR $cr 
	flush $obs_schargeR
	puts $obs_schargeR_t $charges

	puts "z [format "%3.2f" $tq_z]  Ql [format "% 2.5f" $iccChargeLeft]  Qr [format "% 2.5f" $iccChargeRight]  F [format "% 6.2f" $tq_F]  Fint [format "% 6.2f" $tq_Fint]" 
}

#-----------------------
puts "\n--> Writing results"
#-----------------------

close $obs_force
close $obs_schargeL
close $obs_schargeR
close $obs_schargeL_t
close $obs_schargeR_t

#-------------------------
puts "\n--> All done" ;flush stdout
#-------------------------

