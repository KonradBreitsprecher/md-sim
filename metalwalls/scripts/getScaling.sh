#!/bin/bash
for i in {7..12}
do
	mpirun -np $i metalwalls
    var="$(grep -F -m 1 'Excluding also the initialization step: ' run.out)"; var=${var:40:40}   
	echo "$i $var" >> scaling.dat
	rm *.out
done


