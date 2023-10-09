# grid 1: a finer grid for lower selection parameters
# 10x10 grid of selection coefficients from 0.01 to 0.1 by 0.01
# 2x dominance parameters: 0.5 and 0.25
rep=100
for s1 in $(seq 0.01 0.01 0.1); do
    for s2 in $(seq 0.01 0.01 0.1); do
        for h in 0.5 0.25; do
            qsub -v s1=$s1,s2=$s2,h=$h,OUTDIR='/home/dbrandt/balsel_detection/bls_sim/slimout/AP_N1e3_grid0.01/' -t 1-$rep job_run_AP_N1e3.sh
            #qsub -v s1=$s1,s2=$s2,h=$h,OUTDIR='/home/dbrandt/balsel_detection/bls_sim/slimout/AP_N1e4_grid0.01/' -t 1-$rep job_run_AP_N1e4.sh
            #qsub -v s1=$s1,s2=$s2,h=$h,OUTDIR='/home/dbrandt/balsel_detection/bls_sim/slimout/AP_N1e5_grid0.01/' -t 1-$rep job_run_AP_N1e5.sh
        done
    done
done

# NOTE: on CS cluster, run plotting script with python 3:
# use an interactive session with qrsh, ex: qrsh -l tmem=4G,h_vmem=4G,h_rt=2:00:00
# module load python/3.8.5
python3 plot_grids_0.01.py --outdir /SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N1e3_grid0.01

# grid 2: a coarser grid for higher selection parameters
# 10x10 grid of selection coefficients from 0.1 to 1 by 0.1
# 2x dominance parameters: 0.5 and 0.25
rep=100
for s1 in $(seq 0.1 0.1 1); do
    for s2 in $(seq 0.1 0.1 1); do
        for h in 0.5 0.25; do
            qsub -v s1=$s1,s2=$s2,h=$h,OUTDIR='/home/dbrandt/balsel_detection/bls_sim/slimout/AP_N1e3_grid0.1/' -t 1-$rep job_run_AP_N1e3.sh
            qsub -v s1=$s1,s2=$s2,h=$h,OUTDIR='/home/dbrandt/balsel_detection/bls_sim/slimout/AP_N1e4_grid0.1/' -t 1-$rep job_run_AP_N1e4.sh
            qsub -v s1=$s1,s2=$s2,h=$h,OUTDIR='/home/dbrandt/balsel_detection/bls_sim/slimout/AP_N1e5_grid0.1/' -t 1-$rep job_run_AP_N1e5.sh
        done
    done
done

python3 plot_grids_0.1.py --outdir /SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N1e3_grid0.1
