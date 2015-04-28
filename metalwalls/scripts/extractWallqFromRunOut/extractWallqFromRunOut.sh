cd /work/konrad/POROUS/hornetData/PRODUCTION/

for syst in */ ; do
	av_wallq=${syst}av_wallq.out
	rm $av_wallq
	for run in 1 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21; do
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

cp /work/konrad/POROUS/hornetData/PRODUCTION/340K_0ACN_1V/av_wallq.out ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/av_wallq.out
cp /work/konrad/POROUS/hornetData/PRODUCTION/340K_10ACN_1V/av_wallq.out ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_10ACN_1V/av_wallq.out
cp /work/konrad/POROUS/hornetData/PRODUCTION/340K_20ACN_1V/av_wallq.out ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_20ACN_1V/av_wallq.out
cp /work/konrad/POROUS/hornetData/PRODUCTION/340K_40ACN_1V/av_wallq.out ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_40ACN_1V/av_wallq.out
