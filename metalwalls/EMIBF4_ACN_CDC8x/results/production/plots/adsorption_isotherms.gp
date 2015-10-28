load 'common.gp'

set xl 'Particle fraction bulk'
set yl 'Particle fraction pore'

set autos
set yr [0:1]

set key right Left width -4

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/particleCount/pc_340K_xACN_1V.dat' \
   u ($5/($5+$6+$7)):($2/($2+$3+$4)) w lp ls 1 lw 5 t 'Anode - BF4'
