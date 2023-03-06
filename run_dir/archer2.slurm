#!/bin/bash --login
#SBATCH --job-name=iocomp
#SBATCH --nodes=1
#SBATCH --tasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --account=e609
#SBATCH --partition=standard 
#SBATCH --qos=standard
##SBATCH --array=0-2

module swap PrgEnv-cray/8.0.0 PrgEnv-gnu
module load cmake 
module use /work/y07/shared/archer2-lmod/dev
module load xthi 
module swap craype-network-ofi craype-network-ucx 
module swap cray-mpich cray-mpich-ucx 
module load cray-hdf5-parallel

# Setup environment
export PPN=${SLURM_NTASKS_PER_NODE}
export OMP_NUM_THREADS=1
export ADIOS2_DIR=/work/e609/e609/shr203/opt/gnu/8.0.0/ADIOS2
export HPL_DIR=/work/e609/e609/shr203/opt/gnu/8.0.0/HPL/2.3/usr/local
export IOCOMP_DIR=/work/e609/e609/shr203/iocomp
export OpenBLAS_DIR=/work/e609/e609/shr203/opt/gnu/8.0.0/OpenBLAS
export LD_LIBRARY_PATH=${HPL_DIR}/lib:${ADIOS2_DIR}/lib64:${IOCOMP_DIR}/lib:${OpenBLAS_DIR}/lib:${LD_LIBRARY_PATH} 
export CONFIG=${SLURM_SUBMIT_DIR}/config.xml 
export HPL=/work/e609/e609/shr203/HPL_iocomp/hpl-2.3/testing/xhpl

# Make new directory 
IOLAYERS=("MPIIO" "HDF5" "ADIOS2_HDF5" "ADIOS2_BP4" "ADIOS2_BP5") # assign IO layer array 
i=${SLURM_ARRAY_TASK_ID} 
HALF_CORES=$((${SLURM_NTASKS_PER_NODE}/2)) 
FULL_CORES=$((${SLURM_NTASKS_PER_NODE})) 
HALF_NODES=$((${SLURM_NNODES}/2))

for m in {0..0}
do 
  export PARENT_DIR=${SLURM_SUBMIT_DIR}/4March/${SLURM_NNODES}_${SLURM_NTASKS_PER_NODE}/${IOLAYERS[${m}]}

  # Case 1 
	source ${SLURM_SUBMIT_DIR}/slurm_files/sequential.sh
	wait 

  # Case 2
	source ${SLURM_SUBMIT_DIR}/slurm_files/oversubscribe.sh 
	wait 

  # Case 3
	source ${SLURM_SUBMIT_DIR}/slurm_files/hyperthread.sh 
	wait 

  # Case 4
	source ${SLURM_SUBMIT_DIR}/slurm_files/consecutive.sh
	wait 
done 

