load 'common.gp'

dp='~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/'

set autos
set yr[0:180]
set xl 'Mass percentage Acetonitrile'
set yl 'Capacitance $\mathrm{[F/g]}$'
set key top right height 1

p dp.'cap_acn.dat' u 1:2 w lp ls 1 lw 5 ps 3 t 'Simulations',\
  	 		    '' u 1:3 w lp ls 3 lw 5 ps 3 t 'Experiments (CV)'

