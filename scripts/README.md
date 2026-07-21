# ROADMAP

## 1. run SLiM simulations with the following calls:

- initiate 100 simulations
```
1_run_OD_rec.sh
1_run_AP_rec.sh
1_run_SA_rec.sh
1_run_neutral_rec.sh
```

- initiate extra simulations to complete set of 100 simulations with polymorphism maintained
```
1_run_OD_rec_extras.sh
1_run_AP_rec_extras.sh
1_run_SA_rec_extras.sh
```

## 2. generate parameter combinations (output=params.txt)
`2_generate_task_params.sh`

- add alpha and pstar columns
`Rscript params_add_feq.R`

- generate neutral params file with corresponding pstar for running ncd
```
grep neutralnull params.txt > params_neutralnull.txt
Rscript params_neu_add_feq.R
```

## 3. recapitate tree sequences, generate vcf
`job3_ts2vcf.sh`

- example:
```
paramsfile=params.txt
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile |awk '{print$1}') job3_ts2vcf.sh
```

## 4a. cp sets of 100 vcfs to a dir and run next steps from there
```
cd /SAN/reuterlab/balsel_detection/bls_sim/vcf

complete_100() {
    DIR=/SAN/reuterlab/balsel_detection/bls_sim/vcf/${seltype}_N${N}k_r${r}_grid${g}_m${m}
    nvcf=$(ls $DIR/output_s${s1}-${s2}_h${h}_*_c${selage}_*vcf.gz|wc -l)
    if [ $nvcf -gt 10 ] ; then
        mkdir -p ${DIR}_100/
        ls ${DIR}/output_s${s1}-${s2}_h${h}_*_c${selage}_*vcf.gz > ${DIR}_100/output_s${s1}-${s2}_h${h}_c${selage}_fnames.txt
        rep=1
        DIRextra=/SAN/reuterlab/balsel_detection/bls_sim/vcf/${seltype}_N${N}k_r${r}_grid${g}_extra_m${m}
        while [ $nvcf -lt 100 ] && [ $rep -le 100 ] ; do
            if ls ${DIRextra}/output_s${s1}-${s2}_h${h}_r${rep}_*_c${selage}_*vcf.gz 1> /dev/null 2>&1; then
                ls ${DIRextra}/output_s${s1}-${s2}_h${h}_r${rep}_*_c${selage}_*vcf.gz >> ${DIR}_100/output_s${s1}-${s2}_h${h}_c${selage}_fnames.txt
                nvcf=$(wc -l ${DIR}_100/output_s${s1}-${s2}_h${h}_c${selage}_fnames.txt |awk '{print $1}')
            fi
            ((rep++))
        done
        echo "$nvcf reps for ${DIR}_100/output_s${s1}-${s2}_h${h}_*_c${selage}_*vcf.gz"
    else
        echo "Not completing sims from ${DIR}/output_s${s1}-${s2}_h${h}_*_c${selage}_*vcf.gz. $nvcf original reps with polym maintained"
    fi
}

seltype="OD"
for N in 2 20; do
for r in 1e-8 1e-7; do
for m in 1e-8 1e-7; do
for selage in 16000 32000 160000 320000; do
    g=0.01
    for s1 in 0.01 0.02 0.05 0.1; do
    for s2 in 0.01 0.02 0.05 0.1; do
        echo "$N $r $m $selage $s1 $s2"
        complete_100
    done; done
    g=0.1
    for s1 in 0.1 0.2 0.5 1; do
    for s2 in 0.1 0.2 0.5 1; do
        echo "$N $r $m $selage $s1 $s2"
        complete_100
    done;done
done;done;done;done > OD_100.log

r=1e-8
m=1e-8
N=20
for seltype in AP SA; do
for h in 0.5 0.25; do
for selage in 160000; do
    g=0.01
    for s1 in 0.01 0.02 0.05 0.1; do
    for s2 in 0.01 0.02 0.05 0.1; do
        echo "$N $r $m $selage $s1 $s2"
        complete_100
    done; done
    g=0.1
    for s1 in 0.1 0.2 0.5 1; do
    for s2 in 0.1 0.2 0.5 1; do
        echo "$N $r $m $selage $s1 $s2"
        complete_100
    done;done
done;done;done > APSA_100.log
``` 

## 4b. generate ballermix input and helper files - not needed for NCD

- ballermix input files from vcf files (for sets of 100 simulations with selection and for sets of 1000 neutral simulations): 

`job3_vcf2ballermixinput_100.sh` and `job3_vcf2ballermixinput_nn.sh`

  - example runs:
```
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile |awk '{print$1}') job3_vcf2ballermixinput_100.sh
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile |awk '{print$1}') job3_vcf2ballermixinput_nn.sh
```

- ballermix helper files

`job4_ballermix_helperfiles.sh`

  - example:
```
paramsfile=params.txt
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile | awk '{print $1}') job4_ballermix_helperfiles.sh
```

## 5. run selection scans

### NCD

`job5_run_ncd_tf_100.sh`

- examples:
```
# with target frequency fixed at 0.5
qsub -v PARAMSFILE=$paramsfile -v TF=0.5 -v WINSIZE=3000 -t 1-$(wc -l $paramsfile |awk '{print$1}') job5_run_ncd_tf_100.sh 

# with target frequency = equilibrium frequency
paramsfile=params_extras_main_feq.txt
qsub -v PARAMSFILE=$paramsfile -v WINSIZE=3000 -t 1-$(wc -l $paramsfile |awk '{print$1}') job5_run_ncd_tf_100.sh 
```

### Ballermix -> tasks for all params except neutralgenome
`job5_run_ballermix.sh`

- examples:
```
awk '$2==20000 && $3==1e-7 && $4==1e-8' params.txt | grep -v neutral > params_N20k_1e-7_m1e-8_sel.txt
paramsfile=params_N20k_1e-7_m1e-8_sel.txt
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile |awk '{print$1}') job5_run_ballermix.sh

# to run each rep as a task for neutralnull
awk '$1=="neutralnull" && $2==20000 && $3==1e-7 && $4==1e-8' params_reps.txt > params_reps_N20k_r1e-7_m1e-8_neu.txt
paramsfile=params_reps_N20k_r1e-7_m1e-8_neu.txt
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile |awk '{print$1}') job5_run_ballermix_reps.sh
```

## 6. calculate power per param combination
`job6_ballerpower.sh` and `job6b_ncdpower.sh`

- examples:
```
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile |awk '{print$1}')  job6_ballerpower.sh
qsub -v PARAMSFILE=$paramsfile -v TF=0.5 -v WINSIZE=1000 -t 1-$(wc -l $paramsfile |awk '{print $1}') job6b_ncdpower.sh
```

## 7. extract power at alpha=0.01 and alpha=0.05 for comparisons done locally
```
BALDIR=baller/results/
cat ${BALDIR}/*/all_s*_power.txt |sort -ur > ${BALDIR}/allpower.txt
awk 'NR==1 {print}; NR>1 && $1==0.01 {print}' $BALDIR/allpower.txt > $BALDIR/power_01.txt
awk 'NR==1 {print}; NR>1 && $1==0.05 {print}' $BALDIR/allpower.txt > $BALDIR/power_05.txt

NCDDIR=ncd/
cat ${NCDDIR}/*/all_s*_power.txt |sort -ur > ${NCDDIR}/allpower.txt
awk 'NR==1 {print}; NR>1 && $1==0.01 {print}' $NCDDIR/allpower.txt > $NCDDIR/power_01.txt
awk 'NR==1 {print}; NR>1 && $1==0.05 {print}' $NCDDIR/allpower.txt > $NCDDIR/power_05.txt
```
