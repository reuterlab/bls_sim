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
#$ -l tscratch=4G

#The code you want to run now goes here.
source /share/apps/source_files/python/python-3.9.5.source
pip install pandas

params=$(sed -n ${SGE_TASK_ID}'{p;q}' $PARAMSFILE)
echo $params
read -r seltype Ne rec mut selage h grid s1 s2 nrep <<< "$params" 

PROJDIR=/SAN/reuterlab/balsel_detection/bls_sim/
SCRIPTDIR=/SAN/reuterlab/balsel_detection/bls_sim/scripts/

SIMPREF=$seltype'_N'$((Ne/1000))'k_r'$rec'_grid'$grid
INDIR=${PROJDIR}'/slimout/'$SIMPREF
VCFDIR=${PROJDIR}'/vcf/'$SIMPREF'_m'$mut
if [ ! -d $VCFDIR ]; then
    mkdir $VCFDIR
fi

if [[ $seltype == "neutral"* ]]; then
    NEUTRAL=true
else
    NEUTRAL=false
fi

echo "untar trees in scratch dir"
scratchdir=/scratch0/dbrandt/$JOB_ID.$SGE_TASK_ID 
mkdir -p $scratchdir
cp $INDIR.tar.gz $scratchdir/
cd $scratchdir
tar xzvf ${SIMPREF}.tar.gz --wildcards "$SIMPREF/output_s${s1}-${s2}_h${h}_*c${selage}.trees"
cd $SCRIPTDIR

nspl=100
echo "generating recapitated trees and vcf for "$nspl" samples"
echo "Number of trees files being processed:"
ls ${scratchdir}/$SIMPREF/output_s${s1}-${s2}_h${h}_*c${selage}.trees|wc -l

for treefile in ${scratchdir}/$SIMPREF/output_s${s1}-${s2}_h${h}_*c${selage}.trees; do 
    echo $treefile
    vcfpref=$(basename $treefile .trees)
    vcffile=${vcfpref}_spl${nspl}
    if $NEUTRAL; then
        python3 recapitate_neutral.py -i $treefile -o ${VCFDIR}/${vcffile} --vcf --nspl $nspl --ne $Ne --mu $mut --re $rec 
    fi
    if ! $NEUTRAL; then
        python3 recapitate_selected.py -i $treefile -o ${VCFDIR}/${vcffile} --vcf --nspl $nspl --ne $Ne --mu $mut --re $rec
    fi
    /share/apps/htslib-1.20/bgzip -f $VCFDIR/${vcffile}.vcf
done

function finish {
    rm -rf $scratchdir
}
trap finish EXIT ERR INT TERM

echo "FINISHED" 
