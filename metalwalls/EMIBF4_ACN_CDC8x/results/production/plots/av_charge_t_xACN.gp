load 'common.gp'

dp="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/"

set autos
set yr[0.005:0.012]
set xl 't $\mathrm{[ps]}$'
set yl 'Surface Charge per Carbon $\mathrm{[e]}$'

p \
dp.'AV_340K_10ACN_1V/av_wallq.out' u :1 ev 500 w l lw 3 t '$\mathrm{q_c(t) \ 10\%}$ ACN'
