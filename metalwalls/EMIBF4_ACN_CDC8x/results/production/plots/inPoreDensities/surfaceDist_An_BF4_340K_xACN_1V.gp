dl0= "~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/inPoreDensitiesL/"
dr0= "~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/inPoreDensitiesR/"
dl10="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_10ACN_1V/inPoreDensitiesL/"
dr10="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_10ACN_1V/inPoreDensitiesR/"
dl20="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_20ACN_1V/inPoreDensitiesL/"
dr20="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_20ACN_1V/inPoreDensitiesR/"
dl40="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_40ACN_1V/inPoreDensitiesL/"
dr40="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_40ACN_1V/inPoreDensitiesR/"

set term x11 0
set xl 'Distance from surface [A]'
set yl 'Density [bohr^-3]'

p \
dl0.'surface_density.out1' u ($1/1.8897):2 w lp t 'Anode - BF4 in-pore profile 340K 0ACN 1V',\
dl10.'surface_density.out1' u ($1/1.8897):2 w lp t 'Anode - BF4 in-pore profile 340K 10ACN 1V',\
dl20.'surface_density.out1' u ($1/1.8897):2 w lp t 'Anode - BF4 in-pore profile 340K 20ACN 1V',\
dl40.'surface_density.out1' u ($1/1.8897):2 w lp t 'Anode - BF4 in-pore profile 340K 40ACN 1V'

