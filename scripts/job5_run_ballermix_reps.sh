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
#$ -l h_rt=48:00:00 

#These are optional flags but you probably want them in all jobs

#$ -S /bin/bash
#$ -cwd
#$ -j y
# Merges STDOUT and STDERR.
#$ -o /SAN/reuterlab/balsel_detection/bls_sim/scripts/sge_output/

#The code you want to run now goes here.
echo "qsub script start" 
date

source /share/apps/source_files/python/python-3.9.5.source
pip install pandas
source /share/apps/source_files/R/R-4.3.2.source

params=$(sed -n ${SGE_TASK_ID}'{p;q}' $PARAMSFILE)
echo $params
read -r seltype Ne rec mut selage h grid s1 s2 rep <<< "$params" 
#
# run ballermix on neutralnull, OD, AP and SA simulations
if [[ $seltype == neutralnull ]]; then
    NEUTRAL=true
elif [[ $seltype == +(OD|AP|SA) ]]; then
    NEUTRAL=false
else 
    exit 1
fi

PROJDIR=/SAN/reuterlab/balsel_detection/bls_sim/
SCRIPTDIR=/SAN/reuterlab/balsel_detection/bls_sim/scripts/
cd $SCRIPTDIR

SIMPREF=$seltype'_N'$((Ne/1000))'k_r'$rec'_grid'$grid
BALINDIR=$PROJDIR/baller/infiles/$SIMPREF'_m'$mut
BALOUTDIR=$PROJDIR/baller/results/$SIMPREF'_m'$mut
mkdir $BALOUTDIR

infile=$BALINDIR/output_s${s1}-${s2}_h${h}_r${rep}_*_c${selage}_spl100.balmixder
inpref=$(basename $infile .balmixder)
recM=$(echo $rec | awk '{print $1*100}') # ballermix takes recombination rate in centi-Morgans
python3 BalLeRMix/software/BalLeRMix_v2.5.py -i $infile -o $BALOUTDIR/${inpref}.B2 --spect $PROJDIR/baller/infiles/neutralgenome_N$((Ne/1000))'k_r'$rec'_grid0_m'$mut/helperfiles/all_c${selage}_spl100_concat.B2spect_DAF -w 10000 --fixSize --physPos --rec ${recM}

# parse baller output for power analysis 
# -> extract only line corresponding to central site 4999 from each replicate
# -> dump lines of all replicates into a single file for this selage
awk '$1==4999' $BALOUTDIR/output_s${s1}-${s2}_h${h}_r*_c${selage}_spl100.B2 > $BALOUTDIR/all_s${s1}-${s2}_h${h}_c${selage}_spl100.B2

echo "FINISHED" 
