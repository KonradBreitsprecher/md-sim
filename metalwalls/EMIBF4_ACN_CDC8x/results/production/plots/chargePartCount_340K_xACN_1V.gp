set xl 'Mass percentage ACN'
set yl 'Absolute Particle count'

set yr[0:50]

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/particleCount/pc_340K_xACN_1V.dat' \
   u 1:(0.78*($2-$3))  w lp lw 3 t 'Anode - Excess Ion charge',\
'' u 1:(0.78*($9-$8))  w lp lw 3 t 'Cathode - Excess Ion charge'



#'' u 1:5  w lp lw 3 t 'Bulk - BF4',\
#'' u 1:6  w lp lw 3 t 'Bulk - EMIM',\
#'' u 1:7  w lp lw 3 t 'Bulk - ACN',\
