

set NAME  "CDC ELECTRODES + CONSTANT POTENTIAL ICC + EMIBF4 + ACETON"
set startMsg "Starting...$NAME"
set startMsgB [string repeat "#" [string length $startMsg]]
puts "$startMsgB\n$startMsgB\n\n$startMsg\n\n$startMsgB\n$startMsgB"

#---------------------------------------------------------
#--------------------------------INIT--------------------------------
#---------------------------------------------------------

#Stopwatch
set start_time [expr 1.0*[clock clicks -milliseconds]]

#Real runtime
set hours 8
set wall_time [expr $hours*3600.0]

#Seed
for {set i 0} {$i < 24} {incr i} {
   lappend pIDs [pid]
}

t_random seed 
#---------------------------------------------------------
#-------------------------------INPUT--------------------------------
#---------------------------------------------------------

puts "\nArguments: voltage(V) cdcInput_path output_path \[checkpoint\]"

#ARG1: VOLTAGE
set UBat_V [lindex $argv 0]

#ARG2: PATH TO CDC-DATA
#set pathToCDC [lindex $argv 1]

#ARG3: OUTPUT PATH
set path [lindex $argv 1]

#ARG4: PATH TO CHECKPOINT
set useCheckpoint "no"
if {$argc == 4} {
	set useCheckpoint "yes"
	set pathToCheckpoint [lindex $argv 3]
} else {
	set restarts 0
}

#CREATE PATH FOR RUNIDENT
file mkdir $path

#---------------------------------------------------------
#-------------------------------BOX----------------------------------
#---------------------------------------------------------

set box_x 40
set box_y 40
set box_z 130

set gap [expr 0.0*$box_z]
set box_z_tot [expr $gap+$box_z]

setmd box_l $box_x $box_y $box_z_tot
setmd periodic 1 1 1
#cellsystem layered 1
setmd min_global_cut 10

#cellsystem domain_decomposition -no_verlet_list

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
#----------------------------MEASUREMENTS-------------------------------
#---------------------------------------------------------

set nbins 500

#---------------------------------------------------------
#-------------------------------TYPES---------------------------------
#---------------------------------------------------------

set icc_wall_type 0
set c1_type 1
set c2_type 2
set c3_type 3
set com_type 4 
set a_type  5
set wall_type  6

#---------------------------------------------------------
#-------------------------------IONS---------------------------------
#---------------------------------------------------------

#Ion numbers
set n_ion [expr 200]
set n_part [expr 2*$n_ion ]

#---------------------------------------------------------
#------------------------EMI BF4-PARAMETERS--------------------------
#---------------------------------------------------------

set q_c1 0.3591
set q_c2 0.1888
set q_c3 0.2321
set q_a  [expr -0.7800]

set m_c1 67.07
set m_c2 15.04
set m_c3 29.07
set m_ctot [expr $m_c1 + $m_c2 + $m_c3]
set m_a 86.81

set lj_sig_c1 4.38
set lj_sig_c2 3.41
set lj_sig_c3 4.38
set lj_sig_a  4.51

set lj_eps_c1 2.56
set lj_eps_c2 0.36
set lj_eps_c3 1.24
set lj_eps_a  3.241

set c1_x 0
set c2_x 0
set c3_x 0 
set c1_y -0.527
set c2_y 1.641
set c3_y -0.737
set c1_z 1.365
set c2_z 2.987
set c3_z -1.653

#Center of Mass
set c_com_y [expr ($m_c1 * $c1_y + $m_c2 * $c2_y + $m_c3 * $c3_y) / $m_ctot]
set c_com_z [expr ($m_c1 * $c1_z + $m_c2 * $c2_z + $m_c3 * $c3_z) / $m_ctot]
#Shift Coords by COM
set c1_y [expr $c1_y - $c_com_y]
set c2_y [expr $c2_y - $c_com_y]
set c3_y [expr $c3_y - $c_com_y]
set c1_z [expr $c1_z - $c_com_z]
set c2_z [expr $c2_z - $c_com_z]
set c3_z [expr $c3_z - $c_com_z]

#Rotate Coords to diagonalize intertia tensor
set a 0.353110151
set c1_yn [expr $c1_y * cos($a) - $c1_z * sin($a)]
set c1_z [expr $c1_z * cos($a) + $c1_y * sin($a)]
set c1_y $c1_yn
set c2_yn [expr $c2_y * cos($a) - $c2_z * sin($a)]
set c2_z [expr $c2_z * cos($a) + $c2_y * sin($a)]
set c2_y $c2_yn
set c3_yn [expr $c3_y * cos($a) - $c3_z * sin($a)]
set c3_z [expr $c3_z * cos($a) + $c3_y * sin($a)]
set c3_y $c3_yn

#Calc diag. inertia elements
set cat_inertia_xx [expr $m_c1 * (pow($c1_y,2)+pow($c1_z,2)) + $m_c2 * (pow($c2_y,2)+pow($c2_z,2)) + $m_c3 * (pow($c3_y,2)+pow($c3_z,2)) ] 
set cat_inertia_yy [expr $m_c1 * (pow($c1_x,2)+pow($c1_z,2)) + $m_c2 * (pow($c2_x,2)+pow($c2_z,2)) + $m_c3 * (pow($c3_x,2)+pow($c3_z,2)) ] 
set cat_inertia_zz [expr $m_c1 * (pow($c1_x,2)+pow($c1_y,2)) + $m_c2 * (pow($c2_x,2)+pow($c2_y,2)) + $m_c3 * (pow($c3_x,2)+pow($c3_y,2)) ] 

#puts "Com_y = [expr ($m_c1 * $c1_y + $m_c2 * $c2_y + $m_c3 * $c3_y) / $m_ctot]"
#puts "Com_z = [expr ($m_c1 * $c1_z + $m_c2 * $c2_z + $m_c3 * $c3_z) / $m_ctot]"
#puts "J_yz  = [expr $m_c1 * $c1_y * $c1_z + $m_c2 * $c2_y * $c2_z + $m_c3 * $c3_y * $c3_z]" 
#puts "J_xx  = $cat_inertia_xx"
#puts "J_yy  = $cat_inertia_yy"
#puts "J_zz  = $cat_inertia_zz"
#puts "New Coords:\n0 $c1_y $c1_z\n0 $c2_y $c2_z\n0 $c3_y $c3_z"

#---------------------------------------------------------
#------------------------------CARBON-------------------------------
#---------------------------------------------------------

set lj_sig_w  3.37
set lj_eps_w  0.23
set m_carbon 12.0

#---------------------------------------------------------
#---------------------------MIXING RULES----------------------------
#---------------------------------------------------------

set lj_sig_mix_c1_c2 [expr 0.5*($lj_sig_c1+$lj_sig_c2)]
set lj_sig_mix_c1_c3 [expr 0.5*($lj_sig_c1+$lj_sig_c3)]
set lj_sig_mix_c1_a [expr 0.5*($lj_sig_c1+$lj_sig_a)]
set lj_sig_mix_c1_w [expr 0.5*($lj_sig_c1+$lj_sig_w)]
set lj_sig_mix_c2_c3 [expr 0.5*($lj_sig_c2+$lj_sig_c3)]
set lj_sig_mix_c2_a [expr 0.5*($lj_sig_c2+$lj_sig_a)]
set lj_sig_mix_c2_w [expr 0.5*($lj_sig_c2+$lj_sig_w)]
set lj_sig_mix_c3_a [expr 0.5*($lj_sig_c3+$lj_sig_a)]
set lj_sig_mix_c3_w [expr 0.5*($lj_sig_c3+$lj_sig_w)]
set lj_sig_mix_a_w  [expr 0.5*($lj_sig_a+$lj_sig_w)]

set lj_eps_mix_c1_c2 [expr sqrt($lj_eps_c1*$lj_eps_c2)]
set lj_eps_mix_c1_c3 [expr sqrt($lj_eps_c1*$lj_eps_c3)]
set lj_eps_mix_c1_a [expr sqrt($lj_eps_c1*$lj_eps_a)]
set lj_eps_mix_c1_w [expr sqrt($lj_eps_c1*$lj_eps_w)]
set lj_eps_mix_c2_c3 [expr sqrt($lj_eps_c2*$lj_eps_c3)]
set lj_eps_mix_c2_a [expr sqrt($lj_eps_c2*$lj_eps_a)]
set lj_eps_mix_c2_w [expr sqrt($lj_eps_c2*$lj_eps_w)]
set lj_eps_mix_c3_a [expr sqrt($lj_eps_c3*$lj_eps_a)]
set lj_eps_mix_c3_w [expr sqrt($lj_eps_c3*$lj_eps_w)]
set lj_eps_mix_a_w [expr sqrt($lj_eps_a*$lj_eps_w)]

#---------------------------------------------------------
#-------------------------SYSTEM INFO--------------------------------
#---------------------------------------------------------

puts "\nOutput path:          $path"
puts "Timestep (fs):          $time_step_fs"
puts "Timestep (internal):    $time_step"
puts "Voltage (V):            $UBat_V"
puts "Number of ion pairs:    $n_ion"
puts "box x y z (A):          [format %.2f $box_x] [format %.2f $box_y] [format %.2f [expr $box_z+$gap]]"
puts "Bjerrum length (A):     $l_b"
puts "Temperature (K):        $SI_temperature"
puts "Output Path:            $path"
puts "Wall time:              $hours hours"
puts "Random seed:            [t_random seed]"

#---------------------------------------------------------
#-------------------------MESH WALLS------------------------------
#---------------------------------------------------------
global icc_areas icc_normals icc_epsilons icc_sigmas

set UBat [expr $UBat_V/0.01036427]

set stl_files [list "/home/konrad/git/md-sim/espresso/Upore/left_electrode.stl" "/home/konrad/git/md-sim/espresso/Upore/right_electrode.stl"]
set pots [list 0 $UBat]
set types [list $icc_wall_type $icc_wall_type]
#set bins [list 100 100 150]
set bins [list 80 80 260]
#puts [meshToParticles [lindex $stl_files 0] 0 [lindex $types 0]]
#puts [meshToParticles [lindex $stl_files 1] [setmd n_part] [lindex $types 1]]
puts [mesh_capacitor_icc 0 $stl_files $pots $types $bins] 

set iccParticles [setmd n_part]
set iccParticlesLeft 1616 
# [expr int($iccParticles/2)]

for {set i 0} {$i < $iccParticles} {incr i} { 
	lappend icclist $i
}
#WRITE SEPERATE STRUCTURE+COORDS FOR ICC PARTICLES ON FIRST RUN
#if {$useCheckpoint == "no" } {
#	set obs_traj_icc [open "$path/trajectory_ICC.vtf" "w"]
#	puts "->Writing ICC structure data to $path/trajectory_ICC.vtf"
#	writevsf $obs_traj_icc short radius [list 0 [expr $lj_sig_w*0.5]] typedesc {0 "name ICC type 0"}
#	writevcf $obs_traj_icc short folded
#	close $obj_traj_icc
#}

#puts "Load External Potential"
#external_potential tabulated file "externalPotential.dat" scale [list 0 $q_c1 $q_c2 $q_c3 0 $q_a]
#external_potential tabulated file "externalPotential.dat" scale [list 0 0 0 0 0 0]


#---------------------------------------------------------
#---------------------------BORDERS----------------------------------
#---------------------------------------------------------

#constraint wall normal 0 0 1 dist 0 type $wall_type
#constraint wall normal 0 0 -1 dist [expr -$box_z] type $wall_type

#---------------------------------------------------------
#-------------------------CREATE IONS---------------------------------
#---------------------------------------------------------

set ionlist ""
set anionlist ""
set cationComlist ""
set cationlist ""
set oriList ""

set partSpawnL 52
set partSpawnR 74
set partSpawnW [expr $partSpawnR-$partSpawnL]

#ANIONS
for {set i $iccParticles} { $i < [expr $n_ion + $iccParticles] } {incr i} {
    set posx [expr $box_x*[t_random]]
    set posy [expr $box_y*[t_random]]
    set posz [expr $partSpawnW*[t_random]+$partSpawnL]

    part $i pos $posx $posy $posz q $q_a type $a_type mass $m_a
    lappend anionlist $i
    lappend ionlist $i
}

#CATIONS	
for {set j $i} { $j < [expr 5*$n_ion + $iccParticles] } {incr j 4} {
    set posx [expr $box_x*[t_random]]
    set posy [expr $box_y*[t_random]]
    set posz [expr $partSpawnW*[t_random]+$partSpawnL]
    
    part $j pos $posx $posy $posz type $com_type rinertia $cat_inertia_xx $cat_inertia_yy $cat_inertia_zz mass $m_ctot omega [expr 2*[t_random]-1] [expr 2*[t_random]-1] [expr 2*[t_random]-1]
    part [expr $j +1] pos $posx [expr $posy + $c1_y] [expr $posz + $c1_z] type $c1_type virtual 1 q $q_c1 vs_auto_relate_to $j vs_relative $j [expr sqrt(pow($c1_y,2)+pow($c1_z,2))] 
    part [expr $j +2] pos $posx [expr $posy + $c2_y] [expr $posz + $c2_z] type $c2_type virtual 1 q $q_c2 vs_auto_relate_to $j vs_relative $j [expr sqrt(pow($c2_y,2)+pow($c2_z,2))] 
    part [expr $j +3] pos $posx [expr $posy + $c3_y] [expr $posz + $c3_z] type $c3_type virtual 1 q $q_c3 vs_auto_relate_to $j vs_relative $j [expr sqrt(pow($c3_y,2)+pow($c3_z,2))]
    
    lappend oriList $j [expr $j+1] [expr $j+2] [expr $j+3]
    lappend cationComlist $j
    lappend cationlist [expr $j+1]
    lappend cationlist [expr $j+2]
    lappend cationlist [expr $j+3]
    lappend ionlist $j
    lappend ionlist [expr $j+1]
    lappend ionlist [expr $j+2]
    lappend ionlist [expr $j+3]
}

#set f [open "vmd.vsf" "w"]
#writevsf $f 
#close $f
#prepare_vmd_connection vmdout 10000
imd positions

if {$useCheckpoint == "no"} {

	#---------------------------------------------------------
	puts "--> LJ WARM UP"
	#---------------------------------------------------------

	setmd time_step 0.01

	inter $c3_type $icc_wall_type lennard-jones $lj_eps_mix_c3_w $lj_sig_mix_c3_w [expr 2.0*$lj_sig_mix_c3_w] 0.004 0 0
	inter $c1_type $icc_wall_type lennard-jones $lj_eps_mix_c1_w $lj_sig_mix_c1_w [expr 2.0*$lj_sig_mix_c1_w] 0.004 0 0
	inter $c2_type $icc_wall_type lennard-jones $lj_eps_mix_c2_w $lj_sig_mix_c2_w [expr 2.0*$lj_sig_mix_c2_w] 0.004 0 0
	inter $a_type $icc_wall_type lennard-jones $lj_eps_mix_a_w $lj_sig_mix_a_w [expr 2.0*$lj_sig_mix_a_w] 0.004 0 0 
	
	inter forcecap "individual"

	set twop16 [expr pow(2.0,1.0/6.0)]
	set cut 0.2
	set size 0.01
	set E_o 0
	thermostat langevin 1 50
	while {1} {
        
		
		#inter $c1_type $c1_type lennard-jones $lj_eps_c1 $lj_sig_c1 [expr 2.5*$lj_sig_c1] 0.004 0 [expr $cut*$lj_sig_c1] 
		#inter $c1_type $c2_type lennard-jones $lj_eps_mix_c1_c2 $lj_sig_mix_c1_c2 [expr 2.5*$lj_sig_mix_c1_c2] 0.004 0 [expr $cut*$lj_sig_mix_c1_c2]
		#inter $c1_type $c3_type lennard-jones $lj_eps_mix_c1_c3 $lj_sig_mix_c1_c3  [expr 2.5*$lj_sig_mix_c1_c3] 0.004 0 [expr $cut*$lj_sig_mix_c1_c3]
		#inter $c1_type $a_type lennard-jones $lj_eps_mix_c1_a $lj_sig_mix_c1_a [expr 2.5*$lj_sig_mix_c1_a] 0.004 0 [expr $cut*$lj_sig_mix_c1_a]
		#inter $c2_type $c2_type lennard-jones $lj_eps_c2 $lj_sig_c2 [expr 2.5*$lj_sig_c2] 0.004 0 [expr $cut*$lj_sig_c2]
		#inter $c2_type $c3_type lennard-jones $lj_eps_mix_c2_c3 $lj_sig_mix_c2_c3 [expr 2.5*$lj_sig_mix_c2_c3] 0.004 0 [expr $cut*$lj_sig_mix_c2_c3]
		#inter $c2_type $a_type lennard-jones $lj_eps_mix_c2_a $lj_sig_mix_c2_a [expr 2.5*$lj_sig_mix_c2_a] 0.004 0 [expr $cut*$lj_sig_mix_c2_a]
		#inter $c3_type $c3_type lennard-jones $lj_eps_c3 $lj_sig_c3 [expr 2.5*$lj_sig_c3] 0.004 0 [expr $cut*$lj_sig_c3]
		#inter $c3_type $a_type lennard-jones $lj_eps_mix_c3_a $lj_sig_mix_c3_a [expr 2.5*$lj_sig_mix_c3_a] 0.004 0 [expr $cut*$lj_sig_mix_c3_a]
		#inter $a_type $a_type lennard-jones $lj_eps_a $lj_sig_a [expr 2.5*$lj_sig_a] 0.004 0 [expr $cut*$lj_sig_a]
		inter $c1_type $c1_type lennard-jones $lj_eps_c1 [expr $size * $lj_sig_c1] [expr 2.0*$lj_sig_c1] 0.004 0 [expr $cut*$lj_sig_c1*$twop16] 
		inter $c1_type $c2_type lennard-jones $lj_eps_mix_c1_c2 [expr $size * $lj_sig_mix_c1_c2] [expr 2.0*$lj_sig_mix_c1_c2] 0.004 0 [expr $cut*$lj_sig_mix_c1_c2*$twop16]
		inter $c1_type $c3_type lennard-jones $lj_eps_mix_c1_c3 [expr $size * $lj_sig_mix_c1_c3]  [expr 2.0*$lj_sig_mix_c1_c3] 0.004 0 [expr $cut*$lj_sig_mix_c1_c3*$twop16]
		inter $c1_type $a_type lennard-jones $lj_eps_mix_c1_a [expr $size * $lj_sig_mix_c1_a] [expr 2.0*$lj_sig_mix_c1_a] 0.004 0 [expr $cut*$lj_sig_mix_c1_a*$twop16]
		inter $c2_type $c2_type lennard-jones $lj_eps_c2 [expr $size * $lj_sig_c2] [expr 2.0*$lj_sig_c2] 0.004 0 [expr $cut*$lj_sig_c2*$twop16]
		inter $c2_type $c3_type lennard-jones $lj_eps_mix_c2_c3 [expr $size * $lj_sig_mix_c2_c3] [expr 2.0*$lj_sig_mix_c2_c3] 0.004 0 [expr $cut*$lj_sig_mix_c2_c3*$twop16]
		inter $c2_type $a_type lennard-jones $lj_eps_mix_c2_a [expr $size * $lj_sig_mix_c2_a] [expr 2.0*$lj_sig_mix_c2_a] 0.004 0 [expr $cut*$lj_sig_mix_c2_a*$twop16]
		inter $c3_type $c3_type lennard-jones $lj_eps_c3 [expr $size * $lj_sig_c3] [expr 2.0*$lj_sig_c3] 0.004 0 [expr $cut*$lj_sig_c3*$twop16]
		inter $c3_type $a_type lennard-jones $lj_eps_mix_c3_a [expr $size * $lj_sig_mix_c3_a] [expr 2.0*$lj_sig_mix_c3_a] 0.004 0 [expr $cut*$lj_sig_mix_c3_a*$twop16]
		inter $a_type $a_type lennard-jones $lj_eps_a [expr $size * $lj_sig_a] [expr 2.0*$lj_sig_a] 0.004 0 [expr $cut*$lj_sig_a*$twop16]
	       


		if {$E_o == 0} {
		    integrate 1
		    set E_o [analyze energy total]
		}

		integrate 10
		imd positions
		set E [analyze energy total]
			set dE [expr $E-$E_o]
		set E_o $E
		if {[expr abs($dE)] < 7000} {
		    if {$size < 1} {
			set size [expr $size + 0.1]
			if {$size > 1} {set size 1}
		    } else {
			set cut [expr $cut - 0.05]
			if {$cut < 0} {break}
		    }
		}

		#set cutDecr [expr 0.2*$cutDecr + 0.8*(1.0-1000.0/(1000+abs($dE)))]
		puts "t=[setmd time] E=$E dE=$dE size=$size cut=$cut"; flush stdout
	}
	thermostat langevin $temperature $gamma
	inter forcecap 0

	setmd time_step $time_step
}


inter $c3_type $icc_wall_type lennard-jones $lj_eps_mix_c3_w $lj_sig_mix_c3_w [expr 2.0*$lj_sig_mix_c3_w] 0.004 0 0
inter $c1_type $icc_wall_type lennard-jones $lj_eps_mix_c1_w $lj_sig_mix_c1_w [expr 2.0*$lj_sig_mix_c1_w] 0.004 0 0
inter $c2_type $icc_wall_type lennard-jones $lj_eps_mix_c2_w $lj_sig_mix_c2_w [expr 2.0*$lj_sig_mix_c2_w] 0.004 0 0
inter $a_type $icc_wall_type lennard-jones $lj_eps_mix_a_w $lj_sig_mix_a_w [expr 2.0*$lj_sig_mix_a_w] 0.004 0 0 
inter $c1_type $c1_type lennard-jones $lj_eps_c1 $lj_sig_c1 [expr 2.0*$lj_sig_c1] 0.004 0 0
inter $c1_type $c2_type lennard-jones $lj_eps_mix_c1_c2 $lj_sig_mix_c1_c2 [expr 2.0*$lj_sig_mix_c1_c2] 0.004 0 0
inter $c1_type $c3_type lennard-jones $lj_eps_mix_c1_c3 $lj_sig_mix_c1_c3  [expr 2.0*$lj_sig_mix_c1_c3] 0.004 0 0
inter $c1_type $a_type lennard-jones $lj_eps_mix_c1_a $lj_sig_mix_c1_a [expr 2.0*$lj_sig_mix_c1_a] 0.004 0 0
inter $c2_type $c2_type lennard-jones $lj_eps_c2 $lj_sig_c2 [expr 2.0*$lj_sig_c2] 0.004 0 0
inter $c2_type $c3_type lennard-jones $lj_eps_mix_c2_c3 $lj_sig_mix_c2_c3 [expr 2.0*$lj_sig_mix_c2_c3] 0.004 0 0
inter $c2_type $a_type lennard-jones $lj_eps_mix_c2_a $lj_sig_mix_c2_a [expr 2.0*$lj_sig_mix_c2_a] 0.004 0 0
inter $c3_type $c3_type lennard-jones $lj_eps_c3 $lj_sig_c3 [expr 2.0*$lj_sig_c3] 0.004 0 0
inter $c3_type $a_type lennard-jones $lj_eps_mix_c3_a $lj_sig_mix_c3_a [expr 2.0*$lj_sig_mix_c3_a] 0.004 0 0
inter $a_type $a_type lennard-jones $lj_eps_a $lj_sig_a [expr 2.0*$lj_sig_a] 0.004 0 0


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
	
	setmd time $md_time
	incr restarts 
	#integrate 0
	puts "Restart NR: $restarts at [expr $time_scale*$md_time] ns"

} else {
	
	#-----------------------
	puts "\n--> Fill Pores"
	#-----------------------
	set n_steps_t 1
	setmd time_step 0.01
 	set fillTemp 75000
 	thermostat langevin [expr $fillTemp*$kb_kjmol] $gamma
 	puts "Pore filling at $fillTemp K"
	for {set temp_eq_loop 0} {$temp_eq_loop<20} {incr temp_eq_loop} {
		integrate $n_steps_t
		puts "$temp_eq_loop / 20"
		imd positions
	}
	
	#-----------------------
	puts "\n--> Cool down"
	#-----------------------

	setmd time_step 0.01
	for {set curr_temp $fillTemp} {$curr_temp >= 400} {set curr_temp [expr $curr_temp- ($fillTemp - 401.0) / 4.0]} {
		thermostat langevin [expr $curr_temp*$kb_kjmol] $gamma
		puts "Temp. equi. at $curr_temp K"
		for {set temp_eq_loop 0} {$temp_eq_loop<10} {incr temp_eq_loop} {
			integrate $n_steps_t
			puts "$temp_eq_loop / 10"
			imd positions
		}
	}
	setmd time_step $time_step
	thermostat langevin $temperature $gamma

	#-----------------------
	puts "\n--> Electrostatics Equilibration"
	#-----------------------

	#puts [inter coulomb $l_b p3m tunev2 accuracy 1e-3]
	
	setmd time_step 0.001
	for {set i 0} {$i < 10} {incr i} {
	   	integrate $n_steps_t
	   	imd positions
       		puts "$i/10"
	}
	setmd time_step $time_step

	#-----------------------
	#puts "--> Writing initial checkpoint"
	#-----------------------
	set md_time 0
	setmd time 0

	#set out [open "$path/initial_checkpoint.dat" "w"]
	#blockfile $out write tclvariable "md_time restarts"
	#blockfile $out write particles "pos v f" $anionlist
	#blockfile $out write particles "pos quat v f" $cationComlist
	#blockfile $out write particles "pos v f" $cationlist
	#close $out
}

#-----------------------
puts "\n--> Electrostatics"
#-----------------------

#USE SMALL RND START CHARGE FOR ICC PARTICLES
#for {set i 0} {$i < $iccParticles} {incr i} {
#   part $i q [ expr 0.1*([ t_random ]-0.5) ]
#}

puts "Tune P3M"
puts [inter coulomb $l_b p3m tunev2 accuracy 1e-3]

#external_potential tabulated file "externalPotential.dat" scale [list 0 0.001 0.001 0.001 0 -0.001]

puts "Load External Potential"
external_potential tabulated file "externalPotential.dat" scale [list 0 $q_c1 $q_c2 $q_c3 0 $q_a]

puts "Switch on ICC"
puts [iccp3m $iccParticles epsilons $icc_epsilons normals $icc_normals areas $icc_areas sigmas $icc_sigmas ext_field 0.0 0.0 0.0 eps_out 1.0 relax 0.7 max_iterations 100 convergence 1e-4]

#-----------------------
puts "-->Init observables"
#-----------------------

set obs_anion_pos_id [observable new density_profile type [list $a_type] minx 0 maxx $box_x xbins 1 miny 0 maxy $box_y ybins 1 minz 0 maxz $box_z zbins $nbins]
set obs_cation_pos_id [observable new density_profile type [list $com_type] minx 0 maxx $box_x xbins 1 miny 0 maxy $box_y ybins 1 minz 0 maxz $box_z zbins $nbins]
set obs_cation_c1_id [observable new density_profile type [list $c1_type] minx 0 maxx $box_x xbins 1 maxy $box_y ybins 1 minz 0 maxz $box_z zbins $nbins]
set obs_cation_c2_id [observable new density_profile type [list $c2_type] minx 0 maxx $box_x xbins 1 maxy $box_y ybins 1 minz 0 maxz $box_z zbins $nbins]
set obs_cation_c3_id [observable new density_profile type [list $c3_type] minx 0 maxx $box_x xbins 1 maxy $box_y ybins 1 minz 0 maxz $box_z zbins $nbins]

set sampleTime [expr 3*$time_step]
set tauMax [expr 2*$sampleTime]
set corr_anion_pos_id [correlation new obs1 $obs_anion_pos_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_cation_pos_id [correlation new obs1 $obs_cation_pos_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_cation_c1_id [correlation new obs1 $obs_cation_c1_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_cation_c2_id [correlation new obs1 $obs_cation_c2_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
set corr_cation_c3_id [correlation new obs1 $obs_cation_c3_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]

if {$useCheckpoint =="yes"} {
	puts "\n-->Read correlator checkpoint"
	correlation $corr_anion_pos_id read_checkpoint_binary "$path/corr_anion.bin"
	correlation $corr_cation_pos_id read_checkpoint_binary "$path/corr_cation_com.bin"
	correlation $corr_cation_c1_id read_checkpoint_binary "$path/corr_cation_c1.bin"
	correlation $corr_cation_c2_id read_checkpoint_binary "$path/corr_cation_c2.bin"
	correlation $corr_cation_c3_id read_checkpoint_binary "$path/corr_cation_c3.bin"
}

correlation $corr_anion_pos_id autoupdate start
correlation $corr_cation_pos_id autoupdate start
correlation $corr_cation_c1_id autoupdate start
correlation $corr_cation_c2_id autoupdate start
correlation $corr_cation_c3_id autoupdate start

set obs_schargeL [open "$path/s_charge_L.dat" "w"]
set obs_schargeR [open "$path/s_charge_R.dat" "w"]
set obs_schargeL_t [open "$path/s_charge_t_all_L.dat" "w"]
set obs_schargeR_t [open "$path/s_charge_t_all_R.dat" "w"]
set obs_traj [open "$path/trajectory.vtf" "w"]
set obs_energy [open "$path/energy.dat" "w"]

#Write structure+icc coords on first run 
if {$useCheckpoint == "no" } {
	puts "\n-->Writing structure data to $path/trajectory.vtf"
	writevsf $obs_traj short radius [list 0 [expr $lj_sig_w*0.5] 1 auto 2 auto 3 auto 4 auto 5 auto] typedesc {0 "name ICC type 0" 1 "name EMIM_C1_IM type 1" 2 "name EMIM_C2_ME type 2" 3 "name EMIM_C3_ET type 3" 4 "name EMIM_COM type 4" 5 "name BF4 type 5"}
	writevcf $obs_traj short folded pids $icclist
}

#-----------------------
puts "\n-->Starting integration"
#-----------------------

set n_step 25

while {1} {

	imd positions
	
	#Trajectory IONS
	puts "Write trajectory"
	writevcf $obs_traj short folded pids $ionlist

	#Integrate
	puts "Integrate $n_step"
	integrate $n_step

	#Measurements
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
	puts "Charge left $cl"
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
	puts "Charge right $cr"
	puts $obs_schargeR_t $charges

	puts $obs_energy [analyze energy]

	#Timing
	set curr_duration [expr (1.0*[clock clicks -milliseconds]-$start_time)/1e3]
	puts "Simtime: [format %.6f $md_time_ns] ns ([format %.2f [expr $curr_duration/$wall_time*100.0]] %)"; flush stdout  

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

#Checkpoint correlator
correlation $corr_anion_pos_id write_checkpoint_binary "$path/corr_anion.bin" 
correlation $corr_cation_pos_id write_checkpoint_binary "$path/corr_cation_com.bin"
correlation $corr_cation_c1_id write_checkpoint_binary "$path/corr_cation_c1.bin"
correlation $corr_cation_c2_id write_checkpoint_binary "$path/corr_cation_c2.bin"
correlation $corr_cation_c3_id write_checkpoint_binary "$path/corr_cation_c3.bin"

#Finalize correlator
correlation $corr_anion_pos_id finalize
correlation $corr_cation_pos_id finalize
correlation $corr_cation_c1_id finalize
correlation $corr_cation_c2_id finalize
correlation $corr_cation_c3_id finalize

#Bin index to z position
set zlist ""
for {set j 0} {$j < $nbins} {incr j} { lappend zlist [expr 1.0*$box_z/$nbins*$j] }

##### Charge density
set charge_density [vecadd [vecadd [vecscale $q_c1 [correlation $corr_cation_c1_id print average1]] [vecscale $q_c2 [correlation $corr_cation_c2_id print average1]]] [vecadd [vecscale $q_c3 [correlation $corr_cation_c3_id print average1]] [vecscale $q_a [correlation $corr_anion_pos_id print average1]]]] 
##### Total density
set total_density [vecadd [vecadd [vecadd [correlation $corr_cation_c1_id print average1] [correlation $corr_cation_c2_id print average1]] [correlation $corr_cation_c3_id print average1]] [correlation $corr_anion_pos_id print average1]] 
##### Anion density
set anion_den [ correlation $corr_anion_pos_id print average1 ]
set anion_den_err [ correlation $corr_anion_pos_id print average_errorbars ] 
#CationCom density
set cation_den [ correlation $corr_cation_pos_id print average1 ]
set err [ correlation $corr_cation_pos_id print average_errorbars ]
#CationC1 densitcom
set cation_den_c1 [ correlation $corr_cation_c1_id print average1 ]
set err [ correlation $corr_cation_c1_id print average_errorbars ]
#CationC2 density
set cation_den_c2 [ correlation $corr_cation_c2_id print average1 ]
set err [ correlation $corr_cation_c2_id print average_errorbars ]
#CationC3 density
set cation_den_c3 [ correlation $corr_cation_c3_id print average1 ]
set err [ correlation $corr_cation_c3_id print average_errorbars ]

#if {$useCheckpoint=="yes"} {
#
#	proc averageAppend afile aColumn {
#		set infile [open "$afile" "r"]
#		set file_data [read $infile]
#		close $infile
#
#		set data [split $file_data "\n"]
#		set cdc_coords ""
#		set cdc_maxz 0
#		foreach line $data {
#		    if {$line != ""} {
#			set c [join $line " "] 
#			set cz [lindex $c 2]
#			lappend cdc_coords $c
#			if {$cdc_maxz < $cz} {
#			    set cdc_maxz $cz
#			}
#		    }
#		}
#	}
#
#} else {

	#set err [vecadd [vecadd [vecscale $q_c1 [correlation $corr_cation_c1_id print average_errorbars]] [vecscale $q_c2 [correlation $corr_cation_c2_id print average_errorbars]]] [vecadd [vecscale $q_c3 [correlation $corr_cation_c3_id print average_errorbars]] [vecscale $q_a [correlation $corr_anion_pos_id print average_errorbars]]]] 
	set out [open "$path/charge_dens.dat" "w"]
		foreach z $zlist c $charge_density { puts $out "$z $c" }
	close $out 
	set out [open "$path/total_dens.dat" "w"]
		foreach z $zlist c $total_density { puts $out "$z $c" }
	close $out 
	set out [open "$path/anion_dens.dat" "w"]
		foreach z $zlist c $anion_den e $err { puts $out "$z $c $e" }
	close $out
	set out [open "$path/cation_dens_com.dat" "w"]
		foreach z $zlist c $cation_den e $err { puts $out "$z $c $e" }
	close $out
	set out [open "$path/cation_dens_c1.dat" "w"]
		foreach z $zlist c $cation_den_c1 e $err { puts $out "$z $c $e" }
	close $out
	set out [open "$path/cation_dens_c2.dat" "w"]
		foreach z $zlist c $cation_den_c2 e $err { puts $out "$z $c $e" }
	close $out
	set out [open "$path/cation_dens_c3.dat" "w"]
		foreach z $zlist c $cation_den_c3 e $err { puts $out "$z $c $e" }
	close $out
#}

#Checkpoint particle info
set md_time [setmd time]

set out [open "$path/checkpoint_r_$restarts.dat" "w"]
blockfile $out write tclvariable "md_time restarts"
blockfile $out write particles "pos v f" $anionlist
blockfile $out write particles "pos quat v f" $cationComlist
blockfile $out write particles "pos v f" $cationlist
close $out

#Stopwach total time
set duration [expr ([clock clicks -milliseconds]-$start_time) /1e3]
if {$duration>=3600.0} {
    set total_runtime [format "%.2f hours" [expr {$duration / 3600.0}]]
} elseif {$duration>=60.0} {
    set total_runtime [format "%.2f minutes" [expr {$duration / 60.0}]]
} else {
    set total_runtime [format "%.2f seconds" [expr {$duration}]]
}

#Simulation Output
set out [open "$path/sim_params.dat" "w"]
puts $out "Restarts:         $restarts"
puts $out "Output path:      $path"
puts $out "random seed:      [t_random seed]"
puts $out "N ion pairs:      $n_ion"
puts $out "box x y z:        [format %.2f $box_x] [format %.2f $box_y] [format %.2f $box_z]\n"
puts $out "Gap:              $gap"
puts $out "Bjerrum length:   $l_b"
puts $out "Temperature:      $SI_temperature"
puts $out "Voltage:          [lindex $argv 0] V"
puts $out "Number of bins:   $nbins"
puts $out "Wall time:        $hours hours"
puts $out "Runtime:   	     $total_runtime"
puts $out "Sim. times (ns):  $md_time_ns"
close $out

#-------------------------
puts "\n--> All done in $total_runtime" ;flush stdout
#-------------------------

