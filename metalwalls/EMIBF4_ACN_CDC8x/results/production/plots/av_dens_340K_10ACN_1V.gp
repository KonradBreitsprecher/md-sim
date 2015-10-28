load 'common.gp'

set key right height 0.8
set xl 'z $\mathrm{[nm]}$'
set yl 'Total Density $\mathrm{[kg/m^3]}$'

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_10ACN_1V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07+$7*14.01+$8*12.01+$9*15.04)*11205.87) w lp ls 1 lw 2 ps 0.5 t '$\mathrm{10 \% \ Acetonitrile \ 1V}$' 
