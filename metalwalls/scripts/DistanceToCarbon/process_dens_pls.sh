ACNS="0 10 20 40"

for ACN in $ACNS; do
	cd /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/${ACN}ACN/left_cdc/out/
    screen -dmS dens_calc_${ACN} ../../../dens_pls_out < ../idens_local_surf.inpt
	cd /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/${ACN}ACN/right_cdc/out/
    screen -dmS dens_calc_${ACN} ../../../dens_pls_out < ../idens_local_surf.inpt
done

#cp /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/0ACN/left_cdc/out/* ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/inPoreDensitiesL/
#cp /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/10ACN/left_cdc/out/* ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_10ACN_1V/inPoreDensitiesL/
#cp /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/20ACN/left_cdc/out/* ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_20ACN_1V/inPoreDensitiesL/
#cp /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/40ACN/left_cdc/out/* ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_40ACN_1V/inPoreDensitiesL/

#cp /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/0ACN/right_cdc/out/* ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/inPoreDensitiesR/
#cp /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/10ACN/right_cdc/out/* ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_10ACN_1V/inPoreDensitiesR/
#cp /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/20ACN/right_cdc/out/* ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_20ACN_1V/inPoreDensitiesR/
#cp /home/konrad/git/md-sim/metalwalls/scripts/DistanceToCarbon/40ACN/right_cdc/out/* ~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_40ACN_1V/inPoreDensitiesR/
