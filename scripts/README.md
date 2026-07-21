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

## 3. recapitate tree sequences, generate vcf
`job3_ts2vcf.sh`

- example:
```
paramsfile=params.txt
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile |awk '{print$1}') job3_ts2vcf.sh
```

## (4. generate ballermix input and helper files - not needed for NCD) 

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

### NCD

`job5b_run_ncd_tf.sh`

- example:
```
qsub -v PARAMSFILE=$paramsfile -v TF=0.5 -v WINSIZE=3000 -t 1-$(wc -l $paramsfile |awk '{print$1}') job5b_run_ncd_tf.sh 
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
