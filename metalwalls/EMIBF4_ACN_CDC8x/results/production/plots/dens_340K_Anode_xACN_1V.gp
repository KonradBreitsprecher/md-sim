load 'common.gp'

set xl 'Acetonitrile concentration $\mathrm{[\% \ mass]}$'
set yl 'Total Density in pores'

set autos
set yr [0:3000]

set key left Left width -1 

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/particleCount/pc_340K_xACN_1V.dat' \
   u 1:(($2*86.81+$3*111.18+$4*41.06)/15837*1660.539) w lp ls 1 lw 5 ps 3 t 'Anode - Total Mass'

