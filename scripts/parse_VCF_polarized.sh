#shell script to parse VCFs outputs by slim3.3+
#from https://github.com/bioXiaoheng/BalLeRMix/blob/master/Simulation_scripts/parseSlim3VCF.sh

cd $( pwd )

#Path and name of input and output files
infile=$1
outfile=$2

# REPLACING WITH POLARIZED DATA FROM SIMULATIONS (USING 0 AS ANCESTRAL)
##Index No. of the individual to use as ``ancestral'' sequence
##outseq=$3

nseq=$3

# Read & parse the vcf
zcat $infile | awk -v nseq=$nseq -v balmixder=$outfile.balmixder 'BEGIN{
	OFS="\t"; 
	print "physPos\tgenPos\tx\tn" > balmixder ;
        prevpos=9999999999
}{ 
	if(NF > 9 && $9 =="GT"){  
                anc = "0"
		drv=0 ; total=0;
		for(x=10;x<=nseq+9;x++){ # there are 9 site info columns in the vcf
			split($x,h,"|")
			if(h[1] != anc) drv++ ;
			if(h[2] != anc) drv++ ;
			total = total + 2
		}
                if(drv>0){
                   if($2<prevpos) {prevpos=$2}
                   print $2, 1e-6*$2, drv, total > balmixder
                   prevpos=$2
                }
	}		
}'
