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
read -r seltype Ne rec mut selage h grid s1 s2 nrep pstar <<< "$params" 

#optional qsub variables provided with -v
if [[ $TF ]]; then
    tf=$TF; else
    tf=$pstar;
fi
echo "Target frequency: "$tf

if [[ $WINSIZE ]]; then winsize=$WINSIZE; else winsize=3000;fi
echo "Window size: "$winsize

# run power analyses on OD, AP and SA simulations
if [[ $seltype == +(OD|AP|SA) ]]; then
    NEUTRAL=false
else
    exit 1
fi

PROJDIR=/SAN/reuterlab/balsel_detection/bls_sim/
SCRIPTDIR=/SAN/reuterlab/balsel_detection/bls_sim/scripts/
cd $SCRIPTDIR

OUTDIR=$PROJDIR/ncd/
selncd=$OUTDIR/${seltype}_N$((Ne/1000))k_r${rec}_grid${grid}_m${mut}_100/all_s${s1}-${s2}_h${h}_c${selage}_spl100_tf${tf}_w${winsize}.ncd2
# not sure why some null characters ^@ were being introduced in the selncd file. The sed command was to take care of that.
sort -u $selncd | sed 's/\x0//g' > tmp$JOB_ID.$SGE_TASK_ID
mv tmp$JOB_ID.$SGE_TASK_ID $selncd

#Rscript ncdpower.R $OUTDIR/${seltype}_N$((Ne/1000))k_r${rec}_grid${grid}_m${mut}/all_s${s1}-${s2}_h${h}_c${selage}_spl100.ncd2 $OUTDIR/neutralnull_N$((Ne/1000))k_r${rec}_grid0_m${mut}/all_s0-0_h0_c${selage}_spl100.ncd2 $seltype $Ne $rec $mut $s1 $s2 $h $selage
neuncd=$OUTDIR/neutralnull_N$((Ne/1000))k_r${rec}_grid0_m${mut}/all_s0-0_h0_c${selage}_spl100_tf${tf}_w${winsize}.ncd2

# I generated some files where I rounded the tf to 6 digits. this is to take care of those cases
if [ ! -f $neuncd ]; then
    tfround=$(printf "%.6f" $tf)
    neuncd=$OUTDIR/neutralnull_N$((Ne/1000))k_r${rec}_grid0_m${mut}/all_s0-0_h0_c${selage}_spl100_tf${tfround}_w${winsize}.ncd2
fi

Rscript ncdpower.R $selncd $neuncd $seltype $Ne $rec $mut $s1 $s2 $h $selage

echo "FINISHED" 
qstat -j $JOB_ID
