
set schargeList {
	2.094761898338787579e-05
	9.686652694632219823e-04
	1.847437676745168319e-03
	2.746690983943773229e-03
	3.562791387798401078e-03
	4.320978848567951641e-03
	5.074836820700641231e-03
	5.749079977767595877e-03
	6.466320188706282598e-03
	7.104408429924080268e-03
	7.779011603681286989e-03
}

set runs 8
set pot_max 6.0
set num_pots 10.0
set path "$::env(HOME)/git/sim_scripts/jobs/pbsjobs_graphite_CC_explicit"
puts $path
for {set run 1} { $run <= $runs } {incr run} {
	set pbsfname "$path/job_gen_run${run}.pbs"
	set o [open $pbsfname "w"]
	puts $o "#!/bin/bash"
	puts $o "#PBS -N BMIMPF6_Graphite_CCexplicit_run${run}"
	puts $o "#PBS -l mppwidth=[expr int(4*${num_pots})]"
	puts $o "#PBS -l mppnppn=4"
	puts $o "#PBS -l walltime=24:00:00"
	foreach sc $schargeList {
#		puts $o "aprun -n 4 -N 4 \$HOME/git/espresso_git/build/Espresso \$HOME/git/sim_scripts/Sim_graphite_walls_explict.tcl $sc \$HOME/data/graphite_CCexplicit/${run} \$HOME/data/graphite_CCexplicit/${run}/checkpoint_scharge_${sc}.dat &"
		puts $o "aprun -n 4 -N 4 \$HOME/git/espresso_git/build/Espresso \$HOME/git/sim_scripts/Sim_graphite_walls_explicit.tcl $sc \$HOME/data/graphite_CCexplicit/${run} &"
	}
	puts $o "wait"
	puts $o "exit 0"
	close $o
	exec qsub $pbsfname 
	
}
