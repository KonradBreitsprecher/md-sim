#PBS -N gr_cdc
#PBS -l walltime=01:20:00
#PBS -l nodes=1:ppn=24

	#--------------Select is the number of nodes, ncpus is the number of cpus----------#
#--------------for a walltime less than 24 hours, use NodeType=any, for greater than 24 hours use =medium---------------#

#Initialise the module environmentomp


module load chem/gromacs


#Change intompo the project run folder #---------------Change this directory for each new file------------#

cd $HOME/git/md-sim/gromacs/10AN/

#Copy inputs to scratch disk on the comupte node to $TMPDIR#------------Change the inputs for each simulation as required------------#
#quicktest	pwd>test.file
			#-------------Run MD code here--------------#
#which mdrun
aprun -n 24 -N 24 grompp_mpi -p 10AN_0.01e.top -f NVT.mdp -c CDC_10AN_Input.gro -o Step1_Test_np8_ntomp4 -po Step1_Test_np8_ntomp4_po
export OMP_NUM_THREADS=1
aprun -n 24 -N 24 mdrun_mpi -s Step1_Test_np8_ntomp4 -deffnm Step1_Test_np8_ntomp4 -c Step1_Test_np8_ntomp4.pdb -ntomp 1



#cp * /home/uqrburt/MD_Simulations/CDC800_EMIMBF4_AN/10AN
#touch /home/uqrburt/MD_Simulations/CDC800_EMIMBF4_AN/10AN//${PBS_JOBID}
#if [ $? -ne 0 ]; then
# exit 1
#fi
