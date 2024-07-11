#----- wrong run - fixed
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8' -t 1-$rep job_run_neutral_N2k_r1e-8.sh # wrong OUTdir and slim script
qdel 4281843
rm /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8/*r1*j4281843* # bc arg list too long below
rm /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8/*r2*j4281843* # bc arg list too long below
rm /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8/*r3*j4281843* # bc arg list too long below
rm /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8/*r4*j4281843* # bc arg list too long below
rm /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8/*r5*j4281843* # bc arg list too long below
rm /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8/*r6*j4281843* # bc arg list too long below
rm /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8/*r7*j4281843* # bc arg list too long below
rm /SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8/*j4281843*
#-----

rep=3000
qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N2k_r1e-8' -t 1-$rep job_run_neutral_N2k_r1e-8.sh

qsub -v OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N20k_r1e-8' -t 1-$rep job_run_neutral_N20k_r1e-8.sh
