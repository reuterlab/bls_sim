# grid 1: a finer grid for lower selection parameters
# 10x10 grid of selection coefficients from 0.01 to 0.1 by 0.01
# 2x dominance parameters: 0.5 and 0.25 
rep=100
for s1 in 0.01 0.02 0.05 0.1; do
    for s2 in 0.01 0.02 0.05 0.1; do
        for h in 0.5 0.25; do
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N20k_r1e-8_grid0.01_extra/' -t 1-$rep job_run_AP_N20k_r1e-8.sh
        done
    done
done

# grid 2: a coarser grid for higher selection parameters
# 10x10 grid of selection coefficients from 0.2 to 1 by 0.1
# 2x dominance parameters: 0.5 and 0.25
for s1 in 0.1 0.2 0.5 1; do
    for s2 in 0.1 0.2 0.5 1; do
        for h in 0.5 0.25; do
            qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N20k_r1e-8_grid0.1_extra/' -t 1-$rep job_run_AP_N20k_r1e-8.sh
        done
    done
done

cd ~/balsel_detection/bls_sim/slimout
tar czvf AP_N20k_r1e-8_grid0.01_extra.tar.gz AP_N20k_r1e-8_grid0.01_extra
tar czvf AP_N20k_r1e-8_grid0.1_extra.tar.gz AP_N20k_r1e-8_grid0.1_extra

#----------------
# current sets missing to complete 100 [[22-07-2025]] (from vcf/APSA_100.log)  
# 64 reps for /SAN/reuterlab/balsel_detection/bls_sim/vcf/AP_N20k_r1e-8_grid0.1_m1e-8_100/output_s0.1-0.1_h0.5_*_c160000_*vcf.gz
# 86 reps for /SAN/reuterlab/balsel_detection/bls_sim/vcf/AP_N20k_r1e-8_grid0.01_m1e-8_100/output_s0.02-0.05_h0.25_*_c160000_*vcf.gz
# 60 reps for /SAN/reuterlab/balsel_detection/bls_sim/vcf/AP_N20k_r1e-8_grid0.1_m1e-8_100/output_s0.1-0.1_h0.25_*_c160000_*vcf.gz
# -> starting 200 more sim reps for those, to complete 100 each. 0.1-0.1 is fine because those were repeated in the other grid

rep=200
s1=0.02;s2=0.05;h=0.25
qsub -v s1=$s1,s2=$s2,h=$h,rand_inv=1,OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N20k_r1e-8_grid0.01_extra/' -t 1-$rep job_run_AP_N20k_r1e-8.sh
mv AP_N20k_r1e-8_grid0.01_extra AP_N20k_r1e-8_grid0.01_extra2
tar xzvf AP_N20k_r1e-8_grid0.01_extra.tar.gz
mv AP_N20k_r1e-8_grid0.01_extra2/* AP_N20k_r1e-8_grid0.01_extra/
tar czvf AP_N20k_r1e-8_grid0.01_extra.tar.gz AP_N20k_r1e-8_grid0.01_extra # DOING HERE
rm -rf AP_N20k_r1e-8_grid0.01_extra2
tar tf AP_N20k_r1e-8_grid0.01_extra.tar.gz|wc -l #6537
ls AP_N20k_r1e-8_grid0.01_extra|wc -l #6536
rm -rf AP_N20k_r1e-8_grid0.01_extra
