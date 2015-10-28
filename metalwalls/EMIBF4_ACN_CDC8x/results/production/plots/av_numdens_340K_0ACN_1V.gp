#set term x11 0

set title 'Number densities, 340K 0ACN 1V'
set xl 'z [nm]'
set yl 'Density [1/nm^3]'

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/av_density.out' u ($1/18.897):($3*1.48184711e-4) w lp t 'BF4',\
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/av_density.out' u ($1/18.897):($4*1.48184711e-4) w lp t 'IM1',\
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/av_density.out' u ($1/18.897):($5*1.48184711e-4) w lp t 'IM2',\
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/av_density.out' u ($1/18.897):($6*1.48184711e-4) w lp t 'IM3'
