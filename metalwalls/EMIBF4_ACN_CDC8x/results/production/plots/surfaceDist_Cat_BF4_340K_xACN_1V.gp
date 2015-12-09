load 'common.gp'

dl0= "~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/inPoreDensitiesL/"
dr0= "~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/inPoreDensitiesR/"
dl10="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_10ACN_1V/inPoreDensitiesL/"
dr10="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_10ACN_1V/inPoreDensitiesR/"
dl20="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_20ACN_1V/inPoreDensitiesL/"
dr20="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_20ACN_1V/inPoreDensitiesR/"
dl40="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_40ACN_1V/inPoreDensitiesL/"
dr40="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_40ACN_1V/inPoreDensitiesR/"
dl67="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_67ACN_1V/inPoreDensitiesL/"
dr67="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_67ACN_1V/inPoreDensitiesR/"

set key Left right width -7 height 0.6
 
set autos
set xr[2.251:7]
set yr[0:0.007]
set xl 'Distance from surface $\mathrm{[A]}$'
set yl 'Density $\mathrm{[A^{-3}]}$'

p \
dr0.'surface_density.out1'  ev :::0::36 u (($1+10.39)/1.8897-2.749):($2*6.7483345) w lp ls 1 lw 5 t 'Cathode - BF4 $0 \%$ ACN 1V',\
dr10.'surface_density.out1' ev :::0::36 u (($1+10.39)/1.8897-2.749):($2*6.7483345) w lp ls 2 lw 5 t 'Cathode - BF4 $10 \%$ ACN 1V',\
dr20.'surface_density.out1' ev :::0::36 u (($1+10.39)/1.8897-2.749):($2*6.7483345) w lp ls 3 lw 5 t 'Cathode - BF4 $20 \%$ ACN 1V',\
dr40.'surface_density.out1' ev :::0::36 u (($1+10.39)/1.8897-2.749):($2*6.7483345) w lp ls 4 lw 5 t 'Cathode - BF4 $40 \%$ ACN 1V',\
dr67.'surface_density.out1' ev :::0::4 u (($1+10.39)/1.8897-2.749):($2*6.7483345) w lp ls 5 lw 5 t 'Cathode - BF4 $67 \%$ ACN 1V'

