set term x11
set xl 'z [nm]'
set yl 'Density [kg/m^3]'

p \
'AV_340K_0ACN_0V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07)*11205.87) w lp t '340K 0ACN 0V Tot. Density',\
'AV_340K_0ACN_1V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07)*11205.87) w lp t '340K 0ACN 1V Tot. Density',\
'AV_340K_0ACN_2V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07)*11205.87) w lp t '340K 0ACN 2V Tot. Density',\
'AV_340K_0ACN_0V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07)*11205.87) w lp t '340K 0ACN 0V Tot. Density' s bez,\
'AV_340K_0ACN_1V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07)*11205.87) w lp t '340K 0ACN 1V Tot. Density' s bez,\
'AV_340K_0ACN_2V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07)*11205.87) w lp t '340K 0ACN 2V Tot. Density' s bez,\
'Density_Bulk_340K_00AN_1bar.xvg' u ($1*0.035):2 t 'NPT Bulk density'

