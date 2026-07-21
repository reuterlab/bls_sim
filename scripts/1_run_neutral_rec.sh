# 3000 replicate simulations for genome wide distribution for Ballermix
# 1000 replicates for null distributions of NCD2 and B2
rep=3000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralgenome_N20k_r1e-8_grid0' -t 1-$rep job_run_neutral_N20k_r1e-8.sh
rep=1000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralnull_N20k_r1e-8_grid0' -t 1-$rep job_run_neutral_N20k_r1e-8.sh

rep=3000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralgenome_N2k_r1e-8_grid0' -t 1-$rep job_run_neutral_N2k_r1e-8.sh
rep=1000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralnull_N2k_r1e-8_grid0' -t 1-$rep job_run_neutral_N2k_r1e-8.sh

rep=3000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralgenome_N20k_r1e-7_grid0' -t 1-$rep job_run_neutral_N20k_r1e-7.sh
rep=1000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralnull_N20k_r1e-7_grid0' -t 1-$rep job_run_neutral_N20k_r1e-7.sh

rep=3000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralgenome_N2k_r1e-7_grid0' -t 1-$rep job_run_neutral_N2k_r1e-7.sh
rep=1000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralnull_N2k_r1e-7_grid0' -t 1-$rep job_run_neutral_N2k_r1e-7.sh
