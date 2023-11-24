# grid 1: a finer grid for lower selection parameters
# 10x10 grid of selection coefficients from 0.01 to 0.1 by 0.01
# 2x dominance parameters: 0.5 and 0.25
rep=100
for s1 in $(seq 0.01 0.01 0.1); do
    for s2 in $(seq 0.01 0.01 0.1); do
            qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e3_grid0.01/' -t 1-$rep job_run_OD_N1e3.sh
            qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e4_grid0.01/' -t 1-$rep job_run_OD_N1e4.sh
            qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e5_grid0.01/' -t 1-$rep job_run_OD_N1e5.sh
    done
done
mkdir /SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e3_grid0.01
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e3_grid0.01/' job_plot0.01.sh
mkdir /SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e4_grid0.01
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e4_grid0.01/' job_plot0.01.sh
mkdir /SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e5_grid0.01
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e5_grid0.01/' job_plot0.01.sh

# grid 2: a coarser grid for higher selection parameters
# 10x10 grid of selection coefficients from 0.1 to 1 by 0.1
# 2x dominance parameters: 0.5 and 0.25
for s1 in $(seq 0.1 0.1 1); do
    for s2 in $(seq 0.1 0.1 1); do
            qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e3_grid0.1/' -t 1-$rep job_run_OD_N1e3.sh
            qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e4_grid0.1/' -t 1-$rep job_run_OD_N1e4.sh
            qsub -v s1=$s1,s2=$s2,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e5_grid0.1/' -t 1-$rep job_run_OD_N1e5.sh
    done
done
mkdir /SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e3_grid0.1
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e3_grid0.1/' job_plot0.1.sh
mkdir /SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e4_grid0.1
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e4_grid0.1/' job_plot0.1.sh
mkdir /SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e5_grid0.1
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/plots/OD_N1e5_grid0.1/' job_plot0.1.sh
