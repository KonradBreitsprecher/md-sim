set term x11
set xl 'z [nm]'
set yl 'Density [kg/m^3]'

p \
'AV_298K_40ACN_0V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07+$7*14.01+$8*12.01+$9*15.04)*11205.87) w lp t '298K 40ACN 0V Tot. Density',\
'AV_298K_40ACN_1V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07+$7*14.01+$8*12.01+$9*15.04)*11205.87) w lp t '298K 40ACN 1V Tot. Density',\
'AV_298K_40ACN_2V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07+$7*14.01+$8*12.01+$9*15.04)*11205.87) w lp t '298K 40ACN 2V Tot. Density',\
'AV_298K_40ACN_0V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07+$7*14.01+$8*12.01+$9*15.04)*11205.87) w lp t '298K 40ACN 0V Tot. Density' s bez,\
'AV_298K_40ACN_1V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07+$7*14.01+$8*12.01+$9*15.04)*11205.87) w lp t '298K 40ACN 1V Tot. Density' s bez,\
'AV_298K_40ACN_2V/av_density.out' u ($1/18.897):(($3*86.81+$4*67.7+$5*15.04+$6*29.07+$7*14.01+$8*12.01+$9*15.04)*11205.87) w lp t '298K 40ACN 2V Tot. Density' s bez,\
'Density_Bulk_298K_40AN_1bar.xvg' u ($1*0.035):2 t 'NPT Bulk density'

