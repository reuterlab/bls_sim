# grid 1: a finer grid for lower selection parameters
# 10x10 grid of selection coefficients from 0.01 to 0.1 by 0.01
# 2x dominance parameters: 0.5 and 0.25 
rep=100
for s1 in 0.01 0.02 0.05 0.1; do
    for s2 in 0.01 0.02 0.05 0.1; do
        for h in 0.5 0.25; do
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N2k_r1e-7_grid0.01/' -t 1-$rep job_run_AP_N2k_r1e-7.sh
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N2k_r1e-8_grid0.01/' -t 1-$rep job_run_AP_N2k_r1e-8.sh
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N20k_r1e-7_grid0.01/' -t 1-$rep job_run_AP_N20k_r1e-7.sh
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N20k_r1e-8_grid0.01/' -t 1-$rep job_run_AP_N20k_r1e-8.sh
        done
    done
done

# grid 2: a coarser grid for higher selection parameters
# 10x10 grid of selection coefficients from 0.2 to 1 by 0.1
# 2x dominance parameters: 0.5 and 0.25
for s1 in 0.1 0.2 0.5 1; do
    for s2 in 0.1 0.2 0.5 1; do
        for h in 0.5 0.25; do
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N2k_r1e-7_grid0.1/' -t 1-$rep job_run_AP_N2k_r1e-7.sh
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N2k_r1e-8_grid0.1/' -t 1-$rep job_run_AP_N2k_r1e-8.sh
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N20k_r1e-7_grid0.1/' -t 1-$rep job_run_AP_N20k_r1e-7.sh
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N20k_r1e-8_grid0.1/' -t 1-$rep job_run_AP_N20k_r1e-8.sh
        done
    done
done
