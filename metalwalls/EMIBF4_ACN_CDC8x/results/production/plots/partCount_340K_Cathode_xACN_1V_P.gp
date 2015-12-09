load 'common_p.gp'

set xl '\huge Acetonitrile Concentration [wt \%]'
set yl '\huge Particle Count in \underline{Cathode}'

set autos
set yr [0:260]

set key left Left width 0 spacing 1.5 

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/particleCount/pc_340K_xACN_1V.dat' \
   u 1:8  w lp ls 1 lw 7 ps 4 t '\large BF4',\
'' u 1:9  w lp ls 2 lw 7 ps 4 t '\large EMIM',\
'' u 1:10 w lp ls 3 lw 5 ps 4 t '\large ACN'
