load 'common.gp'

set xl 'Acetonitrile concentration $\mathrm{[\% \ mass]}$'
set yl 'Average particle count in pores'

set autos
set yr [0:260]

set key left Left width -1 

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/particleCount/pc_340K_xACN_1V.dat' \
   u 1:2  w lp ls 1 lw 5 ps 3 t 'Anode - BF4',\
'' u 1:3  w lp ls 2 lw 5 ps 3 t 'Anode - EMIM',\
'' u 1:4  w lp ls 3 lw 5 ps 3 t 'Anode - ACN'

