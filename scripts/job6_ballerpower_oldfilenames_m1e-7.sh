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

#$ -l tmem=1G
#$ -l h_vmem=1G
#$ -l h_rt=00:30:00 

#These are optional flags but you probably want them in all jobs

#$ -S /bin/bash
#$ -cwd
#$ -j y
# Merges STDOUT and STDERR.
#$ -o /SAN/reuterlab/balsel_detection/bls_sim/scripts/sge_output/

#The code you want to run now goes here.

echo "qsub script start" 
date
source /share/apps/source_files/R/R-4.3.2.source

params=$(sed -n ${SGE_TASK_ID}'{p;q}' $PARAMSFILE)
echo $params
read -r seltype Ne rec mut selage h grid s1 s2 nrep <<< "$params" 

PROJDIR=/SAN/reuterlab/balsel_detection/bls_sim/
SCRIPTDIR=/SAN/reuterlab/balsel_detection/bls_sim/scripts/
cd $SCRIPTDIR

SIMPREF=$seltype'_N'$((Ne/1000))'k_r'$rec'_grid'$grid'_m'$mut
BALOUTDIR=$PROJDIR/baller/results/

# run power analyses on OD, AP and SA simulations
if [[ $seltype == +(OD) ]]; then
    Rscript ballerpower.R $BALOUTDIR/$SIMPREF/all_s${s1}-${s2}_c${selage}.B2 $BALOUTDIR/neutral_N$((Ne/1000))k_r${rec}_fornull_m${mut}/all_c${selage}.B2 $seltype $Ne $rec $mut $s1 $s2 $h $selage
elif [[ $seltype == +(AP|SA) ]]; then 
    Rscript ballerpower.R $BALOUTDIR/$SIMPREF/all_s${s1}-${s2}_h${h}_c${selage}.B2 $BALOUTDIR/neutral_N$((Ne/1000))k_r${rec}_fornull_m${mut}/all_c${selage}.B2 $seltype $Ne $rec $mut $s1 $s2 $h $selage
else
    exit 1
fi

wait
echo "FINISHED" 
