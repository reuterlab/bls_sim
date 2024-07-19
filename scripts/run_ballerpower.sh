# 1. parse baller output for power analysis

## 1.1 neutral sims
BALDIR=/SAN/reuterlab/balsel_detection/bls_sim/baller/results/
simpref=neutral_N2k_r1e-8
for t in 16000 32000 160000 320000
do
awk '$1==4999' $BALDIR/$simpref/output_*_c${t}_*.B2 > $BALDIR/$simpref/all_c${t}.B2
done

## 1.2 sims with selection need to be parsed per selection grid cell
BALDIR=/SAN/reuterlab/balsel_detection/bls_sim/baller/results/
simpref=OD_N2k_r1e-8_grid0.1

for s1 in 0.1 0.2 0.5 0.9 1
do for s2 in 0.1 0.2 0.5 0.9 1
do for t in 16000 32000 160000 320000
    do awk '$1==4999' $BALDIR/$simpref/output_*${s1}-${s2}_*c${t}_*.B2 > $BALDIR/$simpref/all_s${s1}-${s2}_c${t}.B2
done
done
done
