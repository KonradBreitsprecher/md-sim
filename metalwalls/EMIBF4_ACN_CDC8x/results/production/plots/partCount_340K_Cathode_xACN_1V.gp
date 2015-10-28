load 'common.gp'

set xl 'Acetonitrile concentration $\mathrm{[\% \ mass]}$'
set yl 'Average particle count in pores'

set autos
set yr [0:260]

set key left Left width -1  

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/particleCount/pc_340K_xACN_1V.dat' \
   u 1:8  w lp ls 1 lw 5 ps 3 t 'Cathode - BF4',\
'' u 1:9  w lp ls 2 lw 5 ps 3 t 'Cathode - EMIM',\
'' u 1:10 w lp ls 3 lw 5 ps 3 t 'Cathode - ACN'
