set term x11
set xl 'z [nm]'
set yl 'Density [kg/m^3]'

p \
'AV_340K_67ACN_0V/density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07+$7*14.01+$8*12.01+$9*15.04)*11205.87) w lp t '340K 67ACN 0V Tot. Density',\
'Density_Bulk_67AN_Drop_1bar.xvg' u ($1*0.1):2 t 'Bulk density'
