proc gen_lj_shift { eps sig cut roff e1 e2 b1 b2 } {
	return [expr -($b1*pow($sig/($cut-$roff),$e1)-$b2*pow($sig/($cut-$roff),$e2))]
}

########Simulation of [BMIM][PF6] in ESPResSo
###### 


### setting seed

t_random seed [pid] [pid] [pid] [pid] [pid] [pid] [pid] [pid]

##### Run identification
###########################################################

set run_ident [lindex $argv 1] 


##### Units
###########################################################
# Simulation Unit [1]		Physical Unit
# Length             		1*10^(-10) m (Angstrom)
# Volume			1*10^(-30) m^3 (Angstrom^3)
# Mass				gramm/mol
# Energy			kJ/mol
# Time 				1*10^(-13) s
# charge			1*e (elementary charge)

##### stopwatch
###########################################################
set start_time [expr 1.0*[clock clicks -milliseconds]]


puts ""
puts "========================================="
puts "Simulation of BMIM-PF_6 with simple walls"
puts "========================================="
puts "ESPResSo code base:  [code_info]"
puts ""

##### System parameters
#############################################################
set n_ion 320
set hours 23.5 
set wall_time [expr $hours*3600.0]

##### System size
#############################################################
set n_part [expr 2*$n_ion ]
set V_m 2.21e26
set N_A 6.022141e23
set wall_layer_dist 3.35
set wall_layer_diam 3.37
set volume [expr $n_ion/$N_A*$V_m]
set non_cube_ratio 4 
set box_l [expr pow(pow($non_cube_ratio,2)*$volume,1.0/3.0)+$wall_layer_diam]
set box_h [expr ($box_l-$wall_layer_diam)/$non_cube_ratio]
set gap [expr 0.20*($box_l+4*$wall_layer_dist)]
set wall_shift 5.0
setmd box_l $box_h $box_h [expr $box_l+$gap]

#### External force parameters
############################################################
set U_pot [expr [lindex $argv 0]/0.01036427]
set epsilon_0 5.728e-5

##### Data management
#############################################################
#set path "/scratch/ws/dgbw0970-graphite_walls-0/graphite_walls/$run_ident/$charge_dens"
set path "/work/konrad/BMIMPF6/${run_ident}"
file mkdir $path
#file mkdir "${path}/trajectory"

##### Interaction parameters
############################################################
set lj_sig_c1 4.38
set lj_sig_c2 3.41
set lj_sig_c3 5.04
set lj_sig_a  5.06
set lj_sig_w  2.11

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
set lj_eps_w  24.7

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

set lj_w_e1  9.32
set lj_w_e2  4.66
set lj_w_b1  4.0
set lj_w_b2  4.0
set lj_w_roff 0.0

set lj_w_cut_p_sig 3.0

set q_c1 0.4374
set q_c2 0.1578
set q_c3 0.1848
set q_a  [expr -0.7800]

set m_c1 67.07
set m_c2 15.04
set m_c3 57.12
set m_a 144.96


##### Thermostat/ Verlet parameters
#############################################################
set SI_temperature 1600
set temperature [expr $SI_temperature/120.272]
set gamma       1.0
set skin	0.4
set time_step   0.04
set accuracy    1.0e-04


##### Histogram precision
#############################################################
#set nbins 300
set nbins [expr round(50*$box_l/$sig_mean)]
##### Types
#############################################################
set c1_type 0
set c2_type 1
set c3_type 2
set a_type  3
set non_virtual_type 4 
set wall_type  5

##### Bjerrum length
#############################################################
set l_b [expr 1.67101e-5/$SI_temperature*1e10]

##### periodicity
#############################################################
setmd periodic 1 1 1



##### Integration setup
thermostat langevin $temperature $gamma
setmd time_step $time_step; setmd skin $skin 
setmd min_global_cut 13

#-------------------------
puts "->System specifics:\n" ;flush stdout
#-------------------------
puts "random seed: [t_random seed]"
puts "Number of ion pairs: $n_ion"
puts "box x y z:        [format %.2f $box_h] [format %.2f $box_h] [format %.2f $box_l]\n"
puts "Volume:		$volume"
puts "Bjerrum length:	$l_b"
puts "Temperature: 	$SI_temperature"
puts "Constraints:	[constraint]"
puts "Voltage:		[lindex $argv 0] V"
puts "Average sigma:    $sig_mean"
puts "Number of bins:   $nbins"
puts "Path:		$path"
puts "Non cube ratio:	$non_cube_ratio"
puts "Wall time:	$hours hours"
#-------------------------
puts "->placing anions" ;flush stdout
#-------------------------


##### placing anions
#############################################################

for {set i 0} { $i < $n_ion } {incr i} {
    set posx [expr $box_h*[t_random]]
    set posy [expr $box_h*[t_random]]
    set posz [expr ($box_l-4.0*$lj_sig_w)*[t_random]+2.0*$lj_sig_w]

    part $i pos $posx $posy $posz q $q_a type $a_type mass $m_a
}
	

set oriList ""
#------------------------
puts "->placing cations" ;flush stdout
#------------------------
##### placing cations
#############################################################
for {set j $i} { $j < [expr 5*$n_ion] } {incr j 4} {
    set posx [expr $box_h*[t_random]]
    set posy [expr $box_h*[t_random]]
    set posz [expr ($box_l-4.0*$lj_sig_w)*[t_random]+2.0*$lj_sig_w]
    part $j pos $posx $posy $posz type $non_virtual_type rinertia 646.284 585.158 61.126 mass [expr $m_c1 + $m_c2 + $m_c3] omega [expr 2*[t_random]-1] [expr 2*[t_random]-1] [expr 2*[t_random]-1]
    part [expr $j +1] pos $posx [expr $posy - 0.527] [expr $posz + 1.365] type $c1_type virtual 1 q $q_c1 vs_auto_relate_to $j vs_relative $j [expr sqrt(pow(-0.527,2)+pow(-1.365,2))] 
    part [expr $j +2] pos $posx [expr $posy + 1.641] [expr $posz + 2.987] type $c2_type virtual 1 q $q_c2 vs_auto_relate_to $j vs_relative $j [expr sqrt(pow(1.641,2)+pow(2.987,2))] 
    part [expr $j +3] pos $posx [expr $posy + 0.187] [expr $posz - 2.389] type $c3_type virtual 1 q $q_c3 vs_auto_relate_to $j vs_relative $j [expr sqrt(pow(0.187,2)+pow(-2.389,2))]
    lappend oriList $j [expr $j+1] [expr $j+2] [expr $j+3]
}

#Electrode walls
constraint wall normal 0 0 1 dist 0 type $wall_type
constraint wall normal 0 0 -1 dist [expr -$box_l] type $wall_type

# Check neutrality of the system
puts -nonewline "    Checking that total charge is zero... "; flush stdout
set total_charge 0
for {set i 0} { $i < [expr 5*$n_ion] } {incr i} { 
    set total_charge [expr $total_charge + [part $i print q]] }
if { abs($total_charge) > $accuracy } {
    puts "Failed.\nERROR: System has non-zero total charge $total_charge ! Aborting... "}
puts "Done (found $total_charge as overall charge)."




##### interaction parameters
#############################################################

#------------------------
puts "->LJ warm up"
#------------------------

set integ_steps_warm 50
inter forcecap "individual"

for {set cut 4.0} {$cut > 0.00001} {set cut [expr $cut*0.75]} {

    	puts "t=[setmd time] E=[analyze energy total] warmup: cut=$cut"; flush stdout
	inter $c1_type $c1_type lennard-jones $lj_eps_c1 $lj_sig_c1 [expr 2.5*$lj_sig_c1] auto 0 [expr $cut*$lj_sig_c1] 
	inter $c1_type $c2_type lennard-jones $lj_eps_mix_c1_c2 $lj_sig_mix_c1_c2 [expr 2.5*$lj_sig_mix_c1_c2] auto 0 [expr $cut*$lj_sig_mix_c1_c2]
	inter $c1_type $c3_type lennard-jones $lj_eps_mix_c1_c3 $lj_sig_mix_c1_c3  [expr 2.5*$lj_sig_mix_c1_c3] auto 0 [expr $cut*$lj_sig_mix_c1_c3]
	inter $c1_type $a_type lennard-jones $lj_eps_mix_c1_a $lj_sig_mix_c1_a [expr 2.5*$lj_sig_mix_c1_a] auto 0 [expr $cut*$lj_sig_mix_c1_a]

	inter $c2_type $c2_type lennard-jones $lj_eps_c2 $lj_sig_c2 [expr 2.5*$lj_sig_c2] auto 0 [expr $cut*$lj_sig_c2]
	inter $c2_type $c3_type lennard-jones $lj_eps_mix_c2_c3 $lj_sig_mix_c2_c3 [expr 2.5*$lj_sig_mix_c2_c3] auto 0 [expr $cut*$lj_sig_mix_c2_c3]
	inter $c2_type $a_type lennard-jones $lj_eps_mix_c2_a $lj_sig_mix_c2_a [expr 2.5*$lj_sig_mix_c2_a] auto 0 [expr $cut*$lj_sig_mix_c2_a]
	
	inter $c3_type $c3_type lennard-jones $lj_eps_c3 $lj_sig_c3 [expr 2.5*$lj_sig_c3] auto 0 [expr $cut*$lj_sig_c3]
	inter $c3_type $a_type lennard-jones $lj_eps_mix_c3_a $lj_sig_mix_c3_a [expr 2.5*$lj_sig_mix_c3_a] auto 0 [expr $cut*$lj_sig_mix_c3_a]
	
	inter $a_type $a_type lennard-jones $lj_eps_a $lj_sig_a [expr 2.5*$lj_sig_a] auto 0 [expr $cut*$lj_sig_a]


	set cutoff [expr $lj_w_roff + $lj_w_cut_p_sig*$lj_sig_mix_c1_w]
	inter $c1_type $wall_type lj-gen $lj_eps_mix_c1_w $lj_sig_mix_c1_w $cutoff \
	      [gen_lj_shift $lj_eps_mix_c1_w $lj_sig_mix_c1_w $cutoff $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2] \
              $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2 0

	set cutoff [expr $lj_w_roff + $lj_w_cut_p_sig*$lj_sig_mix_c2_w]
	inter $c2_type $wall_type lj-gen $lj_eps_mix_c2_w $lj_sig_mix_c2_w $cutoff \
	      [gen_lj_shift $lj_eps_mix_c2_w $lj_sig_mix_c2_w $cutoff $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2] \
	      $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2 0

	set cutoff [expr $lj_w_roff + $lj_w_cut_p_sig*$lj_sig_mix_c3_w]
	inter $c3_type $wall_type lj-gen $lj_eps_mix_c3_w $lj_sig_mix_c3_w $cutoff \
	      [gen_lj_shift $lj_eps_mix_c3_w $lj_sig_mix_c3_w $cutoff $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2] \
	      $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2 0

	set cutoff [expr $lj_w_roff + $lj_w_cut_p_sig*$lj_sig_mix_a_w]
	inter $a_type $wall_type lj-gen $lj_eps_mix_a_w $lj_sig_mix_a_w $cutoff \
	      [gen_lj_shift $lj_eps_mix_a_w $lj_sig_mix_a_w $cutoff $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2] \
	      $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2 0

        integrate $integ_steps_warm
    	
  }




##### End of warmup integration
######################################################################### 
inter forcecap 0

inter $c1_type $c1_type lennard-jones $lj_eps_c1 $lj_sig_c1 [expr 2.5*$lj_sig_c1] auto 0 0
inter $c1_type $c2_type lennard-jones $lj_eps_mix_c1_c2 $lj_sig_mix_c1_c2 [expr 2.5*$lj_sig_mix_c1_c2] auto 0 0
inter $c1_type $c3_type lennard-jones $lj_eps_mix_c1_c3 $lj_sig_mix_c1_c3  [expr 2.5*$lj_sig_mix_c1_c3] auto 0 0
inter $c1_type $a_type lennard-jones $lj_eps_mix_c1_a $lj_sig_mix_c1_a [expr 2.5*$lj_sig_mix_c1_a] auto 0 0

inter $c2_type $c2_type lennard-jones $lj_eps_c2 $lj_sig_c2 [expr 2.5*$lj_sig_c2] auto 0 0
inter $c2_type $c3_type lennard-jones $lj_eps_mix_c2_c3 $lj_sig_mix_c2_c3 [expr 2.5*$lj_sig_mix_c2_c3] auto 0 0
inter $c2_type $a_type lennard-jones $lj_eps_mix_c2_a $lj_sig_mix_c2_a [expr 2.5*$lj_sig_mix_c2_a] auto 0 0

inter $c3_type $c3_type lennard-jones $lj_eps_c3 $lj_sig_c3 [expr 2.5*$lj_sig_c3] auto 0 0
inter $c3_type $a_type lennard-jones $lj_eps_mix_c3_a $lj_sig_mix_c3_a [expr 2.5*$lj_sig_mix_c3_a] auto 0 0

inter $a_type $a_type lennard-jones $lj_eps_a $lj_sig_a [expr 2.5*$lj_sig_a] auto 0 0

set cutoff [expr $lj_w_roff + $lj_w_cut_p_sig*$lj_sig_mix_c1_w]
inter $c1_type $wall_type lj-gen $lj_eps_mix_c1_w $lj_sig_mix_c1_w $cutoff \
      [gen_lj_shift $lj_eps_mix_c1_w $lj_sig_mix_c1_w $cutoff $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2] \
      $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2 0

set cutoff [expr $lj_w_roff + $lj_w_cut_p_sig*$lj_sig_mix_c2_w]
inter $c2_type $wall_type lj-gen $lj_eps_mix_c2_w $lj_sig_mix_c2_w $cutoff \
      [gen_lj_shift $lj_eps_mix_c2_w $lj_sig_mix_c2_w $cutoff $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2] \
      $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2 0

set cutoff [expr $lj_w_roff + $lj_w_cut_p_sig*$lj_sig_mix_c3_w]
inter $c3_type $wall_type lj-gen $lj_eps_mix_c3_w $lj_sig_mix_c3_w $cutoff \
      [gen_lj_shift $lj_eps_mix_c3_w $lj_sig_mix_c3_w $cutoff $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2] \
      $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2 0

set cutoff [expr $lj_w_roff + $lj_w_cut_p_sig*$lj_sig_mix_a_w]
inter $a_type $wall_type lj-gen $lj_eps_mix_a_w $lj_sig_mix_a_w $cutoff \
      [gen_lj_shift $lj_eps_mix_a_w $lj_sig_mix_a_w $cutoff $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2] \
      $lj_w_roff $lj_w_e1 $lj_w_e2 $lj_w_b1 $lj_w_b2 0



#------------------------
puts "->Tune P3m"
#------------------------

inter coulomb $l_b p3m tunev2 accuracy 1e-4
inter coulomb elc 1e-4 $gap noneutralization

#-----------------------
puts "->Starting temperature equilibration"
#-----------------------

set obs_energy [open "$path/obs_energy$U_pot.dat" "w"]
for {set curr_temp 1600} {$curr_temp > 400} {set curr_temp [expr $curr_temp-200]} {
	set SI_temperature $curr_temp
	set temperature [expr $SI_temperature/120.272]
	set l_b [expr 1.67101e-5/$SI_temperature*1e10]
	set meas_temp [expr [analyze energy kinetic]/(3*0.0083145*2*$n_ion)]
	puts "Measured temperature/thermostat temperature: $meas_temp / $curr_temp"
	thermostat langevin $temperature $gamma
	inter coulomb $l_b p3m tunev2 accuracy 1e-4
	for {set temp_eq_loop 0} {$temp_eq_loop<10} {incr temp_eq_loop} {
		integrate 100
		set meas_temp [expr [analyze energy kinetic]/(3*0.0083145*2*$n_ion)]
		puts "Measured temperature/thermostat temperature: $meas_temp / $curr_temp"
		puts "loop:			$temp_eq_loop"
	}
}
puts "Setting final temperature of 400 K"
set SI_temperature 400
set temperature [expr $SI_temperature/120.272]
set l_b [expr 1.67101e-5/$SI_temperature*1e10]
thermostat langevin $temperature $gamma

inter coulomb $l_b p3m tunev2 accuracy 1e-4
inter coulomb elc 1e-4 $gap capacitor $U_pot

set obs_scharge [open "$path/s_charge_${U_pot}" "w"]

set t [setmd time]
#1500
while {$t<1500} {
	integrate 50
	puts "t=[setmd time] E=[analyze energy total] equilibration"; 
	puts $obs_scharge "[setmd time] [surfacecharge induced] [surfacecharge bare]"
	flush stdout
	set t [setmd time]
}


set n_step 50

setmd time 0

set obs_orientation [observable new molecule_orientation ids $oriList minx 0 maxx $box_h xbins 1 miny 0 maxy $box_h ybins 1 minz 0 maxz [expr $box_l] zbins $nbins]
set obs_anion_pos_id [observable new density_profile type [list $a_type] minx 0 maxx $box_h xbins 1 miny 0 maxy $box_h ybins 1 minz 0 maxz [expr $box_l] zbins $nbins]
set obs_cation_pos_id [observable new density_profile type [list $non_virtual_type] minx 0 maxx $box_h xbins 1 miny 0 maxy $box_h ybins 1 minz 0 maxz [expr $box_l] zbins $nbins]
set obs_cation_c1_id [observable new density_profile type [list $c1_type] minx 0 maxx $box_h xbins 1 maxy $box_h ybins 1 minz 0 maxz [expr $box_l] zbins $nbins]
set obs_cation_c2_id [observable new density_profile type [list $c2_type] minx 0 maxx $box_h xbins 1 maxy $box_h ybins 1 minz 0 maxz [expr $box_l] zbins $nbins]
set obs_cation_c3_id [observable new density_profile type [list $c3_type] minx 0 maxx $box_h xbins 1 maxy $box_h ybins 1 minz 0 maxz [expr $box_l] zbins $nbins]

set corr_orientation [correlation new obs1 $obs_orientation tau_max 10 dt [expr 2.5*$time_step] compress1 discard1 corr_operation componentwise_product]
set corr_anion_pos_id [correlation new obs1 $obs_anion_pos_id tau_max 10 dt [expr 2.5*$time_step] compress1 discard1 corr_operation componentwise_product]
set corr_cation_pos_id [correlation new obs1 $obs_cation_pos_id tau_max 10 dt [expr 2.5*$time_step] compress1 discard1 corr_operation componentwise_product]
set corr_cation_c1_id [correlation new obs1 $obs_cation_c1_id tau_max 10 dt [expr 2.5*$time_step] compress1 discard1 corr_operation componentwise_product]
set corr_cation_c2_id [correlation new obs1 $obs_cation_c2_id tau_max 10 dt [expr 2.5*$time_step] compress1 discard1 corr_operation componentwise_product]
set corr_cation_c3_id [correlation new obs1 $obs_cation_c3_id tau_max 10 dt [expr 2.5*$time_step] compress1 discard1 corr_operation componentwise_product]

correlation $corr_orientation autoupdate start
correlation $corr_anion_pos_id autoupdate start
correlation $corr_cation_pos_id autoupdate start
correlation $corr_cation_c1_id autoupdate start
correlation $corr_cation_c2_id autoupdate start
correlation $corr_cation_c3_id autoupdate start


puts "--------------------------------------------"
puts "Simulating BMIM-PF_6 with $n_ion ion pairs"
puts "--------------------------------------------"

#set vtf_file [open "$path/trajectory/trajectory_${U_pot}.vtf" "w"]

### Write structure file
#writevsf $vtf_file

set start_time_integration [expr 1.0*[clock clicks -milliseconds]]
set loop 0
while {1} {
	integrate $n_step
	puts "t=[setmd time] E=[analyze energy total] loop=$loop"; flush stdout 
#	writevcf $vtf_file
        puts $obs_energy "[setmd time] [analyze energy total]"; flush stdout
	puts $obs_scharge "[setmd time] [surfacecharge induced] [surfacecharge bare]"
	set curr_duration [expr (1.0*[clock clicks -milliseconds]-$start_time)/1e3]
        if {$curr_duration>=$wall_time} {
                break
	}
	incr loop
}

set duration_integration [expr (1.0*[clock clicks -milliseconds] - $start_time_integration)/1e3 ]

close $obs_energy
#close $vtf_file
close $obs_scharge

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
set out [ open "$path/orientation_hist_pot_${U_pot}" "w" ]
	foreach z $zlist c $orientation_analysis { puts $out "$z $c" }
close $out

##### Charge density
set charge_density [vecadd [vecadd [vecscale $q_c1 [correlation $corr_cation_c1_id print average1]] [vecscale $q_c2 [correlation $corr_cation_c2_id print average1]]] [vecadd [vecscale $q_c3 [correlation $corr_cation_c3_id print average1]] [vecscale $q_a [correlation $corr_anion_pos_id print average1]]]] 
#set err [vecadd [vecadd [vecscale $q_c1 [correlation $corr_cation_c1_id print average_errorbars]] [vecscale $q_c2 [correlation $corr_cation_c2_id print average_errorbars]]] [vecadd [vecscale $q_c3 [correlation $corr_cation_c3_id print average_errorbars]] [vecscale $q_a [correlation $corr_anion_pos_id print average_errorbars]]]] 
set out [open "$path/charge_dens_pot_${U_pot}" "w"]
	foreach z $zlist c $charge_density { puts $out "$z $c" }
close $out 

##### Total density
set total_density [vecadd [vecadd [vecadd [correlation $corr_cation_c1_id print average1] [correlation $corr_cation_c2_id print average1]] [correlation $corr_cation_c3_id print average1]] [correlation $corr_anion_pos_id print average1]] 
set out [open "$path/total_dens_pot_${U_pot}" "w"]
	foreach z $zlist c $total_density { puts $out "$z $c" }
close $out 

##### Anion density
set anion_den [ correlation $corr_anion_pos_id print average1 ]
set err [ correlation $corr_anion_pos_id print average_errorbars ] 
set out [open "$path/anion_dens_pot_${U_pot}" "w"]
	foreach z $zlist c $anion_den e $err { puts $out "$z $c $e" }
close $out

#CationCom density
set cation_den [ correlation $corr_cation_pos_id print average1 ]
set err [ correlation $corr_cation_pos_id print average_errorbars ]
set out [open "$path/cation_dens_com_pot_${U_pot}" "w"]
	foreach z $zlist c $cation_den e $err { puts $out "$z $c $e" }
close $out

#CationC1 density
set cation_den_c1 [ correlation $corr_cation_c1_id print average1 ]
set err [ correlation $corr_cation_c1_id print average_errorbars ]
set out [open "$path/cation_dens_c1_pot_${U_pot}" "w"]
	foreach z $zlist c $cation_den_c1 e $err { puts $out "$z $c $e" }
close $out
#CationC2 density
set cation_den_c2 [ correlation $corr_cation_c2_id print average1 ]
set err [ correlation $corr_cation_c2_id print average_errorbars ]
set out [open "$path/cation_dens_c2_pot_${U_pot}" "w"]
	foreach z $zlist c $cation_den_c2 e $err { puts $out "$z $c $e" }
close $out
#CationC3 density
set cation_den_c3 [ correlation $corr_cation_c3_id print average1 ]
set err [ correlation $corr_cation_c3_id print average_errorbars ]
set out [open "$path/cation_dens_c3_pot_${U_pot}" "w"]
	foreach z $zlist c $cation_den_c3 e $err { puts $out "$z $c $e" }
close $out

#Tot pot
#set out [open "$path/tot_potential_${U_pot}" "w"]
#set pot ""
#set b [expr 1.0/(5.728e-5*180.9513)]
#foreach z $zlist {
#	set sum 0
#	set cnt 0
#	foreach zd $zlist {
#		#Integrating with trapezoid rule
#		set nenner [expr $box_l/$int_steps*$i-$z]
#		set t1 [expr 1.0*[lindex $charge_den $cnt-1]*$nenner]
#		set t2 [expr 1.0*[lindex $charge_den $cnt]*$nenner]
#		set dA [expr $t1*$dz + $dz*($t2-$t1)/2.0]
#		set sum [expr $sum+$dA]		
#
#		if {$zd	== $z} {break}
#	}
#	lappend pot [expr -$b*($sum+$f*$i]
#}


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

set out [open "$path/sim_params_pot_${U_pot}" "w"]
puts $out "Path:             $path"
puts $out "RunIdent:         $run_ident"
puts $out "random seed:      [t_random seed]"
puts $out "N ion pairs:      $n_ion"
puts $out "box x y z:        [format %.2f $box_h] [format %.2f $box_h] [format %.2f $box_l]\n"
puts $out "Elc-Gap:          $gap"
puts $out "Volume:           $volume"
puts $out "Bjerrum length:   $l_b"
puts $out "Temperature:      $SI_temperature"
puts $out "Constraints:      [constraint]"
puts $out "Voltage:          [lindex $argv 0] V"
puts $out "Average sigma:    $sig_mean"
puts $out "Number of bins:   $nbins"
puts $out "Non cube ratio:   $non_cube_ratio"
puts $out "Wall time:        $hours hours"
puts $out "Integ. Time:      $total_integtime"
puts $out "Total Runtime:    $total_runtime"
close $out

#-------------------------
puts "\n->All done in $total_runtime (Integration time: $total_integtime).\n" ;flush stdout
#-------------------------
