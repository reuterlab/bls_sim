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
#$ -l tscratch=1G

#The code you want to run now goes here.
echo "qsub script start" 
date

scratchdir=/scratch0/dbrandt/$JOB_ID.$SGE_TASK_ID
mkdir -p $scratchdir

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

# run NCD on neutralnull, OD, AP and SA simulations
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
INDIR=$PROJDIR/vcf/$SIMPREF'_m'$mut'_100'
OUTDIR=$PROJDIR/ncd/$SIMPREF'_m'$mut'_100'
mkdir $OUTDIR

while read FNAME; do
cp $FNAME $scratchdir
done < $INDIR/output_s${s1}-${s2}_h${h}_c${selage}_fnames.txt

rm $OUTDIR/all_s${s1}-${s2}_h${h}_c${selage}_spl100_tf${tf}_w${winsize}.ncd2
for infile in $scratchdir/output_s${s1}-${s2}_h${h}_*_c${selage}_spl100.vcf.gz;do
    echo $infile
    # pipe to awk to remove header and concat files
    echo "Rscript balselr.R $infile $tf $winsize 2> /dev/null | awk '$8==4999' >> $OUTDIR/all_s${s1}-${s2}_h${h}_c${selage}_spl100_tf${tf}_w${winsize}.ncd2"
    Rscript balselr.R $infile $tf $winsize 2> /dev/null | awk '$8==4999' >> $OUTDIR/all_s${s1}-${s2}_h${h}_c${selage}_spl100_tf${tf}_w${winsize}.ncd2
    # balselr.R output cols:       ncd2  S FD IS  tf Win.start Win.end Win.mid
done

function finish {
    rm -rf $scratchdir
}
trap finish EXIT ERR INT TERM

echo "FINISHED" 
