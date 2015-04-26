ACNS="0 10 20 40"

for ACN in $ACNS; do
	cd /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/${ACN}ACN/left_cdc/out/
    screen -dmS dens_calc_${ACN} ../../../dens_pls_out < ../idens_local_surf.inpt
	cd /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/${ACN}ACN/right_cdc/out/
    screen -dmS dens_calc_${ACN} ../../../dens_pls_out < ../idens_local_surf.inpt
done
