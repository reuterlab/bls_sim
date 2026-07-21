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
read -r seltype Ne rec mut selage h grid s1 s2 nrep <<< "$params" 

SIMPREF=$seltype'_N'$((Ne/1000))'k_r'$rec'_grid'$grid
PROJDIR=/SAN/reuterlab/balsel_detection/bls_sim/
SCRIPTDIR=/SAN/reuterlab/balsel_detection/bls_sim/scripts/
cd $SCRIPTDIR

scratchdir=/scratch0/dbrandt/$JOB_ID.$SGE_TASK_ID
mkdir -p $scratchdir

cp $PROJDIR/vcf/$SIMPREF'_m'$mut/output_s${s1}-${s2}_h${h}_*_c${selage}_spl100.vcf.gz $scratchdir

BALINDIR=${PROJDIR}'/baller/infiles/'$SIMPREF'_m'$mut
if [ ! -d $BALINDIR ]; then
    mkdir $BALINDIR
fi

nspl=100
echo "generating ballermix infiles"
echo "Number of vcf files being processed:"
ls $scratchdir/output_s${s1}-${s2}_h${h}_*c${selage}_spl100.vcf.gz|wc -l

for vcf in $scratchdir/output_s${s1}-${s2}_h${h}_*_c${selage}_spl100.vcf.gz;do
    vcfpref=$(basename $vcf .vcf.gz)
    ## parse vcf files from sims to generate input files for ballermix
    ./parse_VCF_polarized.sh $scratchdir/${vcfpref}.vcf.gz $BALINDIR/${vcfpref} $nspl
done

function finish {
    rm -rf $scratchdir
}
trap finish EXIT ERR INT TERM
echo "FINISHED" 
qstat -j $JOB_ID
