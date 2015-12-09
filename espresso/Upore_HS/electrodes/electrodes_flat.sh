#!/bin/bash
# electrode parameters
w=28  #Pore width
gap=80 #Gap between electrodes


#ARGS: LEFT_ELECTRODE RIGHT_ELECTRODE LEFT_WALL RIGHT_WALL
#path to save

#left wall
gmsh $1 -clscale 1.0 -algo front2d


#PID=$!
#sleep 1
#kill $PID




