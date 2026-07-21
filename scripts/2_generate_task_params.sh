write_line() { printf $seltype" "$Ne" "$rec" "$mut" "$selage" "$h" "$grid" "$s1" "$s2" "$rep"\n" >> params.txt; }

rm params.txt

################
# NEUTRAL SIMS #
################

seltype="neutralnull"
rep=1000
h=0;grid=0;s1=0;s2=0
for Ne in 2000 20000; do
for rec in 1e-7 1e-8; do
for mut in 1e-7 1e-8; do
for selage in 16000 32000 160000 320000;do
    write_line
done;done;done;done

seltype="neutralgenome"
rep=3000
for Ne in 2000 20000; do
for rec in 1e-7 1e-8; do
for mut in 1e-7 1e-8; do
for selage in 16000 32000 160000 320000;do
    write_line
done;done;done;done

#######################
# SIMS with SELECTION #
#######################
rep=100

seltype="OD"
h=0
for Ne in 2000 20000; do
for rec in 1e-7 1e-8; do
for mut in 1e-7 1e-8; do
for selage in 16000 32000 160000 320000;do
    grid=0.01
    for s1 in 0.01 0.02 0.05 0.1; do
    for s2 in 0.01 0.02 0.05 0.1; do
        write_line
    done;done;
    grid=0.1
    for s1 in 0.1 0.2 0.5 1; do
    for s2 in 0.1 0.2 0.5 1; do
        write_line
    done;done
done;done;done;done

for seltype in AP SA; do
for Ne in 2000 20000; do
for rec in 1e-7 1e-8; do
for mut in 1e-7 1e-8; do
for selage in 16000 32000 160000 320000;do
for h in 0.5 0.25; do
    grid=0.01
    for s1 in 0.01 0.02 0.05 0.09 0.1; do
    for s2 in 0.01 0.02 0.05 0.09 0.1; do
        write_line
    done; done;
    grid=0.1
    for s1 in 0.1 0.2 0.5 0.9 1; do
    for s2 in 0.1 0.2 0.5 0.9 1; do
        write_line
    done;done
done;done;done;done;done;done

#------------------------------------------#
# Params files with one replicate per line #
#------------------------------------------#

write_line() { printf $seltype" "$Ne" "$rec" "$mut" "$selage" "$h" "$grid" "$s1" "$s2" "$rep"\n" >> params_reps.txt; }

rm params_reps.txt

################
# NEUTRAL SIMS #
################

seltype="neutralnull"
nrep=1000
h=0;grid=0;s1=0;s2=0
for Ne in 2000 20000; do
for rec in 1e-7 1e-8; do
for mut in 1e-7 1e-8; do
for selage in 16000 32000 160000 320000;do
for rep in $(seq 1 ${nrep}); do
        write_line
done;done;done;done;done

seltype="neutralgenome"
nrep=3000
for Ne in 2000 20000; do
for rec in 1e-7 1e-8; do
for mut in 1e-7 1e-8; do
for selage in 16000 32000 160000 320000;do
for rep in $(seq 1 ${nrep}); do
        write_line
done;done;done;done;done

#######################
# SIMS with SELECTION #
#######################
nrep=100

seltype="OD"
h=0
for Ne in 2000 20000; do
for rec in 1e-7 1e-8; do
for mut in 1e-7 1e-8; do
for selage in 16000 32000 160000 320000;do
    grid=0.01
    for s1 in 0.01 0.02 0.05 0.09 0.1; do
    for s2 in 0.01 0.02 0.05 0.09 0.1; do
    for rep in $(seq 1 ${nrep}); do
        write_line
    done;done;done;
    grid=0.1
    for s1 in 0.1 0.2 0.5 0.9 1; do
    for s2 in 0.1 0.2 0.5 0.9 1; do
    for rep in $(seq 1 ${nrep}); do
        write_line
    done;done;done
done;done;done;done

for seltype in AP SA; do
for Ne in 2000 20000; do
for rec in 1e-7 1e-8; do
for mut in 1e-7 1e-8; do
for selage in 16000 32000 160000 320000;do
for h in 0.5 0.25; do
    grid=0.01
    for s1 in 0.01 0.02 0.05 0.09 0.1; do
    for s2 in 0.01 0.02 0.05 0.09 0.1; do
    for rep in $(seq 1 ${nrep}); do
        write_line
    done; done;done;
    grid=0.1
    for s1 in 0.1 0.2 0.5 0.9 1; do
    for s2 in 0.1 0.2 0.5 0.9 1; do
    for rep in $(seq 1 ${nrep}); do
        write_line
    done;done;done
done;done;done;done;done;done
