# Simulating mechanisms of balancing selection

## scripts

(Scripts are described here in the hierarchical order they are called.)

*run_\*.sh* are bash scripts with the loops of selection and dominance parameters. They call qsub job\_run\*.sh described below for each combination of parameters.

*job\_run\_\*\_N1e\*.sh*  scripts to submit to the SGE scheduler using qsub

SGE job flags:

- -o  qsub output files will be written to /home/dbrandt/bls\_sim/scripts/sge\_output
- -t  number of array jobs to run

These scripts call the slim scripts for each bal sel mode (OD, AP, SA) and effective pop size (1e3 1e4 1e5). 

slim is taking the following values from the command line:

- jobid=$JOB\_ID is the scheduler job ID (will be the same for all tasks in this array)
    - d\_seed=$SEED is the slim seed that is a random number in the range 1-999999999
- d\_repID=REP is the replicate number
- t1 and t2 are the selection coefficients
- h is the dominance parameter
- d\_folder is the subfolder where where the outputs of this particular slim simulations will be written to. Output file names in this folder are:
    - tree sequences: output\_t{t1}-{t2}\_h{h}\_r{d_repID}\_s{d_seed}\_j{jobid}.trees
    - allele frequency files: output\_s{t1}-{t2}\_h{h}\_r{d_repID}\_s{d_seed}\_j{jobid}.AP\_N1e3.txt
