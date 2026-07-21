# grid 1: a finer grid for lower selection parameters
# 10x10 grid of selection coefficients from 0.01 to 0.1 by 0.01
# 2x dominance parameters: 0.5 and 0.25
rep=100
for s1 in 0.01 0.02 0.05 0.09 0.1; do
    for s2 in 0.01 0.02 0.05 0.09 0.1; do
        for h in 0.5 0.25; do
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N2k_r1e-7_grid0.01/' -t 1-$rep job_run_SA_N2k_r1e-7.sh
            #qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N2k_r1e-8_grid0.01/' -t 1-$rep job_run_SA_N2k_r1e-8.sh
            #qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N20k_r1e-7_grid0.01/' -t 1-$rep job_run_SA_N20k_r1e-7.sh
            #qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N20k_r1e-8_grid0.01/' -t 1-$rep job_run_SA_N20k_r1e-8.sh
        done
    done
done

# grid 2: a coarser grid for higher selection parameters
# 10x10 grid of selection coefficients from 0.2 to 1 by 0.1
# 2x dominance parameters: 0.5 and 0.25
for s1 in 0.1 0.2 0.5 0.9 1; do
    for s2 in 0.1 0.2 0.5 0.9 1; do
        for h in 0.5 0.25; do
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N2k_r1e-7_grid0.1/' -t 1-$rep job_run_SA_N2k_r1e-7.sh
            #qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N2k_r1e-8_grid0.1/' -t 1-$rep job_run_SA_N2k_r1e-8.sh
            #qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N20k_r1e-7_grid0.1/' -t 1-$rep job_run_SA_N20k_r1e-7.sh
            #qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N20k_r1e-8_grid0.1/' -t 1-$rep job_run_SA_N20k_r1e-8.sh
        done
    done
done

# missing one replicate 84, rerun:
qsub -v s1=0.01,s2=0.01,h=0.25,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N20k_r1e-7_grid0.01/' -t 1 job_run_SA_N20k_r1e-7.sh
#Your job-array 4398078.1-1:1 ("job_run_SA_N20k_r1e-7.sh") has been submitted
#

# rename files so that it follows the same pattern as the other seltypes
# 1----
#Ne=20
#r=1e-8    
# 1----
Ne=2
Ne=20
r=1e-7
r=1e-8
for grid in 0.01 0.1; do
    FILEPATH=/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N${Ne}k_r${r}_grid${grid}/
    for FILE in ${FILEPATH}/*; do
        NEWNAME=$(basename $FILE| awk -F"_" -v OFS="_" 'gsub("sfm","s",$2){print}')
        mv $FILE ${FILEPATH}/$NEWNAME
    done;done;

cd /SAN/reuterlab/balsel_detection/bls_sim/slimout    

INDIR=SA_N20k_r1e-7_grid0.01  
INDIR=SA_N20k_r1e-7_grid0.1  
INDIR=SA_N2k_r1e-8_grid0.01  
INDIR=SA_N2k_r1e-8_grid0.1  

tar xzvf ${INDIR}.tar.gz
cd $INDIR
tar xzvf trees.tar.gz
ls trees|wc
mv trees/* .
ls *.trees|wc
rm trees.tar.gz
cd ..
tar czvf ${INDIR}.tar.gz $INDIR/

