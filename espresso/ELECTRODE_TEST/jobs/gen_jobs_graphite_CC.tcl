
set schargeList {
	2.0947618983387876e-5
	0.000968665269463222
	0.0018474376767451683
	0.0027466909839437732
	0.003562791387798401
	0.004320978848567952
	0.005749079977767596
	0.006466320188706283
	0.00710440842992408
	0.007779011603681287
}

set runs 8
set pot_max 6.0
set num_pots 10.0
set path "$::env(HOME)/git/sim_scripts/jobs/pbsjobs_graphite_CC"
puts $path
for {set run 1} { $run <= $runs } {incr run} {
	set pbsfname "$path/job_gen_run${run}.pbs"
	set o [open $pbsfname "w"]
	puts $o "#!/bin/bash"
	puts $o "#PBS -N BMIMPF6_Graphite_CC_run${run}"
	puts $o "#PBS -l mppwidth=[expr int(4*${num_pots})]"
	puts $o "#PBS -l mppnppn=4"
	puts $o "#PBS -l walltime=24:00:00"
	foreach sc $schargeList {
		puts $o "aprun -n 4 -N 4 \$HOME/git/espresso_git/build/Espresso \$HOME/git/sim_scripts/Sim_graphite_walls_constCharge.tcl $sc \$HOME/data/Graphite_CC/${run} \$HOME/data/Graphite_CC/${run}/checkpoint_pot_${sc}.dat &"
#		puts $o "aprun -n 4 -N 4 \$HOME/git/espresso_git/build/Espresso \$HOME/git/sim_scripts/Sim_graphite_walls_constCharge.tcl $sc \$HOME/data/Graphite_CC/${run} &"
	}
	puts $o "wait"
	puts $o "exit 0"
	close $o
	exec qsub $pbsfname 
	
}

