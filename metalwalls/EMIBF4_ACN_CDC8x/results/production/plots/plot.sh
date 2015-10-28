#!/bin/bash
if [ $# -ne 1 ]; then
	echo -e "\nusage: `basename $0` filename.gp";
	echo -e "\nprocess a gnuplot script to pdf using pdflatex\n";
	exit 0;
fi;

base=`echo $1 | sed /\.gp/s///`
echo "processing $base";
gnuplot $base.gp &&  
pdflatex -shell-escape -interaction=nonstopmode template.tex
# copy the resultant pdf to the destination, ask if overwrite
mv template.pdf $base.pdf

# cleanup
latexmk -c template
rm gnuout.eps gnuout-eps-converted-to.pdf gnuout.tex

#gv --media=BBOX $base.pdf --infoSilent
gv $base.pdf --infoSilent
#okular $base.pdf 
