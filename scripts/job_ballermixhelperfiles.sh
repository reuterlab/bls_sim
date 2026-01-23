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
#$ -l h_rt=10:00:00 

#These are optional flags but you probably want them in all jobs

#$ -S /bin/bash
#$ -cwd
#$ -j y
# Merges STDOUT and STDERR.
#$ -o /SAN/reuterlab/balsel_detection/bls_sim/scripts/sge_output/

#The code you want to run now goes here.

# any reason to use python3.10? Using 3.9.5 which was used in previous steps
#source /share/apps/source_files/python/python-3.10.0.source
source /share/apps/source_files/python/python-3.9.5.source
pip install pandas

PROJDIR=/SAN/reuterlab/balsel_detection/bls_sim/
SCRIPTDIR=/SAN/reuterlab/balsel_detection/bls_sim/scripts/
cd $SCRIPTDIR
OUTDIR=$PROJDIR/baller/infiles/$simpref

## Helper files (SFS) for Ballermix.
echo "concat all input files for each selection age"
printf "physPos\tgenPos\tx\tn\n" >  $OUTDIR/all_c16000_spl100_concat.balmixder
for file in $OUTDIR/output_*c16000_mut*_spl100.balmixder; do tail -n +2 $file ; done >> $OUTDIR/all_c16000_spl100_concat.balmixder

printf "physPos\tgenPos\tx\tn\n" >  $OUTDIR/all_c32000_spl100_concat.balmixder
for file in $OUTDIR/output_*c32000_mut*_spl100.balmixder; do tail -n +2 $file ; done >> $OUTDIR/all_c32000_spl100_concat.balmixder

printf "physPos\tgenPos\tx\tn\n" >  $OUTDIR/all_c160000_spl100_concat.balmixder
for file in $OUTDIR/output_*c160000_mut*_spl100.balmixder; do tail -n +2 $file ; done >> $OUTDIR/all_c160000_spl100_concat.balmixder

printf "physPos\tgenPos\tx\tn\n" >  $OUTDIR/all_c320000_spl100_concat.balmixder
for file in $OUTDIR/output_*c320000_mut*_spl100.balmixder; do tail -n +2 $file ; done >> $OUTDIR/all_c320000_spl100_concat.balmixder

#git clone https://github.com/bioXiaoheng/BalLeRMix/
echo "get ballermix spect"
mkdir $OUTDIR/helperfiles
python3 BalLeRMix/software/BalLeRMix_v2.5.py -i $OUTDIR/all_c16000_spl100_concat.balmixder --getSpect --spect $OUTDIR/helperfiles/all_c16000_spl100_concat.B2spect_DAF
python3 BalLeRMix/software/BalLeRMix_v2.5.py -i $OUTDIR/all_c32000_spl100_concat.balmixder --getSpect --spect $OUTDIR/helperfiles/all_c32000_spl100_concat.B2spect_DAF
python3 BalLeRMix/software/BalLeRMix_v2.5.py -i $OUTDIR/all_c160000_spl100_concat.balmixder --getSpect --spect $OUTDIR/helperfiles/all_c160000_spl100_concat.B2spect_DAF
python3 BalLeRMix/software/BalLeRMix_v2.5.py -i $OUTDIR/all_c320000_spl100_concat.balmixder --getSpect --spect $OUTDIR/helperfiles/all_c320000_spl100_concat.B2spect_DAF

echo "qsub script end" 
date
