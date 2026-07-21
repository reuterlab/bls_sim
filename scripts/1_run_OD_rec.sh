# grid 1: a finer grid for lower selection parameters
# 10x10 grid of selection coefficients from 0.01 to 0.1 by 0.01
rep=100
for s1 in 0.01 0.02 0.05 0.09 0.1; do
    for s2 in 0.01 0.02 0.05 0.09 0.1; do
        qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N2k_r1e-7_grid0.01/' -t 1-$rep job_run_OD_N2k_r1e-7.sh
        #qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N2k_r1e-8_grid0.01/' -t 1-$rep job_run_OD_N2k_r1e-8.sh
        #qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N20k_r1e-7_grid0.01/' -t 1-$rep job_run_OD_N20k_r1e-7.sh
        #qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N20k_r1e-8_grid0.01/' -t 1-$rep job_run_OD_N20k_r1e-8.sh
   done
done

# # grid 2: a coarser grid for higher selection parameters
# # 10x10 grid of selection coefficients from 0.1 to 1 by 0.1
for s1 in 0.1 0.2 0.5 0.9 1; do
    for s2 in 0.1 0.2 0.5 0.9 1; do
        qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N2k_r1e-7_grid0.1/' -t 1-$rep job_run_OD_N2k_r1e-7.sh
        #qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N2k_r1e-8_grid0.1/' -t 1-$rep job_run_OD_N2k_r1e-8.sh
        #qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N20k_r1e-7_grid0.1/' -t 1-$rep job_run_OD_N20k_r1e-7.sh
        #qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N20k_r1e-8_grid0.1/' -t 1-$rep job_run_OD_N20k_r1e-8.sh
    done
done
#
# rename files so that it follows the same pattern as the other seltypes
# 1----
#Ne=20
#r=1e-8
# 1----
# 2----
#Ne=2
#r=1e-7
# 2----
# 3----
#Ne=20
#r=1e-7
# 3----
# 4----
Ne=2
r=1e-8
# 4----
for grid in 0.01 0.1; do
    FILEPATH=/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N${Ne}k_r${r}_grid${grid}/
    for FILE in ${FILEPATH}/output*; do
        NEWNAME=$(basename $FILE| awk -F"_" -v OFS="_" '$3="h0_"$3')
        mv $FILE ${FILEPATH}/$NEWNAME
done;done;

tar xzvf OD_N2k_r1e-8_grid0.01.tar.gz
cd OD_N2k_r1e-8_grid0.01
tar xzvf trees.tar.gz
ls trees|wc
mv trees/* .
ls *.trees|wc
rm trees.tar.gz
tar czvf OD_N2k_r1e-8_grid0.01.tar.gz OD_N2k_r1e-8_grid0.01/

tar xzvf OD_N2k_r1e-8_grid0.1.tar.gz
cd OD_N2k_r1e-8_grid0.1
tar xzvf trees.tar.gz
ls trees|wc
mv trees/* .
ls *.trees|wc
rm trees.tar.gz
tar czvf OD_N2k_r1e-8_grid0.1.tar.gz OD_N2k_r1e-8_grid0.1/
