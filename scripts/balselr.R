# source /share/apps/source_files/R/R-4.3.2.source

#library(devtools)
#devtools::install_github("bitarellolab/balselr")
library(balselr)
library(R.utils)
library(data.table)
library(ggplot2)
source("my_ncd2.R")

args = commandArgs(trailingOnly=TRUE)
vcffname <- args[1]
if (length(args)>=2){
    tf <- as.numeric(args[2])
} else {
    tf <- 0.5
}
if (length(args)>=3){
    winsize <- as.numeric(args[3])
} else {
    winsize <- 3000
}

# ungzip the vcf file
gunzip(vcffname)
# extract name of ungzipped file
fnameunz <- gsub(".gz", "", vcffname)
# read in vcf as data table
vcf <- read_vcf( x = fnameunz) 
# add outgroup as 00 column
vcf <- cbind(vcf, out="0|0")
# generate ncd input format
ncd2in <- parse_vcf(vcf_data = vcf,
          n0 = 100,
          n1 = 1,
          type = "ncd2"
)
# run ncd2 per informative site
myncd2out <- myncd2(x=ncd2in, tf=tf,  w=winsize, ncores=2, minIS=2, by="IS")
# add columns for window start, end and mid position (central site)
myncd2out$Win.start <- sapply(strsplit(myncd2out$Win.ID, "_"), function (x){as.numeric(x[2])})
myncd2out$Win.end <- sapply(strsplit(myncd2out$Win.ID, "_"), function (x){as.numeric(x[3])})
myncd2out$Win.mid <- myncd2out$Win.start + (myncd2out$Win.end - myncd2out$Win.start)/2

fnamepref <- gsub(".vcf", "", basename(fnameunz))
print(myncd2out[myncd2out$Win.mid==4999, -"Win.ID"],
            row.names=FALSE)
