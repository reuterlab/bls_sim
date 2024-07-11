# Recapitate, add mutations and sample 100 individuals to generate vcf file

# Neutral simulations

# N2k r1e-8 
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N2k_r1e-8/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/neutral_N2k_r1e-8/',nspl=100,ne=2000,mu=1e-8,re=1e-8 job_recapitate_neutral.sh

# Simulations with selection

# N2k r1e-8
# OD fine grid
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N2k_r1e-8_grid0.01/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/OD_N2k_r1e-8_grid0.01/',nspl=100,ne=2000,mu=1e-8,re=1e-8 job_recapitate_selected.sh
# OD coarse grid
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/OD_N2k_r1e-8_grid0.1/',OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/vcf/OD_N2k_r1e-8_grid0.1/',nspl=100,ne=2000,mu=1e-8,re=1e-8 job_recapitate_selected.sh

# AP fine grid
# AP coarse grid

# SA fine grid
# SA coarse grid
