#   This is the most basic QSUB file needed for this cluster.r	
#   Further examples can be found under /share/apps/examples
#   Most software is NOT in your PATH but under /share/apps
#
#   For further info please read http://hpc.cs.ucl.ac.uk
#   For cluster help email cluster-support@cs.ucl.ac.uk
#
#   NOTE hash dollar is a scheduler directive not a comment.

# These are flags you must include - Two memory and one runtime.
# Runtime is either seconds or hours:min:sec

#$ -l tmem=3G
#$ -l h_vmem=3G
#$ -l h_rt=72:00:00 

#These are optional flags but you probably want them in all jobs

#$ -S /bin/bash
#$ -cwd
#$ -j y
# Merges STDOUT and STDERR.
#$ -o /SAN/reuterlab/balsel_detection/bls_sim/scripts/sge_output/

#The code you want to run now goes here.

mkdir $OUTDIR

SEED=$(shuf -i 1-999999999 -n 1) # slim seed is a random number in that range. Seed number will be written in the slim output file name
REP=$SGE_TASK_ID  # replicate number goes from 1 to the number of array jobs requested with the -t flag above
slim -d jobid=$JOB_ID -d d_seed=$SEED -d d_repID=$REP -d sf=$s1 -d sm=$s2 -d h=$h -d d_folder="'$OUTDIR/'" -d rand_inv=1 /SAN/reuterlab/balsel_detection/bls_sim/slim/SA_N1e5.slim
# slim is taking the following values from the command line:
# jobid=$JOB_ID is the scheduler job ID (will be the same for all tasks in this array)
# d_seed=$SEED is the slim seed that is a random number in the range 1-999999999
# d_repID=REP is the replicate number
# sel1 and sel2 are the selection coefficients
# h is the dominance parameter
# d_folder is the subfolder where where the outputs of this particular slim simulations will be written to. Output file names in this folder are:
# - tree sequences: output_s{sel1}-{sel2}_h{h}_r{d_repID}_s{d_seed}_j{jobid}_c{checkpoint}.trees
# - allele frequency files: output_s{sel1}-{sel2}_h{h}_r{d_repID}_s{d_seed}_j{jobid}.SA_N1e5.txt
# rand_inv is a parameter that says wether we want to randomize the invading allele (A1 or A2). 1 means YES, randomize
