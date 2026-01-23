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

#$ -l tmem=8G
#$ -l h_vmem=8G
#$ -l h_rt=240:00:00 

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

echo "qsub script start" 
date

PROJDIR=/SAN/reuterlab/balsel_detection/bls_sim/
SCRIPTDIR=$PROJDIR/scripts/
cd $SCRIPTDIR

BALDIR=$PROJDIR/baller
mkdir $BALDIR/results
mkdir $BALDIR/results/$simpref

for rep in $(seq 1 ${nrep}); do
    for infile in $BALDIR/infiles/$simpref/output*_r${rep}_*_c${age}_*_spl100.balmixder
    do 
        inpref=$(basename $infile .balmixder)
    #    echo $inpref
        python3 BalLeRMix/software/BalLeRMix_v2.5.py -i $infile -o $BALDIR/results/$simpref/${inpref}.B2 --spect $BALDIR/infiles/$helperdir/all_c${age}_spl100_concat.B2spect_DAF -w 10000 --fixSize --physPos --rec ${rec}
    done
done
