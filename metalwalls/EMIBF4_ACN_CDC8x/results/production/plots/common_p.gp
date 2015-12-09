set term epslatex color 
set out "gnuout.tex"
set size 1.2,1.2
set rmargin 0
set lmargin 5
set bmargin 4

# new styles for pstex
#set termoption dashed
set termoption linewidth 1.5 
set size ratio 0.75
# filled-open, R-G-B, lighter-darker
set style line  1 lt  1 lc rgb "#ea6d00" lw 1.0 pt  7 ps 1.26 # circles
set style line  2 lt  2 lc rgb "#00ea92" lw 1.0 pt  6 ps 1.2 
set style line  3 lt  3 lc rgb "#0082ea" lw 1.0 pt  9 ps 1.26 # triangles
set style line  4 lt  4 lc rgb "#ea0000" lw 1.0 pt  8 ps 1.2 
set style line  5 lt  5 lc rgb "#a6ea00" lw 1.0 pt 13 ps 1.37 # diamonds
set style line  6 lt  6 lc rgb "#1d00ea" lw 1.0 pt 12 ps 1.3 
set style line  7 lt  7 lc rgb "#eaba00" lw 1.0 pt 11 ps 1.26 # reverse triangles
set style line  8 lt  8 lc rgb "#9600ea" lw 1.0 pt 10 ps 1.2 
set style line  9 lt  9 lc rgb "#00d4ea" lw 1.0 pt  5 ps 1.16 # squares
set style line 10 lt 10 lc rgb "#ea00db" lw 1.0 pt  4 ps 1.1 
set style line 11 lt  1 lc rgb "#000000" lw 1.0 # solid black line

set style line 12 lt  1 lc rgb "#ea6d00" lw 1.0 pt  7 ps 1.26 # circles
set style line 13 lt  1 lc rgb "#00ea92" lw 1.0 pt  6 ps 1.2 
set style line 14 lt  1 lc rgb "#0082ea" lw 1.0 pt  9 ps 1.26 # triangles
set style line 15 lt  1 lc rgb "#ea0000" lw 1.0 pt  8 ps 1.2 
set style line 16 lt  1 lc rgb "#a6ea00" lw 1.0 pt 13 ps 1.37 # diamonds
set style line 17 lt  1 lc rgb "#1d00ea" lw 1.0 pt 12 ps 1.3 
set style line 18 lt  1 lc rgb "#eaba00" lw 1.0 pt 11 ps 1.26 # reverse triangles
set style line 19 lt  1 lc rgb "#9600ea" lw 1.0 pt 10 ps 1.2 
set style line 20 lt  1 lc rgb "#00d4ea" lw 1.0 pt  5 ps 1.16 # squares
set style line 21 lt  1 lc rgb "#ea00db" lw 1.0 pt  4 ps 1.1 

set xlabel offset 0,-0.5 
set ylabel offset -0.5,0
set tics format "$%g$"

