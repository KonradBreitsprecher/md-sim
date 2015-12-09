load 'common_p.gp'

dp='~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/'

set autos
set yr[0:180]
set xl '\huge Acetonitrile Concentration [wt \%]'
set yl '\huge Capacitance $\mathrm{[F/g]}$'
set key top right height 1

p dp.'cap_acn.dat' u 1:2 w lp ls 1 lw 7 ps 5 t '\large Simulation Results'

