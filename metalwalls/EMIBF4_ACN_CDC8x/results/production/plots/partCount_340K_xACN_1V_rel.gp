load 'common.gp'

set xl 'Acetonitrile bulk concentration $\mathrm{[\% \ mass]}$'
set yl 'Acetonitrile electrode concentration $\mathrm{[\% \ mass]}$'

set autos
set yr[0:100]
set key right Left width -2

#p \
#'~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/particleCount/pc_340K_xACN_1V.dat' \
#   u 1:($4*41.06/($4*41.06+$2*86.81+$3*111.18)*100)  w lp ls 1 lw 7 t 'Anode - ACN mass \%',\
#'' u 1:(($3*111.18)/($4*41.06+$2*86.81+$3*111.18)*100)  w lp ls 2 lw 7 t 'Anode - EMIM mass \%',\
#'' u 1:(($2*86.81)/($4*41.06+$2*86.81+$3*111.18)*100)  w lp ls 3 lw 7 t 'Anode - BF4 mass \%',\
#'' u 1:($10*41.06/($10*41.06+$8*86.81+$9*111.18)*100)  w lp ls 4 lw 7 t 'Cathode - ACN mass \%',\
#'' u 1:(($9*111.18)/($10*41.06+$8*86.81+$9*111.18)*100)  w lp ls 5 lw 7 t 'Cathode - EMIM mass \%',\
#'' u 1:(($8*86.81)/($10*41.06+$8*86.81+$9*111.18)*100)  w lp ls 6 lw 7 t 'Cathode - BF4 mass \%',\
#'' u 1:($7*41.06/($7*41.06+$5*86.81+$6*111.18)*100)  w lp ls 7 lw 7 t 'Bulk - ACN mass \%',\
#'' u 1:(($6*111.18)/($7*41.06+$5*86.81+$6*111.18)*100)  w lp ls 8 lw 7 t 'Bulk - EMIM mass \%',\
#'' u 1:(($5*86.81)/($7*41.06+$5*86.81+$6*111.18)*100)  w lp ls 9 lw 7 t 'Bulk - BF4 mass \%'

p '~/git/md-sim/metalwalls/EMIBF4_ACN_CDC8x/results/production/data/particleCount/pc_340K_xACN_1V.dat' \
   u 1:($4 /($4+$2+$3) *100)  w lp ls 1 lw 2 ps 2 t 'Anode - ACN number \%',\
'' u 1:($3 /($4+$2+$3) *100)  w lp ls 2 lw 2 ps 2 t 'Anode - EMIM number \%',\
'' u 1:($2 /($4+$2+$3) *100)  w lp ls 3 lw 2 ps 2 t 'Anode - BF4 number \%',\
'' u 1:($10/($10+$8+$9)*100)  w lp ls 4 lw 2 ps 2 t 'Cathode - ACN number \%',\
'' u 1:($9 /($10+$8+$9)*100)  w lp ls 5 lw 2 ps 2 t 'Cathode - EMIM number \%',\
'' u 1:($8 /($10+$8+$9)*100)  w lp ls 6 lw 2 ps 2 t 'Cathode - BF4 number \%',\
'' u 1:($7 /($7+$5+$6) *100)  w lp ls 7 lw 2 ps 2 t 'Bulk - ACN number \%',\
'' u 1:($6 /($7+$5+$6) *100)  w lp ls 8 lw 2 ps 2 t 'Bulk - EMIM number \%',\
'' u 1:($5 /($7+$5+$6) *100)  w lp ls 9 lw 2 ps 2 t 'Bulk - BF4 number \%'


#     u 1:($4/$7*100)  w lp ls 2 lw 7 t 'Anode - ACN/ACN_{Bulk}'
#    u 1:(($4)*41.06/(($2)*86.81+($3)*111.18)*100)  w lp ls 2 lw 7 t 'Anode - ACN/Total',\
#''  u 1:(($7)*41.06/(($5)*86.81+($6)*111.18)*100)  w lp ls 3 lw 7 t 'Bulk - ACN/Total'
#   u 1:(($4+$7+$10)*41.06/(($2+$5+$8)*86.81+($3+$6+$9)*111.18)*100)  w lp ls 2 lw 7 t 'Total - ACN/BF4'
#   u 1:($7*41.06/($5*86.81+$6*111.18)*100)  w lp ls 2 lw 7 t 'Bulk    - ACN/BF4'
#   u 1:($4/$2)  w lp ls 1 lw 7 t 'Anode   - ACN/BF4',\
#'' u 1:($10/$8) w lp ls 3 lw 7 t 'Cathode - ACN/BF4'
