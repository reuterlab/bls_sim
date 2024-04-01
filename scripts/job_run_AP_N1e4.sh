# Required flags:
#$ -l tmem=3G
#$ -l h_vmem=3G
#$ -l h_rt=72:00:00 

# Optional flags:
#$ -S /bin/bash
#$ -cwd
#$ -j y
# Merges STDOUT and STDERR.
#$ -o /SAN/reuterlab/balsel_detection/bls_sim/scripts/sge_output/

if [ ! -d $OUTDIR ]; then
	mkdir $OUTDIR
	fi

SEED=$(shuf -i 1-999999999 -n 1)
REP=$SGE_TASK_ID
/share/apps/SLiM-4.0.1/bin/slim -d jobid=$JOB_ID -d d_seed=$SEED -d d_repID=$REP -d t1=$s1 -d t2=$s2 -d h=$h -d d_folder="'$OUTDIR/'" -d rand_inv=$rand_inv /SAN/reuterlab/balsel_detection/bls_sim/slim/AP_N1e4.slim
# slim is taking the following values from the command line:
# jobid=$JOB_ID is the scheduler job ID (will be the same for all tasks in this array)
# d_seed=$SEED is the slim seed that is a random number in the range 1-999999999
# d_repID=REP is the replicate number
# t1 and t2 are the selection coefficients
# h is the dominance parameter
# d_folder is the subfolder where where the outputs of this particular slim simulations will be written to. Output file names in this folder are:
# - tree sequences: output_t{t1}-{t2}_h{h}_r{d_repID}_s{d_seed}_j{jobid}.trees
# - allele frequency files: output_s{t1}-{t2}_h{h}_r{d_repID}_s{d_seed}_j{jobid}.AP_N1e4.txt
# rand_inv is a flag indicating whether the invading allele should be chosen randomly (1) or not (0)
