rep=3000 # initially ran 3000 simulations for ballermix genomewide sfs -> these need to be recapitated again to save ts equivalent to vcf
rep=1000 # [17/7] ran 1000 additional neutral simulations for Ballermix null distribution # jobs 4338072 4338073
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N2k_r1e-8' -t 1-$rep job_run_neutral_N2k_r1e-8.sh
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8' -t 1-$rep job_run_neutral_N20k_r1e-8.sh

# move additional 1000 simulations to a separate folder
mkdir /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N2k_r1e-8_fornull
mv /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N2k_r1e-8/*j4338072* /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N2k_r1e-8_fornull

mkdir /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8_fornull
mv /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8/*j4338073* /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8_fornull
# additional sims with reps that had segfault (see run_neutral_rep_fixfaultytasks.sh)
mv /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8/*j4340204* /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8_fornull

rep=3000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralgenome_N20k_r1e-8' -t 1-$rep job_run_neutral_N20k_r1e-7.sh
rep=1000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralnull_N20k_r1e-8' -t 1-$rep job_run_neutral_N20k_r1e-7.sh

rep=3000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralgenome_N2k_r1e-7_grid0' -t 1-$rep job_run_neutral_N2k_r1e-7.sh
rep=1000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutralnull_N2k_r1e-7_grid0' -t 1-$rep job_run_neutral_N2k_r1e-7.sh

### TO DO: RENAME OUTDIR TO r1e-7, THEN RENAME THE files:
# rename files so that it follows the same pattern as the other seltypes
# 1----
#Ne=20
#r=1e-8
#for seltype in neutral neutralfornull; do
# 1----
Ne=2
r=1e-7
for seltype in neutralgenome neutralnull; do
            FILEPATH=/SAN/reuterlab/balsel_detection/bls_sim/slimout/${seltype}_N${Ne}k_r${r}/
            NEWFILEPATH=/SAN/reuterlab/balsel_detection/bls_sim/slimout/${seltype}_N${Ne}k_r${r}_grid0/
            echo $FILEPATH
            ls $FILEPATH|wc
            mkdir $NEWFILEPATH
            for FILE in ${FILEPATH}/*; do
                NEWNAME=$(basename $FILE| awk -F"_" -v OFS="_" '$2="s0-0_h0_"$2')
                mv $FILE ${NEWFILEPATH}/$NEWNAME
        done;done;
# 1----
 #mv neutralfornull_N20k_r1e-8_grid0/ neutralnull_N20k_r1e-8_grid0/
 #mv neutral_N20k_r1e-8_grid0/ neutralgenome_N20k_r1e-8_grid0/
# 1----
