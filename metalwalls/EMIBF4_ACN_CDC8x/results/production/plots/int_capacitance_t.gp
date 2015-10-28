load 'common.gp'

dp='~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/'

set autos
set yr[100:160]
set xl 't $\mathrm{[ps]}$'
set yl 'Capacitance $\mathrm{[F/g]}$'
set key bottom right

p \
dp.'AV_340K_0ACN_1V/av_wallq.out'  u ($0*20):($1*16080.89) ev 10000 w lp ls 1 lw 5 t '$\mathrm{0\%}$ ACN',\
dp.'AV_340K_10ACN_1V/av_wallq.out' u ($0*20):($1*16080.89) ev 10000 w lp ls 2 lw 5 t '$\mathrm{10\%}$ ACN',\
dp.'AV_340K_20ACN_1V/av_wallq.out' u ($0*20):($1*16080.89) ev 10000 w lp ls 3 lw 5 t '$\mathrm{20\%}$ ACN',\
dp.'AV_340K_40ACN_1V/av_wallq.out' u ($0*20):($1*16080.89) ev 10000 w lp ls 4 lw 5 t '$\mathrm{40\%}$ ACN'
