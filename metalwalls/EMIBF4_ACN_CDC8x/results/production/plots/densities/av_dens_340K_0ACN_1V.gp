set term x11 0
set xl 'z [nm]'
set yl 'Density [kg/m^3]'

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07)*11205.87) w lp t '340K 0ACN 0V Tot. Density'
