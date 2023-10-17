#cd ~/Dropbox/private/projects/uclpostdoc/simulations/sexual_antagonism_natural_pops/scripts
#mamba activate msp # activate mamba environment with latest msprime install if needed
#./ts2recap2vcf.sh /home/debora/Dropbox/private/projects/uclpostdoc/simulations/SAsimulations/sexual_antagonism_natural_pops/out6616 blsold_lowrr
#./ts2recap2vcf.sh /home/debora/Dropbox/private/projects/uclpostdoc/simulations/sexual_antagonism_natural_pops/out9994277 blsmid
#./ts2recap2vcf.sh /home/debora/Dropbox/private/projects/uclpostdoc/simulations/sexual_antagonism_natural_pops/out9897319 neutral

DIR=$1
PREF=$2 #pref is neutral, bls, blsold, blsmid 

for tsfile in $(ls ${DIR}/*trees)
do
    if ! test -f "${DIR}/${PREF}_$(basename $tsfile .trees)_USA_fixpos_fixalleles.vcf"; then
        python recapitate.py -i $tsfile -o ${PREF}_$(basename $tsfile .trees) --vcf --nspl 200 >> ${DIR}/${PREF}_treeheights.txt
        for pop in USA Zambia France
        do
        vcfpref=${PREF}_$(basename $tsfile .trees)_$pop
        mv ../data/${vcfpref}.vcf $DIR
        bgzip -f ${DIR}/${vcfpref}.vcf
        # fix vcf position to be 1-based because vcf output from tskit uses original positions from slim (or tskit itself?) which are 0-based
        zgrep "^#" ${DIR}/${vcfpref}.vcf.gz > ${DIR}/${vcfpref}_fixpos.vcf 
        zgrep -v "^#" ${DIR}/${vcfpref}.vcf.gz | awk 'BEGIN {OFS="\t"}; $2 = $2+1' >> ${DIR}/${vcfpref}_fixpos.vcf
        #tskit vcf output is missing the REF and ALT alleles, and another column after that
        awk 'BEGIN {OFS="\t"}; $2==5000 {$4="A"; $5="C\t."}; {print}' ${DIR}/${vcfpref}_fixpos.vcf > ${DIR}/${vcfpref}_fixpos_fixalleles.vcf
        done
    fi
done
