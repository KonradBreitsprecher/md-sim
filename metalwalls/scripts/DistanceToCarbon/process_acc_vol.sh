ACNS="0 10 20 40"

for ACN in $ACNS; do
	cd /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/${ACN}ACN/left_cdc/out/
	../../../acc_vol_2D < ../input_volume
	cd ../../right_cdc/out/
	../../../acc_vol_2D < ../input_volume
done
