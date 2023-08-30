OUTDIR=/home/debora/Dropbox/private/projects/uclpostdoc/bls_sim/slimout/

for s1 in 0.01 0.01 0.2; do
for s2 in 0.01 0.01 0.2; do
    for h in 0.5 0.25; do
        for REP in {1..10000}; do
            JOB_ID=$REP
            SEED=$RANDOM
            slim -d jobid=$JOB_ID -d d_seed=$SEED -d d_repID=$REP -d sel1=$s1 -d sel2=$s2 -d h=$h -d d_folder="'$OUTDIR/OD_N1e3/'" /home/debora/Dropbox/private/projects/uclpostdoc/bls_sim/slim/OD_N1e3.slim
        done
    done
done
done

wait

