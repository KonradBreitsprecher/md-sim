set runs 8
set pot_max 6.0
set num_pots 10.0
set path "$::env(HOME)/git/sim_scripts/jobs/pbsjobs_graphite_elcic"
puts $path
for {set run 1} { $run <= $runs } {incr run} {
	set pbsfname "$path/job_gen_run${run}.pbs"
	set o [open $pbsfname "w"]
	puts $o "#!/bin/bash"
	puts $o "#PBS -N BMIMPF6_graphite_elcic${run}"
	puts $o "#PBS -l mppwidth=[expr 4*int(${num_pots})]"
	puts $o "#PBS -l mppnppn=4"
	puts $o "#PBS -l walltime=24:00:00"
	for {set i 0} { $i <= $num_pots } {incr i} {
		set pot [expr $i/$num_pots*$pot_max]
#		puts $o "aprun -n 1 -N 1 \$HOME/git/espresso_git/build/Espresso \$HOME/git/sim_scripts/Sim_graphite_walls_icc.tcl $pot \$HOME/data/graphite_icc/${run} \$HOME/data/graphite_icc/${run}/checkpoint_pot_${pot}.dat &"
		puts $o "aprun -n 4 -N 4 \$HOME/git/espresso_git/build/Espresso \$HOME/git/sim_scripts/Sim_graphite_walls_elcic.tcl $pot \$HOME/data/graphite_elcic/${run} \$HOME/data/graphite_elcic/${run}/checkpoint_pot_${pot}.dat &"
	}
	puts $o "wait"
	puts $o "exit 0"
	close $o
	exec qsub $pbsfname 
	
}


