cd $HOME/data/EQUI_CP/

for d in */3 ; do
	fname="${d:0: ${#d}-2}_wallq"
	echo $fname
	if [[ $fname == *"_0ACN"* ]]
	then
		grep "Total charge wall species  5" $d/run.out | awk '{print $6/3821}' >> $fname
	else
		grep "Total charge wall species  8" $d/run.out | awk '{print $6/3821}' >> $fname
	fi
done
