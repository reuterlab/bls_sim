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

echo "qsub script start" 
date
source /share/apps/source_files/R/R-4.3.2.source

Rscript ballerpower.R $selB2file $neuB2file $seltype $Ne $rec $mut $s1 $s2 $t

#selB2file <- args[1]
#neutralB2file <- args[2]
#seltype <- args[3]
#Ne <- args[4]
#rec <- args[5]
#mut <- args[6]
#s1 <- args[7]
#s2 <- args[8]
#t <- args[9]
