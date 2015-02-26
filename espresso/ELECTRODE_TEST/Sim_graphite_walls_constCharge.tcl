#Simulation of [BMIM][PF6] with ICC graphite walls in ESPResSo

#Units
# Simulation Unit [1]		Physical Unit
# Length             		1*10^(-10) m (Angstrom)
# Mass				gramm/mol
# Energy			kJ/mol
# Time 				1*10^(-13) s
# charge			1*e (elementary charge)

puts ""
puts "==========================================================="
puts "Simulation of BMIM-PF_6 with ICC graphite walls in ESPResSo"
puts "==========================================================="
puts "ESPResSo code base:  [code_info]"
puts ""

#Stopwatch
set start_time [expr 1.0*[clock clicks -milliseconds]]

#Real runtime
set hours 23.5

set wall_time [expr $hours*3600.0]

#Seed
t_random seed [pid] [pid] [pid] [pid] [pid] [pid] [pid] [pid]

#Input args

set charge_dens [expr [lindex $argv 0]]
set epsilon_0 5.728e-5
set external_force [expr $charge_dens/($epsilon_0)]

set run_ident [lindex $argv 1]

set useCheckpoint "no"
if {$argc == 3} {
	set useCheckpoint "yes"
	set pathToCheckpoint [lindex $argv 2]
} 

#Paths
set path ${run_ident}
file mkdir $path

#Ion numbers
set n_ion [expr 320]
set n_part [expr 2*$n_ion ]

#Physical constants
set N_A 6.022141e23
#(kJ * Angstrom) / ((elementary charge)^2 * N_A)
set epsilon_0 5.728e-5

#System parameters
set CCbondlength 1.43
set graphenePPDist 3.35
set graphenePPDist2 [expr 2.0*$graphenePPDist]

#BMIM PF6 Parameters
# 2.21e-4 m^3/mol at 400K = 2.21e26 A^3/mol
set molarVolume 2.21e26 
# [g/mol]
set molarMass 284.19 
# [mol/A^3]
set molarConcentration [expr 1.0 / $molarVolume] 
# [A^3]
set volumePerParticlePair [expr $molarVolume/$N_A] 
# [g/cm^3]
set density [expr $molarMass/$molarVolume*1e-6] 
# [1/A^3]
set numberDensity [expr $molarConcentration*$N_A]


#Box sizes
set volume_bulk [expr $n_ion*$volumePerParticlePair]

#Wall effects reduce bulk density -> fudge box_h (wall effect scales with box_h) to get correct bulk density
#set non_cube_ratio 4.0
#set box_ht [expr pow($volume_bulk/$non_cube_ratio,1.0/3.0)]
set box_x 27.2
set box_y 30.0
set box_l [expr 147.83]
set electrode_area [expr $box_x*$box_y]
#Define box length from (inner) wall to wall 
#set box_l [expr ($box_x+$box_y)*0.5*$non_cube_ratio]

#Security gap
set gap [expr 0.15*$box_l]
set volume_sim [expr $box_l*$box_x*$box_y]  
#Define total box length from (outer) wall to wall 
set tot_l [expr $box_l+4.0*$graphenePPDist]
#Particles are expected to be found from...
set partBorderL $graphenePPDist2
#...till...
set partBorderR [expr $graphenePPDist2+$box_l]

set tot_box_l [expr $gap+$tot_l]
setmd box_l $box_x $box_y $tot_box_l


#Interaction parameters
set lj_sig_c1 4.38
set lj_sig_c2 3.41
set lj_sig_c3 5.04
set lj_sig_a  5.06
set lj_sig_w  3.37

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

set sig_mean [expr ($lj_sig_mix_c1_c2+$lj_sig_mix_c1_c3+$lj_sig_mix_c1_a+$lj_sig_mix_c1_w+$lj_sig_mix_c2_c3+$lj_sig_mix_c2_a+$lj_sig_mix_c2_w+$lj_sig_mix_c3_a+$lj_sig_mix_c3_w+$lj_sig_mix_a_w)/10]

set lj_eps_c1 2.56
set lj_eps_c2 0.36
set lj_eps_c3 1.83
set lj_eps_a  4.71
set lj_eps_w  0.23

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

set q_c1 0.4374
set q_c2 0.1578
set q_c3 0.1848
set q_a  [expr -0.7800]

set m_c1 67.07
set m_c2 15.04
set m_c3 57.12
set m_a 144.96

#Thermostat / Verlet parameters
set kb_kjmol 0.0083145
set SI_temperature 400.0
set temperature [expr $SI_temperature*$kb_kjmol]
set gamma       1.0
set skin	0.4
set time_step   0.1

#in s
set timescale [expr 1.0/sqrt(2.0)*1e-13] 

#Histogram precision
set nbins [expr 5*round($box_l/(0.1*$sig_mean))]

#Types
set icc_wall_type 0
set c1_type 1
set c2_type 2
set c3_type 3
set a_type  4
set non_virtual_type 5 
set wall_type  6

#Bjerrum length
set l_b [expr 1.67101e-5/$SI_temperature*1e10]

#periodicity
setmd periodic 1 1 1

##### Integration setup
thermostat langevin $temperature $gamma
setmd time_step $time_step
setmd skin $skin 
setmd min_global_cut 13

#-------------------------
puts "->System Params:\n" ;flush stdout
#-------------------------
puts "random seed: [t_random seed]"
puts "Number of ion pairs: $n_ion"
puts "box x y z:        [format %.2f $box_x] [format %.2f $box_y] [format %.2f $box_l]\n"
puts "Volume:		$volume_sim"
puts "Bjerrum length:	$l_b"
puts "Temperature: 	$SI_temperature"
puts "Number of bins:   $nbins"
puts "Path:		$path"
puts "Wall time:	$hours hours"


#Icc walls first	
set n_icc 300
set iccres [expr sqrt($box_x*$box_y/$n_icc)]

puts "\n->placing walls:"

set sy 0.5



dielectric_hexagonal_wall dist $graphenePPDist2 normal 0 0 1.0 shift 0 $sy lattice_param $CCbondlength sigma 0 eps 10000.0 type $icc_wall_type icc 0
set iccParticlesLeft [setmd n_part]
dielectric_hexagonal_wall dist [expr -$tot_l+$graphenePPDist2] normal 0 0 -1.0 shift 0 $sy lattice_param $CCbondlength sigma 0 eps 10000.0 type $icc_wall_type icc 0
set iccParticlesRight [setmd n_part]

set icclist ""
for {set i 0} { $i < $iccParticlesRight } {incr i} {
	lappend icclist $i
}

dielectric_hexagonal_wall dist $graphenePPDist normal 0 0 1.0 shift [expr $CCbondlength*0.5*sqrt(3.0)] [expr $CCbondlength * 0.5+$sy] lattice_param $CCbondlength sigma 0 eps 10000.0 type $icc_wall_type icc 0
dielectric_hexagonal_wall dist 0 normal 0 0 1.0 shift 0 $sy lattice_param $CCbondlength sigma 0 eps 10000.0 type $icc_wall_type icc 0

dielectric_hexagonal_wall dist [expr -$tot_l+$graphenePPDist] normal 0 0 -1.0 shift [expr $CCbondlength*0.5*sqrt(3.0)] [expr $CCbondlength * 0.5+$sy] lattice_param $CCbondlength sigma 0 eps 10000.0 type $icc_wall_type icc 0
dielectric_hexagonal_wall dist [expr -$tot_l] normal 0 0 -1.0 shift 0 $sy lattice_param $CCbondlength sigma 0 eps 10000.0 type $icc_wall_type icc 0


set startIndexParts [setmd n_part]
puts "\nstartIndexIC: $startIndexParts"

set anionlist ""
set cationComlist ""
set cationlist ""

##### placing anions
#############################################################
#-------------------------
puts "->placing anions" ;flush stdout
#-------------------------

for {set i $startIndexParts} { $i < [expr $n_ion + $startIndexParts] } {incr i} {
    set posx [expr $box_x*[t_random]]
    set posy [expr $box_y*[t_random]]
    set posz [expr ($box_l-($lj_sig_w+$lj_sig_a))*[t_random]+$partBorderL + ($lj_sig_w+$lj_sig_a)*0.5]

    part $i pos $posx $posy $posz q $q_a type $a_type mass $m_a
    lappend anionlist $i
}
	
set oriList ""
#------------------------
puts "->placing cations" ;flush stdout
#------------------------
##### placing cations
#############################################################
for {set j $i} { $j < [expr 5*$n_ion + $startIndexParts] } {incr j 4} {
    set posx [expr $box_x*[t_random]]
    set posy [expr $box_y*[t_random]]
    set posz [expr ($box_l-($lj_sig_w+$lj_sig_c3*2.0))*[t_random]+$partBorderL + ($lj_sig_w+$lj_sig_c3*2.0)*0.5]
    part $j pos $posx $posy $posz type $non_virtual_type rinertia 646.284 585.158 61.126 mass [expr $m_c1 + $m_c2 + $m_c3] omega [expr 2*[t_random]-1] [expr 2*[t_random]-1] [expr 2*[t_random]-1]
    part [expr $j +1] pos $posx [expr $posy - 0.527] [expr $posz + 1.365] type $c1_type virtual 1 q $q_c1 vs_auto_relate_to $j vs_relative $j [expr sqrt(pow(-0.527,2)+pow(-1.365,2))] 
    part [expr $j +2] pos $posx [expr $posy + 1.641] [expr $posz + 2.987] type $c2_type virtual 1 q $q_c2 vs_auto_relate_to $j vs_relative $j [expr sqrt(pow(1.641,2)+pow(2.987,2))] 
    part [expr $j +3] pos $posx [expr $posy + 0.187] [expr $posz - 2.389] type $c3_type virtual 1 q $q_c3 vs_auto_relate_to $j vs_relative $j [expr sqrt(pow(0.187,2)+pow(-2.389,2))]
    lappend oriList $j [expr $j+1] [expr $j+2] [expr $j+3]
    lappend cationComlist $j
    lappend cationlist [expr $j+1]
    lappend cationlist [expr $j+2]
    lappend cationlist [expr $j+3]
}



#Setup interactions
if {$useCheckpoint == "no"} {

	#------------------------
	puts "->LJ warm up"
	#------------------------

	setmd time_step 0.01

	inter $c3_type $icc_wall_type lennard-jones $lj_eps_mix_c3_w $lj_sig_mix_c3_w [expr 2.5*$lj_sig_mix_c3_w] 0.004 0 0
	inter $c1_type $icc_wall_type lennard-jones $lj_eps_mix_c1_w $lj_sig_mix_c1_w [expr 2.5*$lj_sig_mix_c1_w] 0.004 0 0
	inter $c2_type $icc_wall_type lennard-jones $lj_eps_mix_c2_w $lj_sig_mix_c2_w [expr 2.5*$lj_sig_mix_c2_w] 0.004 0 0
	inter $a_type $icc_wall_type lennard-jones $lj_eps_mix_a_w $lj_sig_mix_a_w [expr 2.5*$lj_sig_mix_a_w] 0.004 0 0 

	inter forcecap "individual"

	set twop16 [expr pow(2.0,1.0/6.0)]
	set integ_steps_warm 50

	for {set cut 1.0} {$cut > 0.00001} {set cut [expr $cut*0.7]} {

		imd positions

		thermostat langevin [expr $temperature*(1.0-$cut)] [expr $gamma+25.0*$cut]

	    	puts "t=[setmd time] E=[analyze energy total] warmup: cut=$cut"; flush stdout
	
		inter $c1_type $c1_type lennard-jones $lj_eps_c1 $lj_sig_c1 [expr 2.5*$lj_sig_c1] 0.004 0 [expr $cut*$lj_sig_c1] 
		inter $c1_type $c2_type lennard-jones $lj_eps_mix_c1_c2 $lj_sig_mix_c1_c2 [expr 2.5*$lj_sig_mix_c1_c2] 0.004 0 [expr $cut*$lj_sig_mix_c1_c2]
		inter $c1_type $c3_type lennard-jones $lj_eps_mix_c1_c3 $lj_sig_mix_c1_c3  [expr 2.5*$lj_sig_mix_c1_c3] 0.004 0 [expr $cut*$lj_sig_mix_c1_c3]
		inter $c1_type $a_type lennard-jones $lj_eps_mix_c1_a $lj_sig_mix_c1_a [expr 2.5*$lj_sig_mix_c1_a] 0.004 0 [expr $cut*$lj_sig_mix_c1_a]
		inter $c2_type $c2_type lennard-jones $lj_eps_c2 $lj_sig_c2 [expr 2.5*$lj_sig_c2] 0.004 0 [expr $cut*$lj_sig_c2]
		inter $c2_type $c3_type lennard-jones $lj_eps_mix_c2_c3 $lj_sig_mix_c2_c3 [expr 2.5*$lj_sig_mix_c2_c3] 0.004 0 [expr $cut*$lj_sig_mix_c2_c3]
		inter $c2_type $a_type lennard-jones $lj_eps_mix_c2_a $lj_sig_mix_c2_a [expr 2.5*$lj_sig_mix_c2_a] 0.004 0 [expr $cut*$lj_sig_mix_c2_a]
		inter $c3_type $c3_type lennard-jones $lj_eps_c3 $lj_sig_c3 [expr 2.5*$lj_sig_c3] 0.004 0 [expr $cut*$lj_sig_c3]
		inter $c3_type $a_type lennard-jones $lj_eps_mix_c3_a $lj_sig_mix_c3_a [expr 2.5*$lj_sig_mix_c3_a] 0.004 0 [expr $cut*$lj_sig_mix_c3_a]
		inter $a_type $a_type lennard-jones $lj_eps_a $lj_sig_a [expr 2.5*$lj_sig_a] 0.004 0 [expr $cut*$lj_sig_a]
		integrate $integ_steps_warm

	}
	thermostat langevin $temperature $gamma
	inter forcecap 0

	setmd time_step $time_step
}


inter $c3_type $icc_wall_type lennard-jones $lj_eps_mix_c3_w $lj_sig_mix_c3_w [expr 2.5*$lj_sig_mix_c3_w] 0.004 0 0
inter $c1_type $icc_wall_type lennard-jones $lj_eps_mix_c1_w $lj_sig_mix_c1_w [expr 2.5*$lj_sig_mix_c1_w] 0.004 0 0
inter $c2_type $icc_wall_type lennard-jones $lj_eps_mix_c2_w $lj_sig_mix_c2_w [expr 2.5*$lj_sig_mix_c2_w] 0.004 0 0
inter $a_type $icc_wall_type lennard-jones $lj_eps_mix_a_w $lj_sig_mix_a_w [expr 2.5*$lj_sig_mix_a_w] 0.004 0 0 
inter $c1_type $c1_type lennard-jones $lj_eps_c1 $lj_sig_c1 [expr 2.5*$lj_sig_c1] 0.004 0 0
inter $c1_type $c2_type lennard-jones $lj_eps_mix_c1_c2 $lj_sig_mix_c1_c2 [expr 2.5*$lj_sig_mix_c1_c2] 0.004 0 0
inter $c1_type $c3_type lennard-jones $lj_eps_mix_c1_c3 $lj_sig_mix_c1_c3  [expr 2.5*$lj_sig_mix_c1_c3] 0.004 0 0
inter $c1_type $a_type lennard-jones $lj_eps_mix_c1_a $lj_sig_mix_c1_a [expr 2.5*$lj_sig_mix_c1_a] 0.004 0 0
inter $c2_type $c2_type lennard-jones $lj_eps_c2 $lj_sig_c2 [expr 2.5*$lj_sig_c2] 0.004 0 0
inter $c2_type $c3_type lennard-jones $lj_eps_mix_c2_c3 $lj_sig_mix_c2_c3 [expr 2.5*$lj_sig_mix_c2_c3] 0.004 0 0
inter $c2_type $a_type lennard-jones $lj_eps_mix_c2_a $lj_sig_mix_c2_a [expr 2.5*$lj_sig_mix_c2_a] 0.004 0 0
inter $c3_type $c3_type lennard-jones $lj_eps_c3 $lj_sig_c3 [expr 2.5*$lj_sig_c3] 0.004 0 0
inter $c3_type $a_type lennard-jones $lj_eps_mix_c3_a $lj_sig_mix_c3_a [expr 2.5*$lj_sig_mix_c3_a] 0.004 0 0
inter $a_type $a_type lennard-jones $lj_eps_a $lj_sig_a [expr 2.5*$lj_sig_a] 0.004 0 0


if {$useCheckpoint == "yes"} {

	#-----------------------
	puts "->Load checkpoint"
	#-----------------------

	set file [open "$pathToCheckpoint" "r"]
	while { [blockfile $file read auto] != "eof" } {}
	close $file
	integrate 0

	
} else {

	#-----------------------
	puts "->Starting temperature equilibration"
	#-----------------------
	for {set curr_temp 1600} {$curr_temp > 400} {set curr_temp [expr $curr_temp-200]} {
		thermostat langevin [expr $curr_temp*$kb_kjmol] $gamma
		puts "Temp. equi. at $curr_temp K"
		for {set temp_eq_loop 0} {$temp_eq_loop<10} {incr temp_eq_loop} {
			integrate 100
			puts "$temp_eq_loop / 10"
			imd positions
		}
	}

	thermostat langevin $temperature $gamma

	puts [inter coulomb $l_b p3m tunev2 accuracy 1e-2]
	inter coulomb elc 1e-4 $gap noneutralization

	if { $external_force !=0 } {	
		puts "->Incrementally apply external force"
		for { set fac 0.0 } { $fac <= $external_force } { set fac [expr $fac+0.1*$external_force] } {
			for {set i $startIndexParts} { $i < [expr $n_ion + $startIndexParts] } {incr i} {
				part $i ext_force 0 0 [expr $fac*$q_a]
			}
			for {set j $i} { $j < [expr 5*$n_ion + $startIndexParts] } {incr j 4} {
				part [expr $j +1] ext_force 0 0 [expr $fac*$q_c1]
				part [expr $j +2] ext_force 0 0 [expr $fac*$q_c2]
				part [expr $j +3] ext_force 0 0 [expr $fac*$q_c3]
			}
			puts "External force: $fac" ; flush stdout
			integrate 10
		}
	}
}


puts [inter coulomb $l_b p3m tunev2 accuracy 1e-2]
inter coulomb elc 1e-4 $gap noneutralization


#---------------------
puts "->Apply full external force"
#---------------------

for {set i $startIndexParts} { $i < [expr $n_ion + $startIndexParts] } {incr i} {
	part $i ext_force 0 0 [expr $external_force*$q_a]
}
for {set j $i} { $j < [expr 5*$n_ion + $startIndexParts] } {incr j 4} {
	part [expr $j +1] ext_force 0 0 [expr $external_force*$q_c1]
	part [expr $j +2] ext_force 0 0 [expr $external_force*$q_c2]
	part [expr $j +3] ext_force 0 0 [expr $external_force*$q_c3]
}


setmd time 0

set useObservables "yes"
if {$useObservables == "yes"} {

	#-----------------------
	puts "->Init observables"
	#-----------------------

	set obs_orientation [observable new molecule_orientation ids $oriList minx 0 maxx $box_x xbins 1 miny 0 maxy $box_y ybins 1 minz $partBorderL maxz $partBorderR zbins $nbins]
	set obs_anion_pos_id [observable new density_profile type [list $a_type] minx 0 maxx $box_x xbins 1 miny 0 maxy $box_y ybins 1 minz $partBorderL maxz $partBorderR zbins $nbins]
	set obs_cation_pos_id [observable new density_profile type [list $non_virtual_type] minx 0 maxx $box_x xbins 1 miny 0 maxy $box_y ybins 1 minz $partBorderL maxz $partBorderR zbins $nbins]
	set obs_cation_c1_id [observable new density_profile type [list $c1_type] minx 0 maxx $box_x xbins 1 maxy $box_y ybins 1 minz $partBorderL maxz $partBorderR zbins $nbins]
	set obs_cation_c2_id [observable new density_profile type [list $c2_type] minx 0 maxx $box_x xbins 1 maxy $box_y ybins 1 minz $partBorderL maxz $partBorderR zbins $nbins]
	set obs_cation_c3_id [observable new density_profile type [list $c3_type] minx 0 maxx $box_x xbins 1 maxy $box_y ybins 1 minz $partBorderL maxz $partBorderR zbins $nbins]

	set sampleTime [expr 3*$time_step]
	set tauMax [expr 2*$sampleTime]
	set corr_orientation [correlation new obs1 $obs_orientation tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
	set corr_anion_pos_id [correlation new obs1 $obs_anion_pos_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
	set corr_cation_pos_id [correlation new obs1 $obs_cation_pos_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
	set corr_cation_c1_id [correlation new obs1 $obs_cation_c1_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
	set corr_cation_c2_id [correlation new obs1 $obs_cation_c2_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]
	set corr_cation_c3_id [correlation new obs1 $obs_cation_c3_id tau_max $tauMax dt $sampleTime compress1 discard1 corr_operation componentwise_product]

	correlation $corr_orientation autoupdate start
	correlation $corr_anion_pos_id autoupdate start
	correlation $corr_cation_pos_id autoupdate start
	correlation $corr_cation_c1_id autoupdate start
	correlation $corr_cation_c2_id autoupdate start
	correlation $corr_cation_c3_id autoupdate start
}


#-----------------------
puts "Starting integration"
#-----------------------

set start_time_integration [expr 1.0*[clock clicks -milliseconds]]
set n_step 100
set cnt 0


set obs_traj [open "$path/trajectory_${charge_dens}.vtf" "w"]
writevsf $obs_traj


while {1} {

	writevcf $obs_traj folded

	set t0 [clock clicks -milliseconds]
	integrate $n_step
	set curr_duration [expr (1.0*[clock clicks -milliseconds]-$start_time)/1e3]
	puts "Integrate: [expr [clock clicks -milliseconds]-$t0] ms"
        if {$curr_duration>=$wall_time} { break	}

	incr cnt

}

#-----------------------
puts "Writing results"
#-----------------------
close $obs_traj

set duration_integration [expr (1.0*[clock clicks -milliseconds] - $start_time_integration)/1e3 ]

correlation $corr_orientation finalize
correlation $corr_anion_pos_id finalize
correlation $corr_cation_pos_id finalize
correlation $corr_cation_c1_id finalize
correlation $corr_cation_c2_id finalize
correlation $corr_cation_c3_id finalize

#Bin index to z position
set zlist ""
for {set j 0} {$j < $nbins} {incr j} { 
	lappend zlist [expr 1.0*$box_l/$nbins*$j]
}

#### Orientation analysis
set orientation_analysis [correlation $corr_orientation print average1]
set out [ open "$path/orientation_hist_pot_${charge_dens}" "w" ]
	foreach z $zlist c $orientation_analysis { puts $out "$z $c" }
close $out

##### Charge density
set charge_density [vecadd [vecadd [vecscale $q_c1 [correlation $corr_cation_c1_id print average1]] [vecscale $q_c2 [correlation $corr_cation_c2_id print average1]]] [vecadd [vecscale $q_c3 [correlation $corr_cation_c3_id print average1]] [vecscale $q_a [correlation $corr_anion_pos_id print average1]]]] 
#set err [vecadd [vecadd [vecscale $q_c1 [correlation $corr_cation_c1_id print average_errorbars]] [vecscale $q_c2 [correlation $corr_cation_c2_id print average_errorbars]]] [vecadd [vecscale $q_c3 [correlation $corr_cation_c3_id print average_errorbars]] [vecscale $q_a [correlation $corr_anion_pos_id print average_errorbars]]]] 
set out [open "$path/charge_dens_pot_${charge_dens}" "w"]
	foreach z $zlist c $charge_density { puts $out "$z $c" }
close $out 

##### Total density
set total_density [vecadd [vecadd [vecadd [correlation $corr_cation_c1_id print average1] [correlation $corr_cation_c2_id print average1]] [correlation $corr_cation_c3_id print average1]] [correlation $corr_anion_pos_id print average1]] 
set out [open "$path/total_dens_pot_${charge_dens}" "w"]
	foreach z $zlist c $total_density { puts $out "$z $c" }
close $out 

##### Anion density
set anion_den [ correlation $corr_anion_pos_id print average1 ]
set err [ correlation $corr_anion_pos_id print average_errorbars ] 
set out [open "$path/anion_dens_pot_${charge_dens}" "w"]
	foreach z $zlist c $anion_den e $err { puts $out "$z $c $e" }
close $out

#CationCom density
set cation_den [ correlation $corr_cation_pos_id print average1 ]
set err [ correlation $corr_cation_pos_id print average_errorbars ]
set out [open "$path/cation_dens_com_pot_${charge_dens}" "w"]
	foreach z $zlist c $cation_den e $err { puts $out "$z $c $e" }
close $out

#CationC1 densitcom
set cation_den_c1 [ correlation $corr_cation_c1_id print average1 ]
set err [ correlation $corr_cation_c1_id print average_errorbars ]
set out [open "$path/cation_dens_c1_pot_${charge_dens}" "w"]
	foreach z $zlist c $cation_den_c1 e $err { puts $out "$z $c $e" }
close $out
#CationC2 density
set cation_den_c2 [ correlation $corr_cation_c2_id print average1 ]
set err [ correlation $corr_cation_c2_id print average_errorbars ]
set out [open "$path/cation_dens_c2_pot_${charge_dens}" "w"]
	foreach z $zlist c $cation_den_c2 e $err { puts $out "$z $c $e" }
close $out
#CationC3 density
set cation_den_c3 [ correlation $corr_cation_c3_id print average1 ]
set err [ correlation $corr_cation_c3_id print average_errorbars ]
set out [open "$path/cation_dens_c3_pot_${charge_dens}" "w"]
	foreach z $zlist c $cation_den_c3 e $err { puts $out "$z $c $e" }
close $out

#Write config
set file [open "$path/checkpoint_pot_${charge_dens}.dat" w]
blockfile $file write particles "q" $icclist
blockfile $file write particles "pos v f" $anionlist
blockfile $file write particles "pos quat v f" $cationComlist
blockfile $file write particles "pos v f" $cationlist
close $file


###### Stopwatch
#############################################################

#Estimate time
set duration [expr ([clock clicks -milliseconds]-$start_time) /1e3]
if {$duration>=3600.0} {
    set total_runtime [format "%.2f hours" [expr {$duration / 3600.0}]]
} elseif {$duration>=60.0} {
    set total_runtime [format "%.2f minutes" [expr {$duration / 60.0}]]
} else {
    set total_runtime [format "%.2f seconds" [expr {$duration}]]
}


if {$duration_integration>=3600.0} {
    set total_integtime [format "%.2f hours" [expr {$duration_integration / 3600.0}]]
} elseif {$duration_integration>=60.0} {
    set total_integtime [format "%.2f minutes" [expr {$duration_integration / 60.0}]]
} else {
    set total_integtime [format "%.2f seconds" [expr {$duration_integration}]]
}

set out [open "$path/sim_params_pot_${charge_dens}" "w"]
puts $out "Path:             $path"
puts $out "RunIdent:         $run_ident"
puts $out "random seed:      [t_random seed]"
puts $out "N ion pairs:      $n_ion"
puts $out "box x y z:        [format %.2f $box_x] [format %.2f $box_y] [format %.2f $box_l]\n"
puts $out "Gap:              $gap"
puts $out "Volume:           $volume_sim"
puts $out "Bjerrum length:   $l_b"
puts $out "Temperature:      $SI_temperature"
puts $out "Surface charge:   [lindex $argv 0]"
puts $out "Average sigma:    $sig_mean"
puts $out "Number of bins:   $nbins"
puts $out "Wall time:        $hours hours"
puts $out "Integ. Time:      $total_integtime"
puts $out "Total Runtime:    $total_runtime"
puts $out  "Sim. time:       [expr $timescale*[setmd time]] s"
puts $out  "Sim. realtime:   [expr $timescale*[setmd time]] s"
close $out


#-------------------------
puts "\n->All done in $total_runtime\n" ;flush stdout
#-------------------------
