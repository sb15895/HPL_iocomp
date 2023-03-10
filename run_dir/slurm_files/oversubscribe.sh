export CASE=Oversubscribe
export RUNDIR=${PARENT_DIR}/${CASE}/$i
echo "**" $CASE 
echo $RUNDIR
rm -rf ${RUNDIR}
mkdir -p ${RUNDIR}
lfs setstripe -c -1  ${RUNDIR}
cd ${RUNDIR} 
cp ${CONFIG} . 

# give sequence of cpu mappings 
end=$((${FULL_CORES}-1))
vals=($(seq 0 1 $(eval echo ${end})))
bar=$(IFS=, ; echo "${vals[*]}")

# oversubscribe uses half as many nodes compared to sequential IF full node is used 
if (( ${SLURM_NNODES} > 1  )); then 
  NUM_NODES=${HALF_NODES} 
else
  NUM_NODES=${SLURM_NNODES} 
fi 

srun --hint=nomultithread --distribution=block:block --nodes=${NUM_NODES} --cpu-bind=map_cpu:${bar[@]} --overcommit ${HPL} --io=${m} --HT=1 > test.out

module list  2>&1 | tee -a test.out 

echo "JOB ID"  $SLURM_JOBID >> test.out
echo "JOB NAME" ${SLURM_JOB_NAME} >> test.out
