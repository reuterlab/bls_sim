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
#$ -l h_rt=12:00:00 

#These are optional flags but you probably want them in all jobs

#$ -S /bin/bash
#$ -cwd
#$ -j y
# Merges STDOUT and STDERR.
#$ -o /SAN/reuterlab/balsel_detection/bls_sim/scripts/sge_output/

#The code you want to run now goes here.
source /share/apps/source_files/python/python-3.9.5.source
pip install pandas

params=$(sed -n ${SGE_TASK_ID}'{p;q}' $PARAMSFILE)
echo $params
read -r seltype Ne rec mut selage h grid s1 s2 nrep <<< "$params" 

# run only for neutralgenome simulations
if [[ $seltype == neutralgenome ]]; then
    NEUTRAL=true
else 
    exit 1
fi

PROJDIR=/SAN/reuterlab/balsel_detection/bls_sim/
SCRIPTDIR=/SAN/reuterlab/balsel_detection/bls_sim/scripts/
cd $SCRIPTDIR

# 1. Generate helper files (SFS) for Ballermix.
# will generate 4 helper files, for each of the simulation sets: c16k, c32k, c160k,c320k
# sanity checks: plot_baller_sfs.R and segregating_sites_baller.R

BALINDIR=$PROJDIR'/baller/infiles/neutralgenome_N'$((Ne/1000))'k_r'$rec'_grid'$grid'_m'$mut
echo "number of ballermix input files to be concatenated:"
ls $BALINDIR/output_s0-0_h0_r*c${selage}_spl100.balmixder|wc -l
printf "physPos\tgenPos\tx\tn\n" >  $BALINDIR/all_c${selage}_spl100_concat.balmixder
for file in $BALINDIR/output_s0-0_h0_r*c${selage}_spl100.balmixder; do tail -n +2 $file ; done >> $BALINDIR/all_c${selage}_spl100_concat.balmixder

# git clone https://github.com/bioXiaoheng/BalLeRMix/
echo "get ballermix spect"
mkdir $BALINDIR/helperfiles
python3 BalLeRMix/software/BalLeRMix_v2.5.py -i $BALINDIR/all_c${selage}_spl100_concat.balmixder --getSpect --spect $BALINDIR/helperfiles/all_c${selage}_spl100_concat.B2spect_DAF
