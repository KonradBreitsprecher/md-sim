
set runs 8
set pot_max 6.0
set num_pots 10.0
set path "$::env(HOME)/git/sim_scripts/jobs/pbsjobs_genlj_elcic3"
puts $path
for {set run 1} { $run <= $runs } {incr run} {
	set pbsfname "$path/job_gen_run${run}.pbs"
	set o [open $pbsfname "w"]
	puts $o "#!/bin/bash"
	puts $o "#PBS -N BMIMPF6_GenLJ_ELCIC_run${run}"
	puts $o "#PBS -l mppwidth=[expr int(4*${num_pots})]"
	puts $o "#PBS -l mppnppn=4"
	puts $o "#PBS -l walltime=24:00:00"
	for {set i 0} { $i <= $num_pots } {incr i} {
		set pot [expr $i/$num_pots*$pot_max]
		set U_pot [expr $pot/0.01036427]
		puts $o "aprun -n 4 -N 4 \$HOME/git/espresso_git/build/Espresso \$HOME/git/sim_scripts/Sim_genLJ_walls_constPot.tcl $pot \$HOME/data/genLJ_elcic/${run} \$HOME/data/genLJ_elcic/${run}/checkpoint_pot_${U_pot}.dat &"
	}
	puts $o "wait"
	puts $o "exit 0"
	close $o
	exec qsub $pbsfname 
	
}


