#PBS -S /bin/bash
#PBS -N 114
#PBS -q workq
#PBS -A uq-ChemEng

#PBS -m ae
#PBS -e error_Pore_Filling
#PBS -o output
#PBS -M r.burt@uq.edu.au
#PBS -l walltime=03:20:00
#PBS -l place=scatter
#PBS -l select=32:ncpus=4:mpiprocs=4:NodeType=medium

	#--------------Select is the number of nodes, ncpus is the number of cpus----------#
#--------------for a walltime less than 24 hours, use NodeType=any, for greater than 24 hours use =medium---------------#

#Initialise the module environment

source /usr/share/modules/init/bash

module load gromacs/5.0.4
module load openmpi/1.5.3-intel

#Change into the project run folder #---------------Change this directory for each new file------------#

cd /home/uqrburt/MD_Simulations/CDC800_EMIMBF4_AN/10AN

#Copy inputs to scratch disk on the comupte node to $TMPDIR#------------Change the inputs for each simulation as required------------#




#quicktest	pwd>test.file
			#-------------Run MD code here--------------#
which mdrun

grompp -p 10AN_0.01e.top -f NVT.mdp -c CDC_10AN_Input.gro -o Step1_0.01e_298K -po Step1_0.01e_298K_po
time mpirun -np 128 mdrun_mpi -v -s Step1_0.01e_298K -deffnm Step1_0.01e_298K -c Step1_0.01e_298K.pdb
g_density -f Step1_0.01e_298K.xtc -n 10AN.ndx -s Step1_0.01e_298K.tpr -sl 300 -o Density_Step1_0.01e_298K.xvg <<EOF
8 
EOF
 
grompp -p 10AN.top -f NVT.mdp -c Step1_0.01e_298K.pdb -o Step2_0.00e_298K -po Step2_0.00e_298K_po
time mpirun -np 128 mdrun_mpi -v -s Step2_0.00e_298K -deffnm Step2_0.00e_298K -c Step2_0.00e_298K.pdb
g_density -f Step2_0.00e_298K.xtc -n 10AN.ndx -s Step2_0.00e_298K.tpr -sl 300 -o Density_Step2_0.00e_298K.xvg <<EOF
8 
EOF
 
grompp -p 10AN_0.02e.top -f NVT.mdp -c Step2_0.00e_298K.pdb -o Step3_0.02e_298K -po Step3_0.02e_298K_po
time mpirun -np 128 mdrun_mpi -v -s Step3_0.02e_298K -deffnm Step3_0.02e_298K -c Step3_0.02e_298K.pdb 
g_density -f Step3_0.02e_298K.xtc -n 10AN.ndx -s Step3_0.02e_298K.tpr -sl 300 -o Density_Step3_0.02e_298K.xvg <<EOF
8 
EOF

grompp -p 10AN.top -f NVT.mdp -c Step3_0.02e_298K.pdb -o Step4_0.00e_298K -po Step4_0.00e_298K_po
time mpirun -np 128 mdrun_mpi -v -s Step4_0.00e_298K -deffnm Step4_0.00e_298K -c Step4_0.00e_298K.pdb 
g_density -f Step4_0.00e_298K.xtc -n 10AN.ndx -s Step4_0.00e_298K.tpr -sl 300 -o Density_Step4_0.00e_298K.xvg <<EOF
8 
EOF
grompp -p 10AN_0.02e.top -f NVT.mdp -c Step4_0.00e_298K.pdb -o Step5_0.02e_298K -po Step5_0.02e_298K_po
time mpirun -np 128 mdrun_mpi -v -s Step5_0.02e_298K -deffnm Step5_0.02e_298K -c Step5_0.02e_298K.pdb 
g_density -f Step5_0.02e_298K.xtc -n 10AN.ndx -s Step5_0.02e_298K.tpr -sl 300 -o Density_Step5_0.02e_298K.xvg <<EOF
8 
EOF
 
grompp -p 10AN.top -f NVT.mdp -c Step5_0.02e_298K.pdb -o Step6_0.00e_298K -po Step6_0.00e_298K_po
time mpirun -np 128 mdrun_mpi -v -s Step6_0.00e_298K -deffnm Step6_0.00e_298K -c Step6_0.00e_298K.pdb 
g_density -f Step6_0.00e_298K.xtc -n 10AN.ndx -s Step6_0.00e_298K.tpr -sl 300 -o Density_Step6_0.00e_298K.xvg <<EOF
8 
EOF
 
grompp -p 10AN_0.02e.top -f NVT.mdp -c Step6_0.00e_298K.pdb -o Step7_0.02e_298K -po Step7_0.02e_298K_po
time mpirun -np 128 mdrun_mpi -v -s Step7_0.02e_298K -deffnm Step7_0.02e_298K -c Step7_0.02e_298K.pdb 
g_density -f Step7_0.02e_298K.xtc -n 10AN.ndx -s Step7_0.02e_298K.tpr -sl 300 -o Density_Step7_0.02e_298K.xvg <<EOF
8 
EOF
 
grompp -p 10AN.top -f NVT.mdp -c Step7_0.02e_298K.pdb -o Step8_0.00e_298K -po Step8_0.00e_298K_po
time mpirun -np 128 mdrun_mpi -v -s Step8_0.00e_298K -deffnm Step8_0.00e_298K -c Step8_0.00e_298K.pdb 
g_density -f Step8_0.00e_298K.xtc -n 10AN.ndx -s Step8_0.00e_298K.tpr -sl 300 -o Density_Step8_0.00e_298K.xvg <<EOF
8 
EOF
 
grompp -p 10AN_0.02e.top -f NVT.mdp -c Step8_0.00e_298K.pdb -o Step9_0.02e_298K -po Step9_0.02e_298K_po
time mpirun -np 128 mdrun_mpi -v -s Step9_0.02e_298K -deffnm Step9_0.02e_298K -c Step9_0.02e_298K.pdb 
g_density -f Step9_0.02e_298K.xtc -n 10AN.ndx -s Step9_0.02e_298K.tpr -sl 300 -o Density_Step9_0.02e_298K.xvg <<EOF
8 
EOF
 
grompp -p 10AN.top -f NVT.mdp -c Step9_0.02e_298K.pdb -o Step10_0.00e_298K -po Step10_0.00e_298K_po
time mpirun -np 128 mdrun_mpi -v -s Step10_0.00e_298K -deffnm Step10_0.00e_298K -c Step10_0.00e_298K.pdb 
g_density -f Step10_0.00e_298K.xtc -n 10AN.ndx -s Step10_0.00e_298K.tpr -sl 300 -o Density_Step10_0.00e_298K.xvg <<EOF
8 
EOF

grompp -p 10AN.top -f NVT_200ps.mdp -c Step10_0.00e_298K.pdb -o Final_Equili_298K_10AN -po Final_Equili_298K_10AN_po
time mpirun -np 128 mdrun_mpi -v -s Final_Equili_298K_10AN -deffnm Final_Equili_298K_10AN -c Final_Equili_298K_10AN.pdb 
g_density -f Final_Equili_298K_10AN.xtc -n 10AN.ndx -s Final_Equili_298K_10AN.tpr -sl 300 -o Density_Final_Equili_298K_10AN.xvg <<EOF
8 
EOF
trjconv -f Final_Equili_298K_10AN.pdb -s Final_Equili_298K_10AN.tpr -pbc atom -o Final_Equili_298K_10AN_Trjconv.pdb <<EOF
0 
EOF

rm Step* *.1# step* *.paroo3

# cp * /home/uqrburt/MD_Simulations/CDC800_EMIMBF4_AN/10AN
touch /home/uqrburt/MD_Simulations/CDC800_EMIMBF4_AN/10AN//${PBS_JOBID}
#if [ $? -ne 0 ]; then
# exit 1
#fi
