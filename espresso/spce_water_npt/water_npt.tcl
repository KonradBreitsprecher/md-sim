#Units
# Sim. Unit [1]		Physical Unit
# Length            1*10^(-10) m (Angstrom)
# Mass				gramm/mol resp. u (atom mass unit)
# Energy			kJ/mol
# Time 				1*10^(-13) s  // Angstrom*sqrt(g/kJ)
# Charge			1*e (elementary charge)

#System parameters
set n_water 250
set rho_si 1.0; #g/cm^3 
set temperature_si 277;#277.0
set p_ext_si 101325; #Pa //101325 standard pressure; equil. at 1.153e9
set piston_mass_u 1

#Physical constants, unit conversion
set N_A 6.022141e23
set kb_kjmol 0.0083145  
set rho_factor 0.03346 ;# molecules/Angstrom^3 for rho=1g/cm^3
set p_factor 6.022e-10; #kJ/(mol*Angstrom^3)

#Simulation parameters
set integ_steps 100
set integ_loops 20000
setmd time_step 0.02 
setmd skin 0.3
set method "p3m"
set path "output"
#langevin thermostat
set gamma 1.0
#barostat
set gamma0 1.0;  #equals langevin-gamma 
set gammaV [expr $piston_mass_u*$gamma0]
#Warmup
set force_cap 20
set warm_steps 50
set warm_integ_steps 100
#Random Seed
t_random seed [pid] [pid] [pid] [pid] [pid] [pid] [pid] [pid]

#Compute remaining parameters
set temperature [expr $temperature_si*$kb_kjmol]
puts "Reduced temperature: [format %.3f $temperature]"

#Bjerrum Length
set l_b [expr 2088.76/$temperature_si]
puts "l_b: $l_b Angstrom"

# Setup system geometry in Espresso
set box_l [expr pow(($n_water/($rho_si*$rho_factor)),1/3.)]
puts "Box Length: $box_l"
setmd box_l $box_l $box_l $box_l
setmd periodic 1 1 1

#####################################
#####################################

#Particle types and attributes
set type_water_com 0

set rinertia_xx 1.926;  #u*Angstrom^2=g/mol*Angstrom^2
set rinertia_yy 1.332
set rinertia_zz 1.398

set type_O 1
set type_H1 2
set type_H2 3

set m_oxygen 16.0; #g/mol
set m_hydrogen 1.0

set q_O -0.8476; #e
set q_H 0.4238

set pos_O_bodyframe_y  0.0642; #Angstrom
set pos_O_bodyframe_z  0.0
set pos_H1_bodyframe_y -0.5136
set pos_H1_bodyframe_z 0.8161
set pos_H2_bodyframe_y -0.5136
set pos_H2_bodyframe_z -0.8161

setmd min_global_cut 1.0

#################
# Place particles
for {set j 0} { $j < [expr 4*$n_water] } {incr j 4} {

    #RANDOM POSITIONS FOR THE CENTER OF MASS
    set posx [expr $box_l*[t_random]] 
    set posy [expr $box_l*[t_random]] 
    set posz [expr $box_l*[t_random]] 
    
   #WATER CENTER OF MASS: NON-VIRTUAL    
   part $j pos $posx $posy $posz type $type_water_com rinertia $rinertia_xx $rinertia_yy $rinertia_zz mass [expr $m_oxygen + 2.0*$m_hydrogen] 
   #WATER O: VIRTUAL
   part [expr $j +1] pos $posx [expr $posy + $pos_O_bodyframe_y] $posz type $type_O virtual 1 q $q_O vs_auto_relate_to $j
   #WATER H1: VIRTUAL
   part [expr $j +2] pos $posx [expr $posy + $pos_H1_bodyframe_y] [expr $posz + $pos_H1_bodyframe_z] type $type_H1 q $q_H virtual 1 vs_auto_relate_to $j
   #WATER H2: VIRTUAL
   part [expr $j +3] pos $posx [expr $posy + $pos_H2_bodyframe_y] [expr $posz + $pos_H2_bodyframe_z] type $type_H2  q $q_H virtual 1 vs_auto_relate_to $j
}

puts "Successfully set up particles"
puts "Mindist: [format %.2f [analyze mindist $type_water_com $type_water_com]]"

##################
#LJ Interactions (only between the non-virtual mass-centers), wikipedia
set lj_sig 3.17; #Angstrom
set lj_eps 0.651; #kJ/mol

set lj_cut [expr 1.12246*$lj_sig]
set lj_shift [expr 0.25*$lj_eps]

inter $type_O $type_O lennard-jones $lj_eps $lj_sig $lj_cut $lj_shift 0
#puts "Potential: LJ, sig: $lj_sig, eps: $lj_eps"


#vmd data
set vmdfile [open "$path/data.vtf" "w"]
writevsf $vmdfile
writevcf $vmdfile

#Set degrees of freedom
if { [regexp "ROTATION" [code_info]] } {
    set deg_free 6
} {
    set deg_free 3
}

#prepare_vmd_connection "vmd_startscript" 10000

###########
#Warmup
thermostat langevin $temperature $gamma
puts "Warmup $warm_integ_steps steps"
for {set i 0} {$i < $warm_steps} {incr i 1} {
    set cap [expr $force_cap*1.2]
    set rho_final_si [expr $n_water/(pow([lindex [setmd box_l] 0],3)*$rho_factor)]
    puts -nonewline "t=[format %.1f [setmd time]] E=[format %.2f [analyze energy total]] boxl: [format %.4f [lindex [setmd box_l] 0]], rho: [format %.5f $rho_final_si] Mindist: [format %.2f [analyze mindist $type_water_com $type_water_com]] \r"
    flush stdout
    inter forcecap $force_cap
    integrate $warm_integ_steps
    imd positions
    #writevcf $vmdfile
   
}
puts "\rFinished warmup:"
puts "t=[format %.1f [setmd time]] E=[format %.2f [analyze energy total]] Mindist: [format %.2f [analyze mindist $type_water_com $type_water_com]]"

#############
#Activate Coulomb interactions
puts "Activate coulomb interactions"
puts [inter coulomb $l_b p3m tunev2 accuracy 1e-4]  
#puts [inter coulomb 10.0 p3m tunev2 accuracy 1e-3 mesh 32]
set p3m_params [inter coulomb]
foreach f $p3m_params { eval inter $f }

#Activate Barostatic Integrator
#x:y:z: verhaeltnis
#integrate set npt_isotropic [expr $p_ext_si*$p_factor] $piston_mass_u 
puts "Target Pressure from SI [expr $p_ext_si*$p_factor]"
integrate set npt_isotropic 0.7 $piston_mass_u 
#puts "Barostatic Integrator: [integrate set]"

#Activate Isotropic NPT Thermostat  
thermostat npt_isotropic $temperature $gamma0 $gammaV
#thermostat langevin $temperature $gamma

###############
#Integrate
inter forcecap 0

puts "Start integrating\r"
for {set i 0} { $i < $integ_loops } { incr i} {
    integrate $integ_steps
    imd positions
    set rho_final_si [expr $n_water/(pow([lindex [setmd box_l] 0],3)*$rho_factor)]
    set temperature_current [expr [analyze energy kinetic]/(($deg_free/2.0)*$n_water)/$kb_kjmol]
	#set pressure_atm [expr [analyze pressure total]/$p_factor/$p_ext_si]
	set pressure_atm [analyze pressure total]
	puts "t [format %.1f [setmd time]] P [format %.2f $pressure_atm] T [format %.2f $temperature_current] E [format %.2f [analyze energy total]] boxl [format %.4f [lindex [setmd box_l] 0]] rho [format %.5f $rho_final_si] mindist [format %.2f [analyze mindist $type_water_com $type_water_com]] \r"
#puts "t [format %.1f [setmd time]] T [format %.2f $temperature_current] E [format %.2f [analyze energy total]] boxl [format %.4f [lindex [setmd box_l] 0]] rho [format %.5f $rho_final_si] mindist [format %.2f [analyze mindist $type_water_com $type_water_com]] \r"
    flush stdout
    #writevcf $vmdfile 
}

close $vmdfile
puts "t=[format %.1f [setmd time]] E=[analyze energy total]"



