# 1. parse baller output for power analysis
BALDIR=/SAN/reuterlab/balsel_detection/bls_sim/baller/results/

## 1.1 1000 neutral sims fornull
simpref=neutral_N2k_r1e-8_fornull
for t in 16000 32000 160000 320000
do
awk '$1==4999' $BALDIR/$simpref/output_*_c${t}_*.B2 > $BALDIR/$simpref/all_c${t}.B2
done

## 1.2 100 neutral sims for testing (taken from the simulations used for genome-wide neutral SFS) 
simpref=neutral_N2k_r1e-8
for t in 16000 32000 160000 320000
do
awk '$1==4999' $BALDIR/$simpref/output_*_c${t}_*.B2 > $BALDIR/$simpref/all_c${t}.B2
done

## 1.3 sims with selection need to be parsed per selection grid cell
simpref=OD_N2k_r1e-8_grid0.1

for s1 in 0.1 0.2 0.5 0.9 1
do for s2 in 0.1 0.2 0.5 0.9 1
do for t in 16000 32000 160000 320000
    do awk '$1==4999' $BALDIR/$simpref/output_*${s1}-${s2}_*c${t}_*.B2 > $BALDIR/$simpref/all_s${s1}-${s2}_c${t}.B2
done
done
done

# 2. power analyses
#selB2file <- args[1]
#neutralB2file <- args[2]
#seltype <- args[3]
#Ne <- args[4]
#rec <- args[5]
#mut <- args[6]
#s1 <- args[7]
#s2 <- args[8]
#t <- args[9]
simpref=neutral_N2k_r1e-8
for t in 16000 32000 160000 320000; do
#Rscript ballerpower.R $BALDIR/$simpref/all_c${t}.B2 $BALDIR/neutral_N2k_r1e-8_fornull/all_c${t}.B2
qsub -v selB2file=$BALDIR/$simpref/all_c${t}.B2,neuB2file=$BALDIR/neutral_N2k_r1e-8_fornull/all_c${t}.B2 job_ballerpower.sh
done

for simpref in OD_N2k_r1e-8_grid0.1 AP_N2k_r1e-8_grid0.1 SA_N2k_r1e-8_grid0.1; do
seltype="OD"
Ne="2"
rec="1e-8"
simpref=${seltype}_N${Ne}k_r${rec}_grid0.1
for s1 in 0.1 0.2 0.5 0.9 1; do
for s2 in 0.1 0.2 0.5 0.9 1; do
    for t in 16000 32000 160000 320000; do
    Rscript ballerpower.R $BALDIR/$simpref/all_s${s1}-${s2}_c${t}.B2 $BALDIR/neutral_N2k_r1e-8_fornull/all_c${t}.B2
    done
done
done
done

for simpref in OD_N2k_r1e-8_grid0.01 AP_N2k_r1e-8_grid0.01 SA_N2k_r1e-8_grid0.01; do
for s1 in 0.01 0.02 0.05 0.09 0.1; do
for s2 in 0.01 0.02 0.05 0.09 0.1; do
    for t in 16000 32000 160000 320000; do
    Rscript ballerpower.R $BALDIR/$simpref/all_s${s1}-${s2}_c${t}.B2 $BALDIR/neutral_N2k_r1e-8_fornull/all_c${t}.B2
    done
done
done
done
