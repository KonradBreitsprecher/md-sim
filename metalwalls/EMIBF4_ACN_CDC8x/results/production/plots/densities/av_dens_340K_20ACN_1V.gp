set term x11 0
set xl 'z [nm]'
set yl 'Density [kg/m^3]'

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_20ACN_1V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07+$7*14.01+$8*12.01+$9*15.04)*11205.87) w lp t '340K 20ACN 1V Tot. Density'
