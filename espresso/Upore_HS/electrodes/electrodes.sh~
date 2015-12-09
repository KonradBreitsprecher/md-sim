#!/bin/bash
# electrode parameters
w=18  #Pore width
d=40 #Pore depth
e1=4 #Edge radius pore exit
e2=2 #Edge radius pore floor
b=25 #Embedded plane edge length
rim=10 #Rim
gap=50 #Gap between electrodes


#ARGS: LEFT_ELECTRODE RIGHT_ELECTRODE LEFT_WALL RIGHT_WALL
#path to save
path='output'

#left icc electrode
sed "s/width/$w/; s/depth/$d/; s/edge_radius1/$e1/; s/edge_radius2/$e2/; s/plane_length/$b/; s/rim_replace/$rim/; s/l_replace/$l/; s/gap_replace/$gap/; s/path/$path/" $1 > $1.temp
gmsh $1.temp -clscale 2.9 -algo front2d

#right icc electrode
sed "s/width/$w/; s/depth/$d/; s/edge_radius1/$e1/; s/edge_radius2/$e2/; s/plane_length/$b/; s/rim_replace/$rim/; s/l_replace/$l/; s/gap_replace/$gap/; s/path/$path/" $2 > $2.temp
gmsh $2.temp -clscale 2.9 -algo front2d

#left wall
sed "s/width/$w/; s/depth/$d/; s/edge_radius1/$e1/; s/edge_radius2/$e2/; s/plane_length/$b/; s/rim_replace/$rim/; s/l_replace/$l/; s/gap_replace/$gap/; s/offset_x_replace/$offset_x/; s/offset_y_replace/$offset_y/; s/path/$path/" $3 > $3.temp
#gmsh $3.temp -clscale 5.3 -algo front2d

#right wall
sed "s/width/$w/; s/depth/$d/; s/edge_radius1/$e1/; s/edge_radius2/$e2/; s/plane_length/$b/; s/rim_replace/$rim/; s/l_replace/$l/; s/gap_replace/$gap/; s/offset_x_replace/$offset_x/; s/offset_y_replace/$offset_y/; s/path/$path/" $4 > $4.temp
#gmsh $4.temp -clscale 5.3 -algo front2d

rm *.temp

#PID=$!
#sleep 1
#kill $PID




