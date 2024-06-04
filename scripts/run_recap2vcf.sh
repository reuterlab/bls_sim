# Recapitate, add mutations and sample 100 individuals to generate vcf file

# Simulations with selection

# OD fine grid
#qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e3_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/OD_N1e3_grid0.01/',nspl=100,ne=1000 job_recapitate_selected.sh
#qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e4_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/OD_N1e4_grid0.01/',nspl=100,ne=10000 job_recapitate_selected.sh
#qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e5_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/OD_N1e5_grid0.01/',nspl=100,ne=100000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N20k_r1e-6_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/OD_N20k_r1e-6_grid0.01/',nspl=100,ne=20000,mu=1e-7,re=1e-6 job_recapitate_selected.sh
# OD coarse grid
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e3_grid0.1/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/OD_N1e3_grid0.1/',nspl=100,ne=1000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e4_grid0.1/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/OD_N1e4_grid0.1/',nspl=100,ne=10000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N1e5_grid0.1/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/OD_N1e5_grid0.1/',nspl=100,ne=100000 job_recapitate_selected.sh

# AP fine grid
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N1e3_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/AP_N1e3_grid0.01/',nspl=100,ne=1000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N1e4_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/AP_N1e4_grid0.01/',nspl=100,ne=10000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N1e5_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/AP_N1e5_grid0.01/',nspl=100,ne=100000 job_recapitate_selected.sh
# AP coarse grid
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N1e3_grid0.1/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/AP_N1e3_grid0.1/',nspl=100,ne=1000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N1e4_grid0.1/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/AP_N1e4_grid0.1/',nspl=100,ne=10000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/AP_N1e5_grid0.1/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/AP_N1e5_grid0.1/',nspl=100,ne=100000 job_recapitate_selected.sh

# SA fine grid
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N1e3_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/SA_N1e3_grid0.01/',nspl=100,ne=1000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N1e4_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/SA_N1e4_grid0.01/',nspl=100,ne=10000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N1e5_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/SA_N1e5_grid0.01/',nspl=100,ne=100000 job_recapitate_selected.sh
# SA coarse grid
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N1e3_grid0.1/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/SA_N1e3_grid0.1/',nspl=100,ne=1000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N1e4_grid0.1/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/SA_N1e4_grid0.1/',nspl=100,ne=10000 job_recapitate_selected.sh
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/SA_N1e5_grid0.1/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/SA_N1e5_grid0.1/',nspl=100,ne=100000 job_recapitate_selected.sh

# Neutral simulations
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N1e3/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/neutral_N1e3/',nspl=100,ne=1000 job_recapitate_neutral.sh
# TODO: RENAME INDIR TO REMOVE _OD FROM DIRECTORY NAMES
#qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N1e4/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/neutral_N1e4/',nspl=100,ne=10000 job_recapitate_neutral.sh
#qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N1e5/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/neutral_N1e5/',nspl=100,ne=100000 job_recapitate_neutral.sh
