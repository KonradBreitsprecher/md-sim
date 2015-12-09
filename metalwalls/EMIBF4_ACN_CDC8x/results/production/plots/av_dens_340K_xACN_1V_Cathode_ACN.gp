load 'common.gp'

d0= "~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_0ACN_1V/"
d10="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_10ACN_1V/"
d20="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_20ACN_1V/"
d40="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_40ACN_1V/"
d67="~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_67ACN_1V/"

set autos
set xr[0:6]
set key left Left height 0.8 width -12
set xl 'z $\mathrm{[nm]}$'
set yl 'Total Density $\mathrm{[kg/m^3]}$'
set title 'Cathode ACN Density'

p \
d10.'av_density.out' u ((301.3203-$1)/18.897): (($7*14.01+$8*12.01+$9*15.04)*11205.87) w lp ls 2 lw 2 ps 0.5 t '$\mathrm{10 \% \ Acetonitrile \ 1V}$',\
d20.'av_density.out' u ((327.65960-$1)/18.897):(($7*14.01+$8*12.01+$9*15.04)*11205.87) w lp ls 3 lw 2 ps 0.5 t '$\mathrm{20 \% \ Acetonitrile \ 1V}$',\
d40.'av_density.out' u ((289.74649-$1)/18.897):(($7*14.01+$8*12.01+$9*15.04)*11205.87) w lp ls 4 lw 2 ps 0.5 t '$\mathrm{40 \% \ Acetonitrile \ 1V}$',\
d67.'av_density.out' u ((444.19902-$1)/18.897):(($7*14.01+$8*12.01+$9*15.04)*11205.87) w lp ls 5 lw 2 ps 0.5 t '$\mathrm{67 \% \ Acetonitrile \ 1V}$'
