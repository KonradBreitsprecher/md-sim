load 'common.gp'

set xl 'Acetonitrile concentration $\mathrm{[\% \ mass]}$'
set yl 'Average particle count'

set autos
set yr [0:160]

set key right Left width -4

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/particleCount/pc_340K_xACN_1V.dat' \
   u 1:2  w lp ls 1 lw 7 t 'Anode - BF4',\
'' u 1:3  w lp ls 2 lw 7 t 'Anode - EMIM',\
'' u 1:8  w lp ls 4 lw 7 t 'Cathode - BF4',\
'' u 1:9  w lp ls 5 lw 7 t 'Cathode - EMIM',\

#'' u 1:4  w lp ls 3 lw 7 t 'Anode - ACN',\
#'' u 1:10 w lp ls 6 lw 7 t 'Cathode - ACN'

#'' u 1:5  w lp lw 7 t 'Bulk - BF4',\
#'' u 1:6  w lp lw 7 t 'Bulk - EMIM',\
#'' u 1:7  w lp lw 7 t 'Bulk - ACN',\
