# ROADMAP

## 1. run SLiM simulations with the following calls:

```
1_run_OD_rec.sh
1_run_AP_rec.sh
1_run_SA_rec.sh
1_run_neutral_rec.sh
```

## 2. generate parameter combinations (output=params.txt)
`2_generate_task_params.sh`

## 3. recapitate tree sequences, generate vcf and bal
`job3_ts2ballermixinput.sh`

- example:
```
awk '$2==20000 && $3==1e-8 && $4==1e-7' params.txt > params_N20k_r1e-8_m1e-7.txt
paramsfile=params_N20k_r1e-8_m1e-7.txt
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile |awk '{print$1}') job3_ts2ballermixinput.sh
```

## 4. generate ballermix helper files
`job4_ballermix_helperfiles.sh`

- example:
```
paramsfile=params.txt
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile | awk '{print $1}') job4_ballermix_helperfiles.sh
```

## 5. run ballermix -> tasks for all params except neutralgenome
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
`job6_ballerpower_oldfilenames.sh` and `job6_ballerpower.sh`

- examples:
```
awk '$2==20000 && $3==1e-8 && $4==1e-8' params.txt > params_N20k_r1e-8_m1e-8.txt
paramsfile=params_N20k_r1e-8_m1e-8.txt
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile |awk '{print$1}')  job6_ballerpower_oldfilenames.sh

paramsfile=params_N2k_r1e-7_m1e-7.txt
qsub -v PARAMSFILE=$paramsfile -t 1-$(wc -l $paramsfile |awk '{print$1}')  job6_ballerpower.sh
```

## 7. extract power at alpha=0.01 and alpha=0.05 for comparisons done locally
```
BALDIR=/SAN/reuterlab/balsel_detection/bls_sim/baller/results/
cat ${BALDIR}/*/all_s*_power.txt |sort -ur > ${BALDIR}/allpower.txt
awk 'NR==1 {print}; NR>1 && $1==0.01 {print}' $BALDIR/allpower.txt > $BALDIR/power_01.txt
awk 'NR==1 {print}; NR>1 && $1==0.05 {print}' $BALDIR/allpower.txt > $BALDIR/power_05.txt
```
