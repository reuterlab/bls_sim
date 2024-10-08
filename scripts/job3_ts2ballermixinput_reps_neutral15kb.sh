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
source /share/apps/source_files/python/python-3.9.5.source
pip install pandas

params=$(sed -n ${SGE_TASK_ID}'{p;q}' $PARAMSFILE)
echo $params
read -r seltype Ne rec mut selage h grid s1 s2 rep <<< "$params" 

PROJDIR=/SAN/reuterlab/balsel_detection/bls_sim/
SCRIPTDIR=/SAN/reuterlab/balsel_detection/bls_sim/scripts/
cd $SCRIPTDIR

SIMPREF=$seltype'_N'$((Ne/1000))'k_r'$rec'_grid'$grid
INDIR=${PROJDIR}'/slimout/'$SIMPREF
VCFDIR=${PROJDIR}'/vcf/'$SIMPREF'_m'$mut
if [ ! -d $VCFDIR ]; then
    mkdir $VCFDIR
fi
BALINDIR=${PROJDIR}'/baller/infiles/'$SIMPREF'_m'$mut
if [ ! -d $BALINDIR ]; then
    mkdir $BALINDIR
fi

if [[ $seltype == "neutral"* ]]; then
    NEUTRAL=true
else
    NEUTRAL=false
fi

nspl=100
echo "generating recapitated trees and vcf for "$nspl" samples"
echo "Number of trees files being processed:"
ls $INDIR/output_s${s1}-${s2}_h${h}_r${rep}*c${selage}.trees|wc -l

for treefile in $INDIR/output_s${s1}-${s2}_h${h}_r${rep}_*c${selage}.trees; do 
    if [ -f "$treefile" ]; then
    echo $treefile
    vcfpref=$(basename $treefile .trees)
    vcffile=${vcfpref}_spl${nspl}
    if $NEUTRAL; then
        python3 recapitate_neutral_15kb.py -i $treefile -o ${VCFDIR}/${vcffile} --vcf --nspl $nspl --ne $Ne --mu $mut --re $rec 
    fi
    if ! $NEUTRAL; then
        python3 recapitate_selected.py -i $treefile -o ${VCFDIR}/${vcffile} --vcf --nspl $nspl --ne $Ne --mu $mut --re $rec
    fi
    /share/apps/htslib-1.20/bgzip -f $VCFDIR/${vcffile}.vcf
    # parse vcf files from sims to generate input files for ballermix
    ./parse_VCF_polarized.sh $VCFDIR/${vcffile}.vcf.gz $BALINDIR/${vcffile} $nspl
    fi
done

echo "FINISHED" 
