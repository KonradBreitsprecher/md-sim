PBS -S /bin/bash
#PBS -N MW
#PBS -q workq
#PBS -A uq-ChemEng

#PBS -m ae
#PBS -e Error_30ACN_Test.err
#PBS -o Output_30ACN_Test.log
#PBS -M r.burt@uq.edu.au
#PBS -l walltime=02:00:00
#PBS -l place=scatter
#PBS -l select=8:ncpus=4:mpiprocs=4:NodeType=medium

#--------------Select is the number of nodes, ncpus is the number of cpus----------#
#--------------for a walltime less than 24 hours, use NodeType=any, for greater than 24 hours use =medium---------------#
#Initialise the module environment
source /usr/share/modules/init/bash
module load intel-fc-13 openmpi/1.5.3-intel 
 

#Change into the project run folder 	#---------------Change this directory for each new file------------#

cd /work1/uqrburt/metalwalls/runs/md-sim/metalwalls/BMIBF4_ACN_SLITS/30ACN
rm *out* testout*
#Copy inputs to scratch disk on the comupte node to $TMPDIR	#-------Change the inputs for each simulation as required------------#

#cp potential.inpt restart.dat runtime.inpt  $TMPDIR


pwd
ls
env
#quicktest	pwd>test.file
													#-------------Run MD code here--------------#
#which 


time mpirun -np 32 /work1/uqrburt/metalwalls/bin/metalwalls.exe


touch /work1/uqrburt/metalwalls/runs/md-sim/metalwalls/BMIBF4_ACN_SLITS/30ACN//${PBS_JOBID}

#if [ $? -ne 0 ]; then
# exit 1
#fi
