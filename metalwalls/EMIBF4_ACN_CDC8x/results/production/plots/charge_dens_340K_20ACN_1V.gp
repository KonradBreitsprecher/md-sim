load 'common.gp'

set key right height 0.8
set xzeroaxis
set xr[0:17.3]
set yr[-2.8:2.8]
set xl 'z $\mathrm{[nm]}$'
set yl 'Charge Density $\mathrm{[e/nm^3]}$'

set style rect fc lt -1 fs solid 0.15 noborder back
set grid nocbtics front
set obj rect from 0, graph 0 to 4.8, graph 1
set obj rect from 12.4, graph 0 to graph 1, graph 1

set label 1 at graph 0.02, graph 0.04 'Left electrode' left front
set label 2 at graph 0.5, graph 0.04 'Bulk' center front
set label 3 at graph 0.98, graph 0.04 'Right electrode' right front

p \
'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/AV_340K_20ACN_1V/av_density.out' u ($1/18.897):(($3*-0.78+$4*0.3591+$5*0.1888+$6*0.2321+$7*-0.398+$8*0.129+$9*0.269)*6748.3345) w lp ls 1 lw 2  lc rgb'#00a092' ps 0.5 t '$\mathrm{20 \% \ Acetonitrile \ 1V}$'
