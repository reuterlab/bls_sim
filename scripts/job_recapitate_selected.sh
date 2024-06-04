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
#$ -l h_rt=72:00:00 

#These are optional flags but you probably want them in all jobs

#$ -S /bin/bash
#$ -cwd
#$ -j y
# Merges STDOUT and STDERR.
#$ -o /SAN/reuterlab/balsel_detection/bls_sim/scripts/sge_output/

#The code you want to run now goes here.
source /share/apps/source_files/python/python-3.11.8.source

if [ ! -d $OUTDIR ]; then
	mkdir $OUTDIR
	fi

for treefile in $INDIR/*trees
do
    vcfpref=$(basename $treefile .trees)
    python3 recapitate_selected.py -i $treefile -o ${OUTDIR}/${vcfpref}_mut${mu}_spl${nspl} --vcf --nspl $nspl --ne $ne --mu $mu --re $re
done
