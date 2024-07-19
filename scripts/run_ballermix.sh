# 1. Parse vcf files for ballermix input
# - n is the number of samples (columns) in the vcf files
qsub -v simpref=neutral_N2k_r1e-8,n=100 job_parsevcf4ballermix.sh
qsub -v simpref=OD_N2k_r1e-8_grid0.01,n=100 job_parsevcf4ballermix.sh
qsub -v simpref=OD_N2k_r1e-8_grid0.1,n=100 job_parsevcf4ballermix.sh
qsub -v simpref=AP_N2k_r1e-8_grid0.01,n=100 job_parsevcf4ballermix.sh
qsub -v simpref=AP_N2k_r1e-8_grid0.1,n=100 job_parsevcf4ballermix.sh
qsub -v simpref=SA_N2k_r1e-8_grid0.01,n=100 job_parsevcf4ballermix.sh
qsub -v simpref=SA_N2k_r1e-8_grid0.1,n=100 job_parsevcf4ballermix.sh
qsub -v simpref=neutral_N2k_r1e-8_fornull,n=100 job_parsevcf4ballermix.sh

# 1. Generate helper files (SFS) for Ballermix.
# - n is the number of samples (columns) in the vcf files
# - simpref is the prefix of the neutral simulations
qsub -v simpref=neutral_N2k_r1e-8,n=100 job_ballermixhelperfiles.sh
qsub -v simpref=neutral_N20k_r1e-8,n=100 job_ballermixhelperfiles.sh
# will generate 4 helper files, for each of the simulation sets: c16k, c32k, c160k,c320k
# sanity checks: plot_baller_sfs.R and segregating_sites_baller.R

## TODO[AP,SA,neutral] run ballermix B2 on neutral, OD, AP and SA simulations
for simpref in neutral_N2k_r1e-8_fornull AP_N2k_r1e-8_grid0.01 AP_N2k_r1e-8_grid0.1 SA_N2k_r1e-8_grid0.01 SA_N2k_r1e-8_grid0.1 # OD_N2k_r1e-8_grid0.01 OD_N2k_r1e-8_grid0.1
do
    for age in 16000 32000 160000 320000
    do
    qsub -v simpref=$simpref,age=$age job_B2.sh
done
done

PATH=/share/apps/R-4.2.2/bin/:$PATH 
# get genome-wide percentiles
for pop in Zambia USA France
do echo $pop
    for win in 1000 #5000 10000
    do echo $win
        for bstat in B2 B2maf B0 B0maf
        do echo $bstat
        cut -f3 ../results/ballermix/${pop}_chr*_w${win}.${bstat} |grep -v LR|sort -rn > ../results/ballermix/sortedBs
        n=$(wc -l ../results/ballermix/sortedBs | awk '{print $1}')
        q999=$(awk -v n=$((n/1000)) 'NR==n' ../results/ballermix/sortedBs)
        q9995=$(awk -v n=$((n/2000)) 'NR==n' ../results/ballermix/sortedBs)
        max=$(head -n1 ../results/ballermix/sortedBs)
            for chr in 2L 2R 3L 3R X
            do echo $chr
                Rscript plotballer.R -i ../results/ballermix/${pop}_chr${chr}_w${win}.${bstat} -o ../results/ballermix/${pop}_chr${chr}_w${win}.${bstat} -c chr${chr} -m $max -q $q999,$q9995 -p '99.9%,99.95%'
            done
        done
    done
done

# Zambia B2: plot with ymax on q99.9 to see chr3 and chrX
pop=Zambia;bstat=B2;win=1000
cut -f3 ../results/ballermix/${pop}_chr*_w${win}.${bstat} |grep -v LR| sort -rn > tmp
n=$(wc -l tmp | awk '{print $1}')
q999=$(awk -v n=$((n/1000)) 'NR==n' tmp)
q9995=$(awk -v n=$((n/2000)) 'NR==n' tmp)
max=$q999
for chr in 3L 3R X
do echo $chr
    Rscript plotballer.R -i ../results/ballermix/${pop}_chr${chr}_w${win}.${bstat} -o ../results/ballermix/${pop}_chr${chr}_w${win}_ylim.${bstat} -c chr${chr} -m $max -q $q999,$q9995 -p '99.9%,99.95%'
done

# peaks
win=1000
for pop in Zambia USA France
do echo $pop
    cut -f3 ../results/ballermix/B2/${pop}_chr*_w${win}.B2 |grep -v LR|sort -rn > ../results/ballermix/B2/${pop}_allchr_w${win}.sortedB2.txt
    n=$(wc -l ../results/ballermix/B2/${pop}_allchr_w${win}.sortedB2.txt | awk '{print $1}')
    awk -v n=$((n/1000)) 'NR==n' ../results/ballermix/B2/${pop}_allchr_w${win}.sortedB2.txt > ../results/ballermix/B2/${pop}_w${win}_B2q999.txt
done
more ../results/ballermix/B2/*q999.txt

awk '$3>1380.8807210408268' ../results/ballermix/B2/Zambia_chr2L_w1000.B2 |less
# regions to plot
#1766440-1777208
#1811370-1815669
#20286061-20289416
#21396873-21399994
#22171919-22289996
awk '$3>1380.8807210408268' ../results/ballermix/B2/Zambia_chr2R_w1000.B2 |less
#863690-895573
#2153946-2206776
#2322138-2367044
awk '$3>1380.8807210408268' ../results/ballermix/B2/Zambia_chr3L_w1000.B2 |less
# no peaks in chr3L chr3R
awk '$3>1380.8807210408268' ../results/ballermix/B2/Zambia_chr3R_w1000.B2 |less
# no peaks in chr3L chr3R
awk '$3>1380.8807210408268' ../results/ballermix/B2/Zambia_chrX_w1000.B2 |less
#21029874-21683648
PATH=/share/apps/R-4.2.2/bin/:$PATH 
# manhattan plots with SA candidates and no quantile lines
for pop in Zambia USA France
do echo $pop
    for win in 1000 #5000 10000
    do echo $win
        for bstat in B2
        do echo $bstat
        cut -f3 ../results/ballermix/$bstat/${pop}_chr*_w${win}.${bstat} |grep -v LR|sort -rn > ../results/ballermix/sortedBs
        max=$(head -n1 ../results/ballermix/sortedBs)
            for chr in 2L 2R 3L 3R X
            do echo $chr
                Rscript plotballer.R -i ../results/ballermix/$bstat/${pop}_chr${chr}_w${win}.${bstat} -o ../results/ballermix/$bstat/${pop}_chr${chr}_w${win}_SAcand.${bstat} -c chr${chr} -m $max 
            done
        done
    done
done

# regions to plot
awk '$3>3966.407188814843' ../results/ballermix/B2/USA_chr2L_w1000.B2 |less
#21189690-21224995
awk -v n=$((n/2000)) 'NR==n' ../results/ballermix/B2/USA_allchr_w1000.sortedB2.txt > ../results/ballermix/B2/USA_w1000_B2q9995.txt
max=$(head -n1 ../results/ballermix/B2/USA_allchr_w1000.sortedB2.txt)
Rscript plotballer.R -i ../results/ballermix/B2/USA_chr2L_w1000.B2 -o ../results/ballermix/B2/USA_chr2L_w1000_z20000000-22000000.B2 -c chr2L -z 20000000-22000000 -m $max -q $(cat ../results/ballermix/B2/USA_w1000_B2q999.txt),$(cat ../results/ballermix/B2/USA_w1000_B2q9995.txt) -p  '99.9%,99.95%'

awk '$3>3966.407188814843' ../results/ballermix/B2/USA_chr2R_w1000.B2 |less
#20661531-20674263
awk '$3>3966.407188814843' ../results/ballermix/B2/USA_chr3L_w1000.B2 |less
#21310013-21573394
max=$(head -n1 ../results/ballermix/B2/USA_allchr_w1000.sortedB2.txt)
Rscript plotballer.R -i ../results/ballermix/B2/USA_chr3L_w1000.B2 -o ../results/ballermix/B2/USA_chr3L_w1000_z19000000-23000000.B2 -c chr2L -z 19000000-23000000 --noinv 1 -m $max -q $(cat ../results/ballermix/B2/USA_w1000_B2q999.txt),$(cat ../results/ballermix/B2/USA_w1000_B2q9995.txt) -p  '99.9%,99.95%'

awk '$3>3966.407188814843' ../results/ballermix/B2/USA_chr3R_w1000.B2 |less
#none

awk '$3>3966.407188814843' ../results/ballermix/B2/USA_chrX_w1000.B2 |less
#7050579-7194405
#10712214-10721189

# regions to plot in France
awk '$3>449.2460754754493' ../results/ballermix/B2/France_chr2L_w1000.B2 |less
#1770989-1777901
#4366214-4549090
#5395087-5424394
#6182256-6204505
#20106520-20117880
awk '$3>449.2460754754493' ../results/ballermix/B2/France_chr2R_w1000.B2 |less
#51614-94435
#1110480-1121643
awk '$3>449.2460754754493' ../results/ballermix/B2/France_chr3L_w1000.B2 |less
#none
awk '$3>449.2460754754493' ../results/ballermix/B2/France_chr3R_w1000.B2 |less
#none
awk '$3>449.2460754754493' ../results/ballermix/B2/France_chrX_w1000.B2 |less
#3686017-3734094
#9288103-9289311
#10384819-10387711
#14893815-14899060
#20904063-20904989
#21006117-22130279
