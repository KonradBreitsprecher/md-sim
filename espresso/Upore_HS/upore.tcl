
set NAME  "CDC ELECTRODES + CONSTANT POTENTIAL ICC + BMIMPF6 + SPC/E Water"
set startMsg "Starting...$NAME"
set startMsgB [string repeat "#" [string length $startMsg]]
puts "$startMsgB\n$startMsgB\n\n$startMsg\n\n$startMsgB\n$startMsgB"

#---------------------------------------------------------
#--------------------------------INIT--------------------------------
#---------------------------------------------------------

#Stopwatch
set start_time [expr 1.0*[clock clicks -milliseconds]]

#Seed
for {set i 0} {$i < 24} {incr i} {
   lappend pIDs [pid]
}

t_random seed 

#electrodes/walls
set structure_path "structure/"

#load functions
source functions.tcl

#VMD CONNECTION
set live_vmd 0

#---------------------------------------------------------
#-------------------------------INPUT--------------------------------
#---------------------------------------------------------


#ARG0: WALLTIME
set hours [lindex $argv 0] 
set wall_time [expr $hours*3600.0]

#ARG1: VOLTAGE
set UBat_V [lindex $argv 1]

#ARG2: PORE WIDTH
set pore_w [lindex $argv 2]

#ARG3: PORE DEPTH
set pore_d [lindex $argv 3]

#LOAD CORRELATORS
set load_correlators 1 
#[lindex $argv 3]

#COMPUTE RDFs
set compute_rdfs 1 
#[lindex $argv 4]

set geo_name "pw_${pore_w}__pd_${pore_d}"
set sys_name "U_${UBat_V}V__${geo_name}"
set path "out_${sys_name}"
puts "Output path: $path"

#Const charge Equi
if {$UBat_V==0} {
	set constChargeEqui "no"
} else {
	set constChargeEqui "yes"
}

set useICC "yes"

#---------------------------------------------------------
#-------------------------------PATHS----------------------------------
#---------------------------------------------------------

#PATH TO LEFT ICC WALL
set left_electrode "${structure_path}l_e_${geo_name}.stl"
puts "Left electrode: $left_electrode"
#PATH TO RIGHT ICC WALL
set right_electrode "${structure_path}r_e_${geo_name}.stl"
puts "Right electrode: $right_electrode\n"

#EXTERNAL POTENTIAL INPUT/OUTPUT PATH
set ext_pot_path "potentials/ext_pot_${sys_name}.dat"
puts "External potential: $ext_pot_path"

#---------------------------------------------------------
#-------------------------------CHECKPOINT----------------------------------
#---------------------------------------------------------
set useCheckpoint "no"
if {[file exists "${path}/checkpoint.dat"] == 1} {
	puts "Using checkpoint"
	set useCheckpoint "yes"
	set pathToCheckpoint "${path}/checkpoint.dat" ;#"${path}/checkpoint_r_[lindex $argv 4].dat"

	#save current checkpoint
	file copy -force $pathToCheckpoint "${path}/checkpoint_backup.dat"
} else {
	puts "No checkpoints found"
	set restarts 0
	#CREATE PATH FOR RUNIDENT
	file mkdir $path
}



#---------------------------------------------------------
#-------------------------------PORE GEOMETRY----------------------------------
#---------------------------------------------------------

set c_sigma 3.37

#pore_d ARG
#pore_w ARG

set pore_e1 4 ;#Edge radius pore exit
set pore_e2 2 ;#Edge radius pore floor
set pore_b 25 ;#Embedded plane edge length
set pore_rim 10 ;#Rim
set pore_gap 80 ;#Gap between electrodes

set pore_total_width [expr 2*$pore_rim+$pore_w+2*$pore_e1]
set pore_total_heigth [expr 2*$pore_d+$pore_gap]

#Volume with sigma_carbon/2 offset from borders
set pore_volume [expr 2*$pore_b*(($pore_gap/2-$c_sigma/2)*(2*$pore_rim+2*$pore_e1+$pore_w)+($pore_d-$c_sigma/2)*($pore_w-$c_sigma)+2*(1-3.1415/4)*(pow($pore_e1,2)-pow($pore_e2,2)))]
#Volume according to carbon center positions
set pore_volume_c [expr 2*$pore_b*(($pore_gap/2)*(2*$pore_rim+2*$pore_e1+$pore_w)+($pore_d)*($pore_w)+2*(1-3.1415/4)*(pow($pore_e1,2)-pow($pore_e2,2)))]

set pore_surface [expr 2.0*($pore_rim+0.25*2.0*[PI]*($pore_e1+$pore_e2)+$pore_d-$pore_e1-$pore_e2+$pore_w*0.5-$pore_e2)*$pore_b]

#bulk density
set bulk_z_l [expr $pore_d+5]
set bulk_z_u [expr $pore_d-5+$pore_gap]
set bulk_volume [expr ($bulk_z_u - $bulk_z_l)*$pore_b*$pore_total_width]


#---------------------------------------------------------
#-------------------------------BOX----------------------------------
#---------------------------------------------------------

set box_x $pore_total_width
set box_y $pore_b
set box_z $pore_total_heigth

set gap [expr 0.15*$box_z]
set box_z_tot [expr $gap+$box_z]

#spawn places
set partSpawnL [expr $pore_d+7]; 
set partSpawnR [expr $pore_d+$pore_gap-7];
set partSpawnW [expr $partSpawnR-$partSpawnL]

setmd box_l $box_x $box_y $box_z_tot
setmd periodic 1 1 1

#cellsystem nsquare
cellsystem domain_decomposition


#cellsystem layered 1
setmd min_global_cut 10

#cellsystem domain_decomposition -no_verlet_list

#coordinate to determine particles in pores
set z_upper [expr $pore_d+$pore_gap]
set z_lower $pore_d

#coordinate to determine particles in pore bulk
set pbm 0.2
set z_pb_up1 [expr $pore_d+$pore_gap+$pore_d*$pbm]
set z_pb_up2 [expr 2.0*$pore_d+$pore_gap-$pore_d*$pbm]
set z_pb_low1 [expr $pore_d*$pbm]
set z_pb_low2 [expr $pore_d-$pore_d*$pbm]
set volume_pore_bulk [expr (1.0-2.0*$pbm)*($pore_d)*($pore_w-$c_sigma)*$pore_b]
set volume_pore_bulk_c [expr (1.0-2.0*$pbm)*($pore_d)*($pore_w)*$pore_b]
#---------------------------------------------------------
#----------------------------TIMESCALE-------------------------------
#---------------------------------------------------------

#ns
set time_scale 1.0e-4 

set time_step_fs 2.0
set time_step [expr $time_step_fs / ($time_scale*1e6) ]


setmd time_step $time_step

#---------------------------------------------------------
#----------------------------THERMOSTAT------------------------------
#---------------------------------------------------------

#Thermostat / Verlet parameters
set SI_temperature 400.0
set kb_kjmol 0.0083145
set temperature [expr $SI_temperature*$kb_kjmol]
set gamma       1.0

thermostat langevin $temperature $gamma

#---------------------------------------------------------
#----------------------------WARMUP/EQUILIBRATION------------------------------
#---------------------------------------------------------

set warmup_time 0.1 ;# in ns, without electrostatics, fast, for fillung pores
set equi_time_elstat 0.01 ;#in ns, with elstat, without icc
set equi_time 0.005 ;#in ns with icc
set cc_equi_time 0.005 ;#in ns

set equi_time_md [expr $equi_time/$time_scale]
set warmup_time_md [expr $warmup_time/$time_scale]
set elstat_equi_time_md [expr $equi_time_elstat/$time_scale]
set cc_equi_time_md [expr $cc_equi_time/$time_scale]

set radius_factor 0.008
set warmup_integ_steps 100
set initial_force_cap 100
set force_cap $initial_force_cap
set max_forcecap 5e6; #cap when warmup stops



#---------------------------------------------------------
#-----------------------------CONSTANTS-----------------------------
#---------------------------------------------------------

#AVOGADRO NUMBER
set N_A 6.022141e23
#VACUUM PERMITTIVITY
#(kJ * Angstrom) / ((elementary charge)^2 * N_A)
set epsilon_0 5.728e-5
#Epsilon_R
set epsilon_r 2
#BJERRUM length
set l_b [expr 1.67101e-5/$SI_temperature*1e10/$epsilon_r]

#---------------------------------------------------------
#----------------------------MEASUREMENTS-------------------------------
#---------------------------------------------------------

#####SAMPLING PARAMETERS
set sampleTime [expr 3*$time_step]
set tauMax [expr 2*$sampleTime]

set rdf_rmax 24.0
set rdf_rmin 3.0
set rdf_bin 200

#---------------------------------------------------------
#-------------------------------IONS/SYSTEM---------------------------------
#---------------------------------------------------------

set n_step 250 ;#main integration steps

set vol_frac 0.31
set sig_ion 5.0
set eps_ion 1.0

#Ion numbers
set vol_ion [expr [PI]/6.0*pow($sig_ion,3)]
set n_ion_pairs [expr round(0.5*1.0*$vol_frac*$pore_volume*6.0/[PI]/pow($sig_ion,3))]
set n_ions [expr 2*$n_ion_pairs ]

#initial number of loops
set n_loops 0

set cutoff_factor 2.35

setmd skin 0.4

#---------------------------------------------------------
#-------------------------------TYPES---------------------------------
#---------------------------------------------------------

set type_icc_wall 0
set type_c 1
set type_a  2

#---------------------------------------------------------
#------------------------BMIM-PF6-PARAMETERS--------------------------
#---------------------------------------------------------

#charges
set q_c 1
set q_a -1

set m_c 144 
set m_a 144 

#---------------------------------------------------------
#------------------------------CARBON-------------------------------
#---------------------------------------------------------

set lj_sig_w  3.37
set lj_eps_w  1.0
set m_carbon 12.0

#---------------------------------------------------------
#---------------------------MIXING RULES----------------------------
#---------------------------------------------------------

set wca_pre [expr pow(2.0,1.0/6.0)]
set r_cut [expr $wca_pre*$sig_ion]

#mixed sigmas
set lj_sig_mix_c_w [expr 0.5*($sig_ion+$lj_sig_w)]
set lj_sig_mix_a_w [expr 0.5*($sig_ion+$lj_sig_w)]

set lj_rcut_c_w [expr $lj_sig_mix_c_w*$wca_pre]
set lj_rcut_a_w [expr $lj_sig_mix_a_w*$wca_pre]

#---------------------------------------------------------
#-------------------------SYSTEM INFO--------------------------------
#---------------------------------------------------------

puts "\nOutput path:   	        $path"
puts "Timestep (fs):          $time_step_fs"
puts "Timestep (internal):    $time_step"
puts "Voltage (V):            $UBat_V"
puts "Number of ion pairs:    $n_ion_pairs"
puts "box x y z (A):          [format %.2f $box_x] [format %.2f $box_y] [format %.2f [expr $box_z+$gap]]"
puts "Pore volume:		$pore_volume"
puts "Pore volume carbon centers:		$pore_volume_c"
puts "Pore Surface:		$pore_surface"
puts "Cells: 			[setmd cell_grid]" 
puts "Bjerrum length (A):     $l_b"
puts "Temperature (K):	$SI_temperature, $temperature"
puts "Wall time:              $hours hours"
puts "Random seed:            [t_random seed]"
puts "Corr. Taumax: 		$tauMax"
puts "Corr. dt: 		$sampleTime"
puts "\n"

#---------------------------------------------------------
#-------------------------MESH WALLS------------------------------
#---------------------------------------------------------
global icc_areas icc_normals icc_epsilons icc_sigmas

set UBat [expr $UBat_V/0.01036427]

set stl_files [list $left_electrode $right_electrode]
set pots [list [expr -$UBat*0.5] [expr $UBat*0.5]]
set types [list $type_icc_wall $type_icc_wall]
set bins_per_angstrom 10
set bins [list [expr int($box_x*$bins_per_angstrom)] 1 [expr int($box_z_tot*$bins_per_angstrom)]]
set num_particles [mesh_capacitor_icc 0 $stl_files $pots $types $bins [expr 2.5/$bins_per_angstrom] 1000000 1e-7 $epsilon_0 $ext_pot_path] 

set iccParticles [setmd n_part]
set iccParticlesLeft [lindex $num_particles 0]
set iccParticlesRight [lindex $num_particles 1]
puts "ICC PARTS LEFT: $iccParticlesLeft"
puts "ICC PARTS RIGHT: $iccParticlesRight"

# [expr int($iccParticles/2)]

for {set i 0} {$i < $iccParticles} {incr i} {
	lappend icclist $i
}

set fudge_slit 9
set cc_guess [expr $pore_surface*$epsilon_0*$UBat/$pore_gap*$fudge_slit / (0.5*$iccParticles)]
puts "Guessed total charge: [expr $cc_guess * 0.5 * $iccParticles]"

#puts "Mindist icc particles: [analyze mindist $type_icc_wall $type_icc_wall]"

#for {set i 0} {$i < $iccParticles} {incr i} { 
#	for {set j [expr $i+1]} {$j < $iccParticles} {incr j} {
#		set d [veclen [vecsub [part $i print pos folded] [part $j print pos folded]]]
#		if {$d < 0.1} {
#			puts "$i $j"
#		}
#	}
#}

#Set Graphene-like Electrodes
#set num_wallpartsL [meshToParticles $left_wall $iccParticles $type_wall]
#set num_wallpartsR [meshToParticles $right_wall [expr $iccParticles+$num_wallpartsL] $type_wall]

#puts "Wall parts L: $num_wallpartsL"
#puts "Wall parts R: $num_wallpartsR"

set totalWallParts [setmd n_part]
#---------------------------------------------------------
#-------------------------CREATE IONS---------------------------------
#---------------------------------------------------------

set ionlist ""
set anionlist ""
set cationlist ""


#PLACE ANIONS
for {set i $totalWallParts} { $i < [expr $n_ion_pairs + $totalWallParts] } {incr i} {
    set posx [expr $box_x*[t_random]]
    set posy [expr $box_y*[t_random]]
    set posz [expr $partSpawnW*[t_random]+$partSpawnL]

    part $i pos $posx $posy $posz q $q_a type $type_a mass $m_a
    
	lappend anionlist $i
    lappend ionlist $i
}

#PLACE CATIONS	
for {set j $i} { $j < [expr $n_ions + $totalWallParts] } {incr j} {
    set posx [expr $box_x*[t_random]]
    set posy [expr $box_y*[t_random]]
    set posz [expr $partSpawnW*[t_random]+$partSpawnL]
    
    part $j pos $posx $posy $posz type $type_c mass [expr $m_c] q $q_c
    
    lappend cationlist $j
    lappend ionlist $j
}


puts "Placed particles"
#list with all particles except walls
set illist [list {*}$ionlist]
#puts "Ion list: [llength $ionlist]"


#Interaction with walls
inter $type_c $type_icc_wall lennard-jones 1.0 $lj_sig_mix_c_w $lj_rcut_c_w auto
inter $type_a $type_icc_wall lennard-jones 1.0 $lj_sig_mix_a_w $lj_rcut_a_w auto


#VMD live connection
if {$live_vmd == 1} { 
	prepare_vmd_connection vmdout 10000
	imd positions
}

if {$useCheckpoint == "no"} {

	puts "Write restarts file"
    set restart_file [open "${path}/restarts.dat" "a"]
    puts $restart_file "Simulation $restarts, time: [format %.4f [expr $time_scale * [setmd time]]] ns, voltage: $UBat_V, loaded_corrs: $load_correlators"
    close $restart_file

	#---------------------------------------------------------
	puts "Blow up sigmas"
	#---------------------------------------------------------

	inter forcecap $initial_force_cap

	while {1} {
		set radius_factor [expr $radius_factor*1.2]
		puts "t=[format %.1f [setmd time]], E=[analyze energy total], Rad.-Fac.: [format %.3f $radius_factor], Mindist: PF6:[format %.2f [analyze mindist $type_a $type_a]], BMIM:[format %.2f [analyze mindist $type_c $type_c]]"
		flush stdout

		if {$radius_factor>=0.9} { break	}	

		#blow up particle radii
		set blow_rad [expr $radius_factor*$sig_ion]
		inter $type_c $type_c lennard-jones $eps_ion $blow_rad [expr $wca_pre*$blow_rad] auto
		inter $type_a $type_a lennard-jones $eps_ion $blow_rad [expr $wca_pre*$blow_rad] auto
		inter $type_a $type_c lennard-jones $eps_ion $blow_rad [expr $wca_pre*$blow_rad] auto

		integrate $warmup_integ_steps

		if {$live_vmd == 1} { imd positions	}

	}

	#heat up system to fill pores, warm up until forcecapping is quite high
	set temp [expr $kb_kjmol*$SI_temperature/pow(0.9,30)] 
	puts "\n\nFilling Temperature: [format %.1f $temp] / [format %.1f [expr $temp/$kb_kjmol]] K"
	thermostat langevin $temp $gamma

	puts "Warmup until forcecap is $max_forcecap"
	while {1} {
		if {$force_cap>$max_forcecap} { break }
		set force_cap [expr $force_cap*1.2]
		inter forcecap  $force_cap
		puts "t=[format %.1f [setmd time]], E=[analyze energy total], Cap: [format %.0f $force_cap], Mindist: PF6:[format %.2f [analyze mindist $type_a $type_a]], BMIM:[format %.2f [analyze mindist $type_c $type_c]]"
		flush stdout
	
		integrate $warmup_integ_steps

		if {$live_vmd == 1} { imd positions	}
	}

} ;#checkpoint


inter forcecap 0
if {$useCheckpoint == "no"} {
	setmd time 0.0
	#continue filling pores

	puts "\nFill pores to t=$warmup_time"
	for {set i 0} {[setmd time] < $warmup_time_md} {incr i} {

		#compute bulk density
		set ions_in_bulk_num [ions_in_bulk]
		set bulk_density [expr $ions_in_bulk_num/($bulk_volume)]

	
		#compute particles in pores
		set parts_in_pores [expr [count_parts_lower $cationlist]+[count_parts_lower $anionlist]+[count_parts_upper $cationlist]+[count_parts_upper $anionlist]]
		
		puts "t=[format %.4f [expr [setmd time]*$time_scale]], E=[analyze energy total], P. in pores: $parts_in_pores / [expr $n_ions] ([format %.2f [expr double($parts_in_pores)/($n_ions)*100]] %), bulk dens.: [format %.2f $bulk_density] ,[expr $ions_in_bulk_num/2] parts, T=[temp_il]"
		flush stdout
	
		integrate $warmup_integ_steps

		if {$live_vmd == 1} { imd positions	}
	}

	#cool down
	for {set i 0} {$i < 30} {incr i} {
		set temp [expr $temp*0.9]
		puts "Cool down, temperature: [format %.1f $temp]\r"
		flush stdout
		thermostat langevin $temp $gamma
		integrate 10
	}

	#kill_particle_motion
	thermostat langevin $temperature $gamma
}

#---------------------------------------------------------
#-------------------------SETUP INTERACTIONS---------------------------------
#---------------------------------------------------------

puts "\nActivate full interactions"

inter $type_c $type_c lennard-jones $eps_ion $sig_ion $r_cut auto
inter $type_a $type_a lennard-jones $eps_ion $sig_ion $r_cut auto
inter $type_a $type_c lennard-jones $eps_ion $sig_ion $r_cut auto

#---------------------------------------------------------
#-----------------------LOAD CHECKPOINT--------------------------
#---------------------------------------------------------

if {$useCheckpoint == "yes"} {

	#-----------------------
	puts "\n--> Load checkpoint $pathToCheckpoint"
	#-----------------------

	set infile [open "$pathToCheckpoint" "r"]
	while { [blockfile $infile read auto] != "eof" } {}
	close $infile

	#save current state of density observables
	file copy -force "${path}/dens_z_total_slice_latest.dat" "${path}/dens_z_total_slice_r${restarts}.dat"
	file copy -force "${path}/dens_xy_lower_latest.dat" "${path}/dens_xy_lower_r${restarts}.dat"
	file copy -force "${path}/dens_xy_upper_latest.dat" "${path}/dens_xy_upper_r${restarts}.dat"
	
	setmd time $md_time
	incr restarts 

    set restart_file [open "${path}/restarts.dat" "a"]
    puts $restart_file "Simulation $restarts, time: [format %.4f [expr $time_scale * [setmd time]]] ns, voltage: $UBat_V, loaded_corrs: $load_correlators"
    close $restart_file

	#integrate 0
	puts "Restart NR: $restarts at [expr $time_scale*$md_time] ns ($n_loops loops)"

}


#USE SMALL RND START CHARGE FOR ICC PARTICLES
for {set i 0} {$i < $iccParticles} {incr i} {
   part $i q 0 
#[ expr 0.1*([ t_random ]-0.5) ]
}

#activate electrostatics and icc, load potential
puts "Tune P3M"
puts [inter coulomb $l_b p3m tunev2 accuracy 1e-4]


#-----------------------
puts "\n--> Quick electrostatic equilibration"
#-----------------------

if {$useCheckpoint == "no"} {

	setmd time 0.0
#setmd time_step [expr $time_step*0.1]
	for {set i 0} {[setmd time] < $elstat_equi_time_md} {incr i} {

		puts "t=[format %.4f [expr [setmd time]*$time_scale]]"
		puts [analyze energy]
		flush stdout
	
		integrate $n_step
		if {$live_vmd == 1} { imd positions	}
	}

#	setmd time_step $time_step
}

if {$UBat_V != 0.0} {
	external_potential tabulated file $ext_pot_path scale [list 0 $q_c $q_a]
	puts "External potential loaded: $ext_pot_path"
} else {
	puts "No potential to load since UBat is 0V"
}

#No ICC
if {$useICC == "no"} {

		for {set i 0} {$i < $iccParticles} {incr i} {
			part $i q 0
		}

		#---------------------------------------------------------
		#-----------------------EQUILIBRATE SYSTEM--------------------------
		#---------------------------------------------------------
		if {$useCheckpoint == "no"} {

			setmd time 0.0
			inter forcecap 0
			puts "\nEquilibrate to t=[format %.4f [expr $equi_time]]"
			for {set i 0} {[setmd time] < $equi_time_md} {incr i} {

				#compute bulk density
				set ions_in_bulk_num [ions_in_bulk]
				set bulk_density [expr $ions_in_bulk_num/($bulk_volume)]

				puts "t=[format %.4f [expr [setmd time]*$time_scale]], E=[analyze energy total], bulk dens.: [format %.2f $bulk_density], bp: $ions_in_bulk_num, kintemp: [format %.2f [temp_il]]"
				flush stdout
			
				integrate $n_step
				save_energy "energy_equi.dat"
				if {$live_vmd == 1} { imd positions	}
			}

			#in case of a new simulation, reset time here
			setmd time 0.0

			puts "\nReset time, start production run"
		}


} else {
#Constant charge equi
	if {$useCheckpoint == "no" && $constChargeEqui == "yes"} {
		
		for {set i 0} {$i < $iccParticlesLeft} {incr i} { 
			part $i q [expr -$cc_guess]
		}
		for {set j $i} {$j < $iccParticles} {incr j} { 
			part $j q $cc_guess
		}

		setmd time 0.0
		puts "\nConst charge equilibration to t=[format %.4f [expr $cc_equi_time]]\n"
		for {set i 0} {[setmd time] < $cc_equi_time_md} {incr i} {

		
			set t0 [clock clicks -milliseconds]
			integrate $n_step
			set ts [expr 1.0/(0.005787037*([clock clicks -milliseconds]-$t0)/$n_step)]

			set parts_in_pores_pb [expr [count_parts_lower_pb $cationlist]+[count_parts_lower_pb $anionlist]+[count_parts_upper_pb $cationlist]+[count_parts_upper_pb $anionlist]]
			set pore_bulk_vf [expr $parts_in_pores_pb*$vol_ion/$volume_pore_bulk]

			puts "t=[format %.4f [expr [setmd time]*$time_scale]], E=[analyze energy total], [format %.2f $ts] ns/day, Pore Bulk volume fraction: $pore_bulk_vf"
			flush stdout

			if {$live_vmd == 1} { imd positions	}
		}

		setmd time 0.0
		puts "Switch on ICC"
		puts [iccp3m $iccParticles epsilons $icc_epsilons normals $icc_normals areas $icc_areas sigmas $icc_sigmas ext_field 0.0 0.0 0.0 eps_out 1.0 relax 0.75 max_iterations 100 convergence 5e-1]

		puts "\nReset time, start production run"

#Charge Dynamics
	} else {

		puts "Switch on ICC"

		set qa 1
		for {set i 0} {$i < $iccParticles} {incr i} {
			set qa [expr -$qa]
			part $i q [expr $qa*(0.00005 + 0.00005*[t_random])]
		}

		puts [iccp3m $iccParticles epsilons $icc_epsilons normals $icc_normals areas $icc_areas sigmas $icc_sigmas ext_field 0.0 0.0 0.0 eps_out 1.0 relax 0.75 max_iterations 100 convergence 5e-1]


		#---------------------------------------------------------
		#-----------------------EQUILIBRATE SYSTEM--------------------------
		#---------------------------------------------------------
		if {$useCheckpoint == "no"} {

			setmd time 0.0
			inter forcecap 0
			puts "\nEquilibrate to t=[format %.4f [expr $equi_time]]"
			for {set i 0} {[setmd time] < $equi_time_md} {incr i} {

				#compute bulk density
				set ions_in_bulk_num [ions_in_bulk]
				set bulk_density [expr $ions_in_bulk_num/($bulk_volume)]

				puts "t=[format %.4f [expr [setmd time]*$time_scale]], E=[analyze energy total], bulk dens.: [format %.2f $bulk_density], bp: $ions_in_bulk_num, kintemp: [format %.2f [temp_il]]"
				flush stdout
			
				integrate $n_step
				save_energy "energy_equi.dat"
				if {$live_vmd == 1} { imd positions	}
			}

			#in case of a new simulation, reset time here
			setmd time 0.0

			puts "\nReset time, start production run"
		}

	}
}
#-----------------------
puts "-->Init observables"
#-----------------------

#---------------------------------------------------------
#-----------------------OBSERVABLES--------------------------
#---------------------------------------------------------

#bulk layering
set nbins_z 200
set min_x 0
set max_x $pore_rim
set min_z $pore_d
set max_z [expr $pore_d+$pore_gap]
set list_z_bulk ""
for {set j 0} {$j < $nbins_z} {incr j} { lappend list_z_bulk [expr $min_z + 1.0*($max_z-$min_z)/$nbins_z*$j] }
set obs_bulk_dens_a_l [observable new density_profile type [list $type_a] minx $min_x maxx $max_x xbins 1 miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins $nbins_z]
set obs_bulk_dens_c_l [observable new density_profile type [list $type_c] minx $min_x maxx $max_x xbins 1 miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins $nbins_z]
set min_x [expr $pore_rim+2*$pore_e1+$pore_w]
set max_x $box_x
set obs_bulk_dens_a_r [observable new density_profile type [list $type_a] minx $min_x maxx $max_x xbins 1 miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins $nbins_z]
set obs_bulk_dens_c_r [observable new density_profile type [list $type_c] minx $min_x maxx $max_x xbins 1 miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins $nbins_z]

#ion densities in z-slices over the whole system including pores
set nbins 500
set min_x [expr $pore_rim+$pore_e1+1.5]
set max_x [expr $pore_rim+$pore_e1+$pore_w-1.5]
set min_z 0
set max_z [expr 2*$pore_d+$pore_gap]
set obs_anion_pos_id [observable new density_profile type [list $type_a] minx $min_x maxx $max_x xbins 1 miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins $nbins]
set obs_cation_pos_id [observable new density_profile type [list $type_c] minx $min_x maxx $max_x xbins 1 miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins $nbins]

#xy-slices through pores
set nbins_x 200
set min_x [expr $pore_rim+$pore_e1]
set max_x [expr $pore_rim+$pore_e1+$pore_w]
set min_z 5
set max_z [expr $pore_d-5]
set list_x ""
for {set j 0} {$j < $nbins_x} {incr j} { lappend list_x [expr $min_x + 1.0*($max_x-$min_x)/$nbins_x*$j] }
#lower
set obs_anion_xy_lower [observable new density_profile type [list $type_a] minx $min_x maxx $max_x xbins $nbins_x miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins 1]
set obs_cation_xy_lower [observable new density_profile type [list $type_c] minx $min_x maxx $max_x xbins $nbins_x miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins 1]
#upper
set min_z [expr $pore_d+$pore_gap+5]
set max_z [expr 2*$pore_d+$pore_gap-5]
set obs_anion_xy_upper [observable new density_profile type [list $type_a] minx $min_x maxx $max_x xbins $nbins_x miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins 1]
set obs_cation_xy_upper [observable new density_profile type [list $type_c] minx $min_x maxx $max_x xbins $nbins_x miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins 1]

#pore entrance
set nbins_x 80
set nbins_z 30
set entrance_offset_x 2
set entrance_offset_z 8
#lower
set min_x [expr $pore_rim-$entrance_offset_x]
set max_x [expr $pore_rim+2*$pore_e1+$pore_w+$entrance_offset_x]
set min_z [expr $pore_d-$pore_e1-$entrance_offset_z]
set max_z [expr $pore_d+$entrance_offset_z]
#puts "Pore entrance density observable: $min_x $max_x $min_z $max_z"
set list_entr_low_x ""
for {set j 0} {$j < $nbins_x} {incr j} { lappend list_entr_low_x [expr $min_x + 1.0*($max_x-$min_x)/$nbins_x*$j] }
#puts $list_entr_low_x
set list_entr_low_z ""
for {set j 0} {$j < $nbins_z} {incr j} { lappend list_entr_low_z [expr $min_z + 1.0*($max_z-$min_z)/$nbins_z*$j] }
#puts $list_entr_low_z
set obs_anion_entr_lower [observable new density_profile type [list $type_a] minx $min_x maxx $max_x xbins $nbins_x miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins $nbins_z]
set obs_cation_entr_lower [observable new density_profile type [list $type_c] minx $min_x maxx $max_x xbins $nbins_x miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins $nbins_z]

#upper
set min_x [expr $pore_rim-$entrance_offset_x]
set max_x [expr $pore_rim+2*$pore_e1+$pore_w+$entrance_offset_x]
set min_z [expr $pore_d+$pore_gap-$entrance_offset_z]
set max_z [expr $pore_d+$pore_gap+$pore_e1+$entrance_offset_z]
set list_entr_upp_x ""
for {set j 0} {$j < $nbins_x} {incr j} { lappend list_entr_upp_x [expr $min_x + 1.0*($max_x-$min_x)/$nbins_x*$j] }
set list_entr_upp_z ""
for {set j 0} {$j < $nbins_z} {incr j} { lappend list_entr_upp_z [expr $min_z + 1.0*($max_z-$min_z)/$nbins_z*$j] }
set obs_anion_entr_upper [observable new density_profile type [list $type_a] minx $min_x maxx $max_x xbins $nbins_x miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins $nbins_z]
set obs_cation_entr_upper [observable new density_profile type [list $type_c] minx $min_x maxx $max_x xbins $nbins_x miny 0 maxy $box_y ybins 1 minz $min_z maxz $max_z zbins $nbins_z]




#####CORRELATORS####
#bulk
set corr_bulk_dens_a_l [correlation new obs1 $obs_bulk_dens_a_l tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_bulk_dens_c_l [correlation new obs1 $obs_bulk_dens_c_l tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]

set corr_bulk_dens_a_r [correlation new obs1 $obs_bulk_dens_a_r tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_bulk_dens_c_r [correlation new obs1 $obs_bulk_dens_c_r tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]

#z-slices through pores
set corr_anion_pos [correlation new obs1 $obs_anion_pos_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_cation_pos [correlation new obs1 $obs_cation_pos_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
#x-slices through pore (perpend.)
#lower
set corr_anion_xy_lower [correlation new obs1 $obs_anion_xy_lower tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_cation_xy_lower [correlation new obs1 $obs_cation_xy_lower tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
#upper
set corr_anion_xy_upper [correlation new obs1 $obs_anion_xy_upper tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_cation_xy_upper [correlation new obs1 $obs_cation_xy_upper tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]

#pore entrance
#lower
set corr_anion_entr_lower [correlation new obs1 $obs_anion_entr_lower tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_cation_entr_lower [correlation new obs1 $obs_cation_entr_lower tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
#upper
set corr_anion_entr_upper [correlation new obs1 $obs_anion_entr_upper tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_cation_entr_upper [correlation new obs1 $obs_cation_entr_upper tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]



#fetch correlators from checkpoint
if {$useCheckpoint =="yes" && $load_correlators == 1} {
	puts "\n-->Read correlator checkpoint"
	correlation $corr_bulk_dens_a_l read_checkpoint_binary "$path/corr_bulk_dens_a.bin"
	correlation $corr_bulk_dens_c_l read_checkpoint_binary "$path/corr_bulk_dens_c.bin"
	correlation $corr_bulk_dens_a_r read_checkpoint_binary "$path/corr_bulk_dens_a.bin"
	correlation $corr_bulk_dens_c_r read_checkpoint_binary "$path/corr_bulk_dens_c.bin"
	correlation $corr_anion_pos read_checkpoint_binary "$path/corr_dens_anion.bin"
	correlation $corr_cation_pos read_checkpoint_binary "$path/corr_dens_cation.bin"
	correlation $corr_anion_xy_lower read_checkpoint_binary "$path/corr_anion_xy_lower.bin"
	correlation $corr_cation_xy_lower read_checkpoint_binary "$path/corr_cation_xy_lower.bin"
	correlation $corr_anion_xy_upper read_checkpoint_binary "$path/corr_anion_xy_upper.bin"
	correlation $corr_cation_xy_upper read_checkpoint_binary "$path/corr_cation_xy_upper.bin"
	correlation $corr_anion_entr_lower read_checkpoint_binary "$path/corr_anion_entr_lower.bin"
	correlation $corr_cation_entr_lower read_checkpoint_binary "$path/corr_cation_entr_lower.bin"
	correlation $corr_anion_entr_upper read_checkpoint_binary "$path/corr_anion_entr_upper.bin"
	correlation $corr_cation_entr_upper read_checkpoint_binary "$path/corr_cation_entr_upper.bin"

}

#start correlators
correlation $corr_bulk_dens_a_l autoupdate start
correlation $corr_bulk_dens_c_l autoupdate start
correlation $corr_bulk_dens_a_r autoupdate start
correlation $corr_bulk_dens_c_r autoupdate start

correlation $corr_anion_pos autoupdate start
correlation $corr_cation_pos autoupdate start

correlation $corr_anion_xy_lower autoupdate start
correlation $corr_cation_xy_lower autoupdate start

correlation $corr_anion_xy_upper autoupdate start
correlation $corr_cation_xy_upper autoupdate start

correlation $corr_anion_entr_lower autoupdate start
correlation $corr_cation_entr_lower autoupdate start

correlation $corr_anion_entr_upper autoupdate start
correlation $corr_cation_entr_upper autoupdate start

#puts "TRAJ: [file exists ${path}/trajectory.vtf]"

#Write structure+icc coords on first run 
if {$useCheckpoint == "no" || [file exists "${path}/trajectory.vtf"] == 0} {
	set obs_traj [open "$path/trajectory.vtf" "a"]
	puts "\n-->Writing structure data to $path/trajectory.vtf"
	writevsf $obs_traj short radius [list 0 [expr $lj_sig_w*0.5] 1 auto 2 auto] typedesc {0 "name ICC type 0" 1 "name Cation type 1" 2 "name Anion type 2"}
	writevcf $obs_traj short folded pids $icclist
	close $obs_traj
}



#file streams for observables
set obs_schargeL [open "$path/s_charge_L.dat" "a"]
set obs_schargeR [open "$path/s_charge_R.dat" "a"]
set obs_schargeL_t [open "$path/s_charge_t_all_L.dat" "a"]
set obs_schargeR_t [open "$path/s_charge_t_all_R.dat" "a"]
set obs_energy [open "$path/energy_obs.dat" "a"]
set obs_traj [open "$path/trajectory.vtf" "a"]
set obs_volfrac [open "$path/volfrac.dat" "a"]


#initialize lists 
#particles in pores
set pore_lower_cations ""
set pore_lower_anions ""
set pore_upper_cations ""
set pore_upper_anions ""

set time_list ""
set bulk_density_list ""

set dens_list ""

#icc charges
set list_obs_charge_l ""
set list_obs_charge_r ""



#-----------------------
puts "\n-->Starting integration"
#-----------------------

if {$useCheckpoint =="no"} {
	setmd time 0.0
}

set tot_parts [setmd n_part]

while {1} {

	if {$live_vmd == 1} { imd positions	}

	#compute bulk density
	set ions_in_bulk_num [ions_in_bulk]
	set bulk_density [expr $ions_in_bulk_num/($bulk_volume)]
	lappend bulk_density_list $bulk_density	

	#Timing
	set md_time_ns [expr $time_scale * [setmd time]]
	set curr_duration [expr (1.0*[clock clicks -milliseconds]-$start_time)/1e3]

	#Store configurations
	if {$compute_rdfs == 1} { analyze append }

	save_energy "energy_main.dat"

	#Integrate
	set t0 [clock clicks -milliseconds]
	integrate $n_step
	set ts [expr 1.0/(0.005787037*([clock clicks -milliseconds]-$t0)/$n_step)]



	lappend time_list [format %.4f $md_time_ns]


	#Measurements	



	#Write trajectory and all charges every n timesteps
	#if {[expr $n_loops%4] == 0} { 
		writevcf $obs_traj short folded pids $illist 

    set iccChargeLeft 0
	set charges ""
	for {set i 0} {$i < $iccParticlesLeft} {incr i} { 
		set qa [format %.4f [part $i print q]]
		set iccChargeLeft [expr $iccChargeLeft + $qa] 
		if {$charges==""} {
			set charges $qa
		} else {
			set charges "$charges $qa"
		}
	}
	set cl "[format %.4f $md_time_ns] [format %.4f $iccChargeLeft]"
	puts $obs_schargeL $cl
	lappend list_obs_charge_l $cl
	flush $obs_schargeL
	puts $obs_schargeL_t $charges

	set iccChargeRight 0
	set charges ""
	for {set j $i} {$j < $iccParticles} {incr j} { 
		set qa [format %.4f [part $j print q]]
		set iccChargeRight [expr $iccChargeRight + $qa]
		if {$charges==""} {
			set charges [format %.4f $qa]
		} else {
			set charges "$charges $qa"
		}
	}
	set cr "[format %.4f $md_time_ns]  [format %.4f [expr $iccChargeRight]]"
	puts $obs_schargeR $cr 
	lappend list_obs_charge_r $cr
	flush $obs_schargeR
	puts $obs_schargeR_t $charges


	#count particles in pores
	lappend pore_lower_cations [count_parts_lower $cationlist]
	lappend pore_lower_anions [count_parts_lower $anionlist]
	
	lappend pore_upper_cations [count_parts_upper $cationlist]
	lappend pore_upper_anions [count_parts_upper $anionlist]

	#}

	puts $obs_energy [analyze energy]

	set parts_in_pores_pb [expr [count_parts_lower_pb $cationlist]+[count_parts_lower_pb $anionlist]+[count_parts_upper_pb $cationlist]+[count_parts_upper_pb $anionlist]]
	set pore_bulk_vf [expr $parts_in_pores_pb*$vol_ion/$volume_pore_bulk]
	#Measured with carbon offset
	set bulk_vf [expr $ions_in_bulk_num*$vol_ion/$bulk_volume]
	#Measured from carbon centers
	set pore_bulk_vf_c [expr $parts_in_pores_pb*$vol_ion/$volume_pore_bulk_c]
	puts "(Accessible)     Pore Bulk volume fraction: $pore_bulk_vf   Bulk volume fraction: $bulk_vf"
	puts "(Carbon centers) Pore Bulk volume fraction: $pore_bulk_vf_c "

	puts $obs_volfrac "$md_time_ns $pore_bulk_vf $pore_bulk_vf_c $bulk_vf"

	set n_loops [expr $n_loops+1]

	
	puts "[format %.2f [expr $curr_duration/$wall_time*100.0]] %, $n_loops Loops/run, t: [format %.4f $md_time_ns] ns, E: [analyze energy total], Rho_B.: [format %.2f $bulk_density], bp: $ions_in_bulk_num, Tkin: [format %.2f [temp_il]] "
	
	puts "Charge left: [format %.3f $iccChargeLeft], right: [format %.3f $iccChargeRight]"
	puts "Computing time (ns/day): $ts"

#Break if wall time reached
        if {$curr_duration>=$wall_time} { break	}
}

#-----------------------
puts "\n--> Writing results"
#-----------------------
close $obs_traj
close $obs_schargeL
close $obs_schargeR
close $obs_schargeL_t
close $obs_schargeR_t
close $obs_energy
close $obs_volfrac

#Checkpoint correlators
correlation $corr_bulk_dens_a_l write_checkpoint_binary "$path/corr_bulk_dens_a.bin"
correlation $corr_bulk_dens_c_l write_checkpoint_binary "$path/corr_bulk_dens_c.bin"
correlation $corr_bulk_dens_a_r write_checkpoint_binary "$path/corr_bulk_dens_a.bin"
correlation $corr_bulk_dens_c_r write_checkpoint_binary "$path/corr_bulk_dens_c.bin"

correlation $corr_anion_pos write_checkpoint_binary "$path/corr_dens_anion.bin" 
correlation $corr_cation_pos write_checkpoint_binary "$path/corr_dens_cation.bin"

correlation $corr_anion_xy_lower write_checkpoint_binary "$path/corr_anion_xy_lower.bin"
correlation $corr_cation_xy_lower write_checkpoint_binary "$path/corr_cation_xy_lower.bin"

correlation $corr_anion_xy_upper write_checkpoint_binary "$path/corr_anion_xy_upper.bin"
correlation $corr_cation_xy_upper write_checkpoint_binary "$path/corr_cation_xy_upper.bin"

correlation $corr_anion_entr_lower write_checkpoint_binary "$path/corr_anion_entr_lower.bin"
correlation $corr_cation_entr_lower write_checkpoint_binary "$path/corr_cation_entr_lower.bin"

correlation $corr_anion_entr_upper write_checkpoint_binary "$path/corr_anion_entr_upper.bin"
correlation $corr_cation_entr_upper write_checkpoint_binary "$path/corr_cation_entr_upper.bin"

#Finalize correlators
correlation $corr_bulk_dens_a_l finalize
correlation $corr_bulk_dens_c_l finalize
correlation $corr_bulk_dens_a_r finalize
correlation $corr_bulk_dens_c_r finalize

correlation $corr_anion_pos finalize
correlation $corr_cation_pos finalize

correlation $corr_anion_xy_lower finalize
correlation $corr_cation_xy_lower finalize

correlation $corr_anion_xy_upper finalize
correlation $corr_cation_xy_upper finalize

correlation $corr_anion_entr_lower finalize
correlation $corr_cation_entr_lower finalize

correlation $corr_anion_entr_upper finalize
correlation $corr_cation_entr_upper finalize


#Bin index to z position
set zlist ""
for {set j 0} {$j < $nbins} {incr j} { lappend zlist [expr 1.0*$box_z/$nbins*$j] }


#########WRITE DENSITIES TO FILES################
# Charge density
set charge_density [vecadd [vecscale $q_c [correlation $corr_cation_pos print average1]] [vecscale $q_a [correlation $corr_anion_pos print average1]]] 
	set out [open "$path/dens_charge.dat" "w"]
		foreach z $zlist c $charge_density { puts $out "[format %.2f $z] $c" }
	close $out 

# Total density
set total_density [vecadd [correlation $corr_cation_pos print average1] [correlation $corr_anion_pos print average1]] 
	set out [open "$path/dens_total.dat" "w"]
		foreach z $zlist c $total_density { puts $out "[format %.2f $z] $c" }
	close $out 

####BULK DENSITY SI (counted)
set out [open "$path/dens_bulk_si.dat" "a"]
	foreach t $time_list dens $bulk_density_list { puts $out "[format %.4f $t] [format %.4f $dens]" }
close $out


####BULK DENSITIES##
set a_den_l [ correlation $corr_bulk_dens_a_l print average1 ]
set c_den_l [ correlation $corr_bulk_dens_c_l print average1 ]
set a_den_r [ correlation $corr_bulk_dens_a_r print average1 ]
set c_den_r [ correlation $corr_bulk_dens_c_r print average1 ]

set a_err_l [ correlation $corr_bulk_dens_a_l print average_errorbars ]
set c_err_l [ correlation $corr_bulk_dens_c_l print average_errorbars ]
set a_err_r [ correlation $corr_bulk_dens_a_r print average_errorbars ]
set c_err_r [ correlation $corr_bulk_dens_c_r print average_errorbars ]


set out [open "$path/dens_bulk_z_l.dat" "w"]
foreach z $list_z_bulk a $a_den_l a_e $a_err_l c $c_den_l c_e $c_err_l { 
	puts $out "[format %.2f $z] $a $a_e $c $c_e" }
close $out
set out [open "$path/dens_bulk_z_r.dat" "w"]
foreach z $list_z_bulk a $a_den_r a_e $a_err_r c $c_den_r c_e $c_err_r { 
	puts $out "[format %.2f $z] $a $a_e $c $c_e" }
close $out

####Z-SLICES##
set a_den [ correlation $corr_anion_pos print average1 ]
set c_den [ correlation $corr_cation_pos print average1 ]

set a_err [ correlation $corr_anion_pos print average_errorbars ] 
set c_err [ correlation $corr_cation_pos print average_errorbars ]

set out [open "$path/dens_z_total_slice_latest.dat" "w"]
foreach z $zlist a $a_den a_e $a_err c $c_den c_e $c_err { 
	puts $out "[format %.2f $z] $a $a_e $c $c_e"}
close $out


####X-SLICES##
#lower
set a_den [ correlation $corr_anion_xy_lower print average1 ]
set c_den [ correlation $corr_cation_xy_lower print average1 ]

set a_err [ correlation $corr_anion_xy_lower print average_errorbars ]
set c_err [ correlation $corr_cation_xy_lower print average_errorbars ]

set out [open "$path/dens_xy_lower_latest.dat" "w"]
foreach x $list_x a $a_den a_e $a_err c $c_den c_e $c_err { 
	puts $out "[format %.2f $x] $a $a_e $c $c_e" }
close $out

#upper
set a_den [ correlation $corr_anion_xy_upper print average1 ]
set c_den [ correlation $corr_cation_xy_upper print average1 ]

set a_err [ correlation $corr_anion_xy_upper print average_errorbars ]
set c_err [ correlation $corr_cation_xy_upper print average_errorbars ]

set out [open "$path/dens_xy_upper_latest.dat" "w"]
foreach x $list_x a $a_den a_e $a_err c $c_den c_e $c_err { 
	puts $out "[format %.2f $x] $a $a_e $c $c_e" }
close $out


###ENTRANCE
#lower
#anion
set dens [ correlation $corr_anion_entr_lower print average1 ]
set out [open "$path/dens_entr_low_a.dat" "w"]
set i 0
foreach x $list_entr_low_x { 
	foreach z $list_entr_low_z {
		puts $out "[format %.2f $x] [format %.2f $z] [lindex $dens $i]"
		incr i 
	}
}
#cation
set dens [ correlation $corr_cation_entr_lower print average1 ]
set out [open "$path/dens_entr_low_c.dat" "w"]
set i 0
foreach x $list_entr_low_x { 
	foreach z $list_entr_low_z {
		puts $out "[format %.2f $x] [format %.2f $z] [lindex $dens $i]"
		incr i 
	}
}
#upper
#anion
set dens [ correlation $corr_anion_entr_upper print average1 ]
set out [open "$path/dens_entr_upp_a.dat" "w"]
set i 0
foreach x $list_entr_upp_x { 
	foreach z $list_entr_upp_z {
		puts $out "[format %.2f $x] [format %.2f $z] [lindex $dens $i]"
		incr i 
	}
}
#cation
set dens [ correlation $corr_cation_entr_upper print average1 ]
set out [open "$path/dens_entr_upp_c.dat" "w"]
set i 0
foreach x $list_entr_upp_x { 
	foreach z $list_entr_upp_z {
		puts $out "[format %.2f $x] [format %.2f $z] [lindex $dens $i]"
		incr i 
	}
}

#write num particles in pores to file
#structure: time anions cations total
	set out [open "$path/pore_part_low.dat" "a"]
		foreach t $time_list anions $pore_lower_anions cations $pore_lower_cations { puts $out "[format %.4f $t] $anions $cations [expr $anions+$cations]" }
	close $out
	set out [open "$path/pore_part_upp.dat" "a"]
		foreach t $time_list anions $pore_upper_anions cations $pore_upper_cations { puts $out "[format %.4f $t] $anions $cations [expr $anions+$cations]" }
	close $out


#Compute ans save RDFs
if {$compute_rdfs == 1} {
	compute_rdf $type_c $type_c 
	compute_rdf $type_a $type_a
}


#Checkpoint particle info
set md_time [setmd time]

set out [open "$path/checkpoint.dat" "w"]
blockfile $out write tclvariable "md_time restarts n_loops"
blockfile $out write particles "pos v f" $anionlist
blockfile $out write particles "pos v f" $cationlist
blockfile $out write particles "q" $icclist
close $out

#Stopwatch total time
set duration [expr ([clock clicks -milliseconds]-$start_time) /1e3]
if {$duration>=3600.0} {
    set total_runtime [format "%.2f hours" [expr {$duration / 3600.0}]]
} elseif {$duration>=60.0} {
    set total_runtime [format "%.2f minutes" [expr {$duration / 60.0}]]
} else {
    set total_runtime [format "%.2f seconds" [expr {$duration}]]
}


#Simulation Output
set out [open "$path/sim_params.dat" "a"]
puts "\n\n"
puts $out "Restarts:         $restarts"
puts $out "Output path:      $path"
puts $out "random seed:      [t_random seed]"
puts $out "int. steps/loop	$n_step"
puts $out "Corr. Taumax: 	 $tauMax"
puts $out "Corr. dt: 		 $sampleTime"
puts $out "N ion pairs:      $n_ion_pairs"
puts $out "Pore width        $pore_w"
puts $out "Gap between pores:        $gap"
puts $out "Pore volume:		 $pore_volume"
puts $out "box x y z:        [format %.2f $box_x] [format %.2f $box_y] [format %.2f $box_z]"
puts $out "Final bulk dens.: [format %.2f $bulk_density]"
puts $out "Bjerrum length:   $l_b"
puts $out "Temperature:      $SI_temperature"
puts $out "Voltage:          $UBat_V V"
puts $out "Number of bins:   $nbins"
puts $out "Wall time:        $hours hours"
puts $out "Runtime:   	     $total_runtime"
puts $out "Sim. times (ns):  [format %.4f $md_time_ns]"
puts $out "Loops:	     $n_loops\n\n"
close $out

#-------------------------
puts "\n--> All done in $total_runtime" ;flush stdout
#-------------------------

