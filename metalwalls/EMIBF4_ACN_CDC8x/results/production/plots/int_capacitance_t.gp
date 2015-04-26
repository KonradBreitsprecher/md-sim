dp="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/"

set xl "t [ps]"
set yl "C [F/g]"

p \
dp.'AV_340K_0ACN_1V/av_wallq.out' u :($1*16080.89) ev 500 w lp t "Capacitance(t) 0\% ACN",\
dp.'AV_340K_10ACN_1V/av_wallq.out' u :($1*16080.89) ev 500 w lp t "Capacitance(t) 10\% ACN",\
dp.'AV_340K_20ACN_1V/av_wallq.out' u :($1*16080.89) ev 500 w lp t "Capacitance(t) 20\% ACN",\
dp.'AV_340K_40ACN_1V/av_wallq.out' u :($1*16080.89) ev 500 w lp t "Capacitance(t) 40\% ACN",\
