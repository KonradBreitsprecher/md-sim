set runs 1
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
7.779011603681286989e-03}

for {set run 1} { $run <= $runs } {incr run} {
	foreach sc $schargeList {
		set pbsfname "job_gen_run${run}_scharge${sc}.pbs"
		set o [open $pbsfname "w"]
		puts $o "#!/bin/bash"
		puts $o "#    -N BMIMPF6+GenLj with ${sc}"
#		puts $o "#PBS -j oe"
#		puts $o "#PBS -q medium"
		puts $o "#PBS -l nodes=1:ppn=4,walltime=24:00:00"
		puts $o "/usr/local/bin/mpiexec -np 4 \$HOME/git/espresso/build/src/Espresso \$HOME/git/sim_scripts/Sim_genLJ_walls.tcl $sc constCharge_48/${run}"
		close $o
		exec qsub $pbsfname 
	}
}
