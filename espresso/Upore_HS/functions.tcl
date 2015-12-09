proc calc_temperature {} {
    #global deg_free
    global n_ions
	#puts $n_ions
    global kb_kjmol
    set temperature_current [expr [analyze energy kinetic]/((6.0/2.0)*$n_ions)/$kb_kjmol]
    return $temperature_current
}


proc save_energy {file_name} {
	global path
    set energy_file [open "${path}/$file_name" "a"]
    puts $energy_file "[format %.0f [setmd time]]  [analyze energy total] [analyze energy kinetic]"
    close $energy_file
}



proc count_parts_lower {pids} {
	global z_lower
	set number 0
	foreach ion $pids { 
		if {[lindex [part $ion print pos] 2] < $z_lower} {
			incr number
		}
	}
	return $number
}

proc count_parts_upper {pids} {
	global z_upper
	set number 0
	foreach ion $pids { 
		if {[lindex [part $ion print pos] 2] > $z_upper} {
			incr number
		}
	}
	return $number
}

proc count_parts_lower_pb {pids} {
	global z_pb_low1
	global z_pb_low2
	set number 0
	foreach ion $pids {
		set z [lindex [part $ion print pos] 2]
		if {$z > $z_pb_low1 && $z < $z_pb_low2} {
			incr number
		}
	}
	return $number
}

proc count_parts_upper_pb {pids} {
	global z_pb_up1
	global z_pb_up2
	set number 0
	foreach ion $pids {
		set z [lindex [part $ion print pos] 2]
		if {$z > $z_pb_up1 && $z < $z_pb_up2} {
			incr number
		}
	}
	return $number
}

proc ions_in_bulk {} {
	global anionlist
	global cationlist
	global bulk_z_l
	global bulk_z_u
	set number 0
	foreach ion $anionlist { 
		if {([lindex [part $ion print pos] 2] > $bulk_z_l) && ([lindex [part $ion print pos] 2] < $bulk_z_u)} {
			incr number
		}
	}
	foreach ion $cationlist { 
		if {([lindex [part $ion print pos] 2] > $bulk_z_l) && ([lindex [part $ion print pos] 2] < $bulk_z_u)} {
			incr number
		}
	}
	return $number
}

proc temp_il {} {
	set kin_energy 0
	global kb_kjmol
	global m_c
	global m_a
	global anionlist
	global cationlist
	#anions
	foreach ion $anionlist { 
		set kin_energy [expr $kin_energy + [veclensqr [part $ion print v]]]
	}
	set temp_a [expr 0.5*$m_a*$kin_energy/((3.0/2.0)*[llength $anionlist])/$kb_kjmol]
	#cations (with inertia)
	foreach ion $cationlist { 
		set kin_energy [expr $kin_energy + $m_c*[veclensqr [part $ion print v]]]
	}
	set temp_c [expr 0.5*$kin_energy/((6.0/2.0)*[llength $cationlist])/$kb_kjmol]
    return [expr ($temp_a+$temp_c)/2]
}

proc compute_rdf {type1 type2} {
    global rdf_rmin
    global rdf_rmax
    global rdf_bin
    global path
    set drdf [analyze <rdf> $type1 $type2 $rdf_rmin $rdf_rmax $rdf_bin [analyze stored]]
    set data_rdf [lindex $drdf 1]
    set dsize [llength $data_rdf]
    set rlist [list]
    set rdflist [list]
    for {set i 0} {$i <$dsize} {incr i} {
        lappend  rlist [lindex $data_rdf $i 0]
        lappend  rdflist [lindex $data_rdf $i 1]
    }
    set rdf_file [open "$path/rdf_${type1}_${type2}.dat" "w"]
    foreach r $rlist value $rdflist { puts $rdf_file "$r  $value" }

    close $rdf_file
}


#proc compute_msd {} {
#    global n_water
#    global vec_r0
#    set msd 0.0
#    for {set j 0} {$j < $n_water} {incr j} { 
#        set pos [part [expr 4*$j] print pos]
#        set pos0 [lindex $vec_r0 $j]
#        set delta_r [vecsub $pos $pos0]
#        set msd [expr $msd + [veclensqr $delta_r] ]
#    }
#    return [expr $msd/$n_water]
#}

#proc save_traj {} {
#    global n_water
#    global file_path
#    file mkdir "$file_path/traj"
#    set file [open "$file_path/traj/[format %07.0f [setmd time]].dat" w]
#    for {set i 0} {$i < [expr 4*$n_water]} {incr i 4} {
#        puts $file [part [expr $i+1] print pos]
#    }
#    close $file
#}

