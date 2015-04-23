cd /work/konrad/POROUS/hornetData/PRODUCTION/

for syst in */ ; do
	av_wallq=${syst}av_wallq.out
	rm $av_wallq
	for run in 6 7 8; do
		d=$syst$run
		fname="$d/wall_q_from_run.out"
		rm $fname
		echo $fname
		if [[ $fname == *"_0ACN"* ]]
		then
			grep "Total charge wall species  5" $d/run.out | awk '{print $6/3821}' >> $fname
		else
			grep "Total charge wall species  8" $d/run.out | awk '{print $6/3821}' >> $fname
		fi
		cat $fname >> $av_wallq
	done
	echo "Written $av_wallq"
done
