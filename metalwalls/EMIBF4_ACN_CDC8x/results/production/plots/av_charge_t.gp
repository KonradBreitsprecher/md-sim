load 'common.gp'

dp="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/"

set autos
set yr[0.0:0.011]
set xl 't $\mathrm{[ns]}$'
set yl 'Surface Charge per Carbon $\mathrm{[e]}$'
set key right bottom

p \
dp.'AV_340K_0ACN_1V/av_wallq.out'  u ($0*2e-6*1000):1 ev 1000 w l lw 3 t '$\mathrm{q_c(t) \ \ \ 0\%}$ ACN',\
dp.'AV_340K_10ACN_1V/av_wallq.out' u ($0*2e-6*1000):1 ev 1000 w l lw 3 t '$\mathrm{q_c(t) \ 10\%}$ ACN',\
dp.'AV_340K_20ACN_1V/av_wallq.out' u ($0*2e-6*1000):1 ev 1000 w l lw 3 t '$\mathrm{q_c(t) \ 20\%}$ ACN',\
dp.'AV_340K_40ACN_1V/av_wallq.out' u ($0*2e-6*1000):1 ev 1000 w l lw 3 t '$\mathrm{q_c(t) \ 40\%}$ ACN',\
dp.'AV_340K_67ACN_1V/av_wallq.out' u ($0*2e-6*1000):1 ev 1000 w l lw 3 t '$\mathrm{q_c(t) \ 67\%}$ ACN'
