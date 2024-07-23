# 1. parse baller output for power analysis -> extract only line corresponding to central site 4999
BALDIR=/SAN/reuterlab/balsel_detection/bls_sim/baller/results/

## 1.1 1000 neutral sims fornull [DONE]
simpref=neutral_N2k_r1e-8_fornull
for t in 16000 32000 160000 320000
do
awk '$1==4999' $BALDIR/$simpref/output_*_c${t}_*.B2 > $BALDIR/$simpref/all_c${t}.B2
done

## 1.2 100 neutral sims for testing (taken from the 3000 simulations used for genome-wide neutral SFS) [DONE]
simpref=neutral_N2k_r1e-8
for t in 16000 32000 160000 320000
do
awk '$1==4999' $BALDIR/$simpref/output_*_c${t}_*.B2 > $BALDIR/$simpref/all_c${t}.B2
done

## 1.3 sims with selection need to be parsed per selection grid cell
#[DONE] - check that both numbers below match 6276 B2 files
#ls ../baller/results/OD_N2k_r1e-8_grid0.1/output_s*|wc
#wc ../baller/results/OD_N2k_r1e-8_grid0.1/all_s*B2
simpref=OD_N2k_r1e-8_grid0.1 #6276 B2 files
for s1 in 0.1 0.2 0.5 0.9 1; do
for s2 in 0.1 0.2 0.5 0.9 1; do
for t in 16000 32000 160000 320000; do
    awk '$1==4999' $BALDIR/$simpref/output_s${s1}-${s2}_*c${t}_*.B2 > $BALDIR/$simpref/all_s${s1}-${s2}_c${t}.B2
done
done
done
#[DONE]
simpref=OD_N2k_r1e-8_grid0.01 #4891 B2 files
for s1 in 0.01 0.02 0.05 0.09 0.1; do
for s2 in 0.01 0.02 0.05 0.09 0.1; do
for t in 16000 32000 160000 320000; do
    awk '$1==4999' $BALDIR/$simpref/output_s${s1}-${s2}_*c${t}_*.B2 > $BALDIR/$simpref/all_s${s1}-${s2}_c${t}.B2
done
done
done


#[TODO]
# AP coarse grid -> 5267 trees files
simpref=AP_N2k_r1e-8_grid0.1
for s1 in 0.1 0.2 0.5 0.9 1; do
for s2 in 0.1 0.2 0.5 0.9 1; do
for h in 0.25 0.5; do
for t in 16000 32000 160000 320000; do
    awk '$1==4999' $BALDIR/$simpref/output_t${s1}-${s2}_h${h}_*c${t}_*.B2 > $BALDIR/$simpref/all_s${s1}-${s2}_h${h}_c${t}.B2
done
done
done
done
# AP fine grid -> 2755 trees files
simpref=AP_N2k_r1e-8_grid0.01
for s1 in 0.01 0.02 0.05 0.09 0.1; do
for s2 in 0.01 0.02 0.05 0.09 0.1; do
for h in 0.25 0.5; do
for t in 16000 32000 160000 320000; do
    awk '$1==4999' $BALDIR/$simpref/output_t${s1}-${s2}_h${h}_*c${t}_*.B2 > $BALDIR/$simpref/all_s${s1}-${s2}_h${h}_c${t}.B2
done
done
done
done


#[TODO]
# SA coarse grid -> 5346 trees files
simpref=SA_N2k_r1e-8_grid0.1
for s1 in 0.1 0.2 0.5 0.9 1; do
for s2 in 0.1 0.2 0.5 0.9 1; do
for h in 0.25 0.5; do
for t in 16000 32000 160000 320000; do
    awk '$1==4999' $BALDIR/$simpref/output_sfm${s1}-${s2}_h${h}_*c${t}_*.B2 > $BALDIR/$simpref/all_s${s1}-${s2}_h${h}_c${t}.B2
done
done
done
# SA fine grid -> 2066 trees files
simpref=SA_N2k_r1e-8_grid0.01
for s1 in 0.01 0.02 0.05 0.09 0.1; do
for s2 in 0.01 0.02 0.05 0.09 0.1; do
for h in 0.25 0.5; do
for t in 16000 32000 160000 320000; do
    awk '$1==4999' $BALDIR/$simpref/output_sfm${s1}-${s2}_h${h}_*c${t}_*.B2 > $BALDIR/$simpref/all_s${s1}-${s2}_h${h}_c${t}.B2
done
done
done


# 2. power analyses

# [TODO]
seltype="neutral"
Ne="2"
rec="1e-8"
mut="1e-8"
simpref=${seltype}_N${Ne}k_r${rec}
s1=0
s2=0
for t in 16000 32000 160000 320000; do
qsub -v selB2file=$BALDIR/$simpref/all_c${t}.B2,neuB2file=$BALDIR/neutral_N2k_r1e-8_fornull/all_c${t}.B2,seltype=$seltype,Ne=$Ne,rec=$rec,mut=$mut,s1=$s2,s2=$s2 job_ballerpower.sh
#Rscript ballerpower.R $selB2file $neuB2file $seltype $Ne $rec $mut $s1 $s2 $t
done

Ne="2"
rec="1e-8"
mut="1e-8"
seltype="OD"
simpref=${seltype}_N${Ne}k_r${rec}_grid0.1
for s1 in 0.1 0.2 0.5 0.9 1; do
for s2 in 0.1 0.2 0.5 0.9 1; do
    for t in 16000 32000 160000 320000; do
    Rscript ballerpower.R $BALDIR/$simpref/all_s${s1}-${s2}_c${t}.B2 $BALDIR/neutral_N2k_r1e-8_fornull/all_c${t}.B2 $seltype $Ne $rec $mut $s1 $s2 $t
    done
done
done
cat $BALDIR/$simpref/all_s*_power.txt > $BALDIR/$simpref/allpower.txt
Rscript plot_baller_power.R

simpref=${seltype}_N${Ne}k_r${rec}_grid0.01
for s1 in 0.01 0.02 0.05 0.09 0.1; do
for s2 in 0.01 0.02 0.05 0.09 0.1; do
    for t in 16000 32000 160000 320000; do
    Rscript ballerpower.R $BALDIR/$simpref/all_s${s1}-${s2}_c${t}.B2 $BALDIR/neutral_N2k_r1e-8_fornull/all_c${t}.B2 $seltype $Ne $rec $mut $s1 $s2 $t
    done
done
done
cat $BALDIR/$simpref/all_s*_power.txt > $BALDIR/$simpref/allpower.txt
Rscript plot_baller_power.R
