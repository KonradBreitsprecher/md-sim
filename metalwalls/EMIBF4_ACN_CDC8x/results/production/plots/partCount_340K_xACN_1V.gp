set xl 'Mass percentage ACN'
set yl 'Absolute Particle count'
p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/particleCount/pc_340K_xACN_1V.dat' \
   u 1:2  w lp lw 3 t 'Anode - BF4',\
'' u 1:3  w lp lw 3 t 'Anode - EMIM',\
'' u 1:4  w lp lw 3 t 'Anode - ACN',\
'' u 1:8  w lp lw 3 t 'Cathode - BF4',\
'' u 1:9  w lp lw 3 t 'Cathode - EMIM',\
'' u 1:10 w lp lw 3 t 'Cathode - ACN'


#'' u 1:5  w lp lw 3 t 'Bulk - BF4',\
#'' u 1:6  w lp lw 3 t 'Bulk - EMIM',\
#'' u 1:7  w lp lw 3 t 'Bulk - ACN',\
