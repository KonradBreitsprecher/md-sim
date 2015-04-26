set term x11 enhanced font "Arial,20" 

dp="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/"

set xl "t [ps]"
set yl "Surface Charge per Carbon [e]"

p \
dp.'AV_340K_0ACN_1V/av_wallq.out' u :($1) ev 500 w l lw 3 t "q_c(t) 0\% ACN",\
dp.'AV_340K_10ACN_1V/av_wallq.out' u :($1) ev 500 w l lw 3 t "q_c(t) 10\% ACN",\
dp.'AV_340K_20ACN_1V/av_wallq.out' u :($1) ev 500 w l lw 3 t "q_c(t) 20\% ACN",\
dp.'AV_340K_40ACN_1V/av_wallq.out' u :($1) ev 500 w l lw 3 t "q_c(t) 40\% ACN"
