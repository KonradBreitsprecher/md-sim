RUNS="6 7 8 9 10 11 12"
ACNS="40"
#ACNS="0 10 20 40"

PART_NUM[0]=10442
PART_NUM[10]=11412
PART_NUM[20]=12673
PART_NUM[40]=12490

for ACN in $ACNS; do
	cd /work/konrad/POROUS/processedData/position_out/340K_${ACN}ACN_1V
	echo "PROCESSING $ACN ACN, RUNS $RUNS"
	for i in $RUNS; do 
		cp ../../../hornetData/PRODUCTION/340K_${ACN}ACN_1V/$i/positions.out $i/
		PN=${PART_NUM[$ACN]}
		POS_NL=$(wc -l < $i/positions.out)
		MOD_NL=$(bc <<< "$POS_NL%$PN")
		#echo "Remove $MOD_NL Lines"
		NUM_CONF=$(bc <<< "($POS_NL-$MOD_NL)/$PN")
		#echo "NUM_CONF=$NUM_CONF"
		head -n -$MOD_NL $i/positions.out > tmpfile
		cat tmpfile > $i/positions.out
		rm tmpfile
		realpath $i/positions.out
		echo $NUM_CONF
	done
done
