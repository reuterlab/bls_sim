# Python script that performs the recapitation:

# Edited by Max, starting November 24
# - simplify to adapt to simulations with a single population and without scaling
# - add Ne variable provided as argument

# source /share/apps/source_files/python/python-3.9.5.source
# python3 recapitate.py -i [tsfile] -o [output path and prefix] --vcf --nspl 200 --ne $Ne
# python3 recapitate.py -i /SAN/reuterlab/balsel_detection/bls_sim/slimout_test/OD_N1e3_grid0.01/output_s0.3-0.3_r1_s373688260_j3200352_c4000.trees -o /SAN/reuterlab/balsel_detection/bls_sim/slimout_test/OD_N1e3_grid0.01/output_s0.3-0.3_r1_s373688260_j3200352_c4000_test  --vcf --nspl 200 --ne 1000

import tskit as tsk # installed via python3 -m pip install tskit 
import msprime #installed via python3 -m pip install msprime
import pyslim #installed via python3 -m pip install pyslim
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import argparse
import random
import sys
import glob

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", help="input file name: tree sequence file")
parser.add_argument("-o", "--outpref", help="prefix for output file name")
parser.add_argument("--vcf", action="store_true", help="output VCF file")
parser.add_argument("--nspl", help = "number of samples to output to VCF")
# added to accommodate variable Ne
parser.add_argument("--ne", help = "effective population size")
parser.add_argument("--mu", help = "mutation rate (for neutral mutations)")
parser.add_argument("--re", help = "recombination rate")

args = parser.parse_args(args=None if sys.argv[1:] else ['--help'])

Ne=int(args.ne)
recrate=float(args.re)
mutrate=float(args.mu)

infile = args.input

if args.outpref:
    pref = args.outpref
else:
    pref = infile+"_"

# Define function to calculate tree heights, giving uncoalesced sites the maximum time
def tree_heights(ts):
    heights = np.zeros(ts.num_trees)
    for tree in ts.trees():
        children = tree.children(tree.root)
        real_root = tree.root if len(children) > 1 else children[0]
        heights[tree.index] = tree.time(real_root)
    return heights

# allele frequency list
AFs=[]
# allele ages list
ages=[]
# total tree heights list
THs=[]

multiallelic=[]
recmut=[]
### FOR TESTING
for rep in range(100):
    multiallelic.append(0)
    recmut.append(0)
    rep=rep+1
    #inpref="../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_r"+str(rep)+"_*_c640000.trees"
    inpref="../slimout/OD_N20k_r1e-7_grid0.01/output_s0.01-0.01_r"+str(rep)+"_*_c640000.trees"
    infile=glob.glob(inpref)
    if not infile: # mutation did not segregate till this generation so the trees file was not generated for this replicate
        continue
    elif len(infile)>1:
        print ("Check if there's something wrong here: There is more than one file for rep "+str(rep))
        break
    else:
        infile=infile[0]
#        print(infile)
    Ne=20000
    #recrate=1e-6
    recrate=1e-7
    mutrate=1e-7
    # Load the .trees file
    ts = tsk.load(infile)
    # Recapitate!
    recap = pyslim.recapitate(ts, ancestral_Ne=Ne, recombination_rate=recrate)
    #recap.dump("../data/"+pref+"_recap.trees")
    recsim = recap.simplify()
    # mutation rate map setting mutation rate at site under SA (0-based pos=4999) to zero, so that there is no overlap with neutral mutation
    rates_exclmidsite = msprime.RateMap(position=[0, 4999, 5000, 10000], rate=[mutrate, 0, mutrate])
    # Ne*u ~ 0.001 in humans, 0.01 in Dmel
    # u=1e-7 -> Ne*u = {1e-4, 1e-3, 1e-2} with Ne = {1e3, 1e4, 1e5}
    mutated = msprime.sim_mutations(recsim, rate=rates_exclmidsite) 
    mutsim = mutated.simplify()
    breakpoints = [i for i in mutsim.breakpoints()]
    treespans = [x-breakpoints[i] for i,x in enumerate(breakpoints[1:])]
    midpoints = [x+((x-breakpoints[i])/2) for i,x in enumerate(breakpoints[1:])]
    dist_to_BLS=[abs(x-4999) for x in midpoints]
    # statistics from true trees
    th=tree_heights(mutsim)
    THs.extend(list(zip(dist_to_BLS,th)))
    ### CONTINUE ADDING BRANCH-BASED PI AND TAJIMAS D HERE
##    pi=mutsim.diversity(windows=breakpoints, mode="branch")
##    PIs.extend(list(zip(dist_to_BLS,th)))
    # statistics based on variants:
    for snp in mutsim.variants():
        dist_to_BLS=abs(snp.site.position-4999) 
        if (snp.num_alleles>2): #for now, skip >biallelic sites
            multiallelic[rep-1]+=1
            #print(snp.frequencies())
            #print(snp.site)
#        elif (len(snp.site.mutations)>1):
#            recmut[rep-1]+=1 #should be the same as multiallelic BUT ITS NOT -> this is due to recurrent mutations to the same allele, or back mutation. More than 1 mutation per site, by only 2 alleles
#            print(snp.frequencies())
#            print(snp.num.alleles)
#            print(snp.site)
        else:
            AF=np.mean(snp.genotypes) # genotypes are 0 or 1, so the mean is the frequency of the derived allele
            age=max([mut.time for mut in snp.site.mutations]) # if there is more than one mutation in this site, take the oldest one
#            if(dist_to_BLS<=0):
#                print('excluded site '+str(snp.site))
            if(dist_to_BLS>0): #exclude BLS site
                AFs.append((dist_to_BLS, AF, rep))
                ages.append((dist_to_BLS, age, rep))
#    if mutsim.num_sites != len([v for v in mutsim.variants()]) : # these numbers are always the same!
#        print("number of variants: "+str(len([v for v in mutsim.variants()])))
#        print("number of sites: "+str(mutsim.num_sites))
#    print("number of multiallelics: "+ str(multiallelic[rep-1]))
#    print("proportion of multiallelics: "+ str(multiallelic[rep-1]/mutsim.num_sites)) # around 2.5% multiallelics


# some checks/visualizations:

# plot all points (5kb around BLS site)

# windows for plotting?
#L = 10000
#w = np.linspace(0, L, num=L//1_000)

plt.scatter([x[0] for x in ages], [x[1] for x in ages],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Allele age")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
#plt.savefig('../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_c640000_age.png')
plt.savefig('../slimout/OD_N20k_r1e-7_grid0.01/output_s0.01-0.01_c640000_age.png')
plt.close()
#plt.show()

plt.scatter([x[0] for x in AFs], [x[1] for x in AFs],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Allele frequency")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
#plt.savefig('../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_c640000_af.png')
plt.savefig('../slimout/OD_N20k_r1e-7_grid0.01/output_s0.01-0.01_c640000_af.png')
plt.close()
#plt.show()

MAFs = [1-x[1] if x[1]>0.5 else x[1] for x in AFs ]
plt.scatter([x[0] for x in AFs], [MAFs[i] for i,x in enumerate(AFs)],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Minor allele frequency")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
#plt.savefig('../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_c640000_maf.png')
plt.savefig('../slimout/OD_N20k_r1e-7_grid0.01/output_s0.01-0.01_c640000_maf.png')
plt.close()

plt.scatter([x[0] for x in THs], [x[1] for x in THs],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site (midpoint of tree span)")
plt.ylabel("Total tree height")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
#plt.savefig('../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_c640000_th.png')
plt.savefig('../slimout/OD_N20k_r1e-7_grid0.01/output_s0.01-0.01_c640000_th.png')
plt.close()
#plt.show()

# plot only dist bp around BLS site
dist=1000
plt.scatter([x[0] for x in ages if x[0]<=dist], [x[1] for x in ages if x[0]<=dist],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Allele age")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
#plt.savefig('../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_c640000_age_'+str(dist)+'bp.png')
plt.savefig('../slimout/OD_N20k_r1e-7_grid0.01/output_s0.01-0.01_c640000_age_'+str(dist)+'bp.png')
plt.close()
#plt.show()

MAFs = [1-x[1] if x[1]>0.5 else x[1] for x in AFs ]
plt.scatter([x[0] for x in AFs if x[0]<=dist], [MAFs[i] for i,x in enumerate(AFs) if x[0]<=dist],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Minor Allele Frequency")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
#plt.savefig('../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_c640000_MAF_'+str(dist)+'bp.png')
plt.savefig('../slimout/OD_N20k_r1e-7_grid0.01/output_s0.01-0.01_c640000_MAF_'+str(dist)+'bp.png')
plt.close()
#plt.show()

plt.scatter([x[0] for x in AFs if x[0]<=dist], [x[1] for x in AFs if x[0]<=dist],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Allele Frequency")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
#plt.savefig('../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_c640000_AF_'+str(dist)+'bp.png')
plt.savefig('../slimout/OD_N20k_r1e-7_grid0.01/output_s0.01-0.01_c640000_AF_'+str(dist)+'bp.png')
plt.close()
#plt.show()

plt.scatter([x[0] for x in THs if x[0]<=dist], [x[1] for x in THs if x[0]<=dist],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site (midpoint of tree span)")
plt.ylabel("Total tree height")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
#plt.savefig('../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_c640000_TH_'+str(dist)+'bp.png')
plt.savefig('../slimout/OD_N20k_r1e-7_grid0.01/output_s0.01-0.01_c640000_TH_'+str(dist)+'bp.png')
plt.close()
#plt.show()

#################

plt.hist(th)
plt.show()
np.mean(th)
len(th)

plt.hist(treespans)
plt.show()
max(treespans)
len(treespans)

beforei=max([i for i,x in enumerate(breakpoints) if x <4999])
afteri=min([i for i,x in enumerate(breakpoints) if x >4999])

#plot tree height along sequence
plt.stairs(th[(beforei-100):(beforei+101)], breakpoints[(beforei-100):(beforei+102)])
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
plt.show()
plt.savefig(infile+"_TMRCA.png")
plt.close()

#nodespl = list(np.concatenate([mutsim.individual(x).nodes for x in indspl]))
#sfs=mutsim.allele_frequency_spectrum(sample_sets=[nodespl], polarised=True, span_normalise=False)
#np.savetxt(pref+"_SFS.csv", sfs, delimiter=",")
#
#plt.bar(np.arange(mutsim.num_samples + 1), sfs)
#plt.title("Polarised allele frequency spectrum")
#plt.show()
#
#print(tree_heights(mutsim))
