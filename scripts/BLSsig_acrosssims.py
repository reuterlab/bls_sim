# Python script that looks for BLS signatures accross replicates of simulated tree sequences

# source /share/apps/source_files/python/python-3.9.5.source

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

### FOR TESTING
#inpref="../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_r"+str(rep)+"_*_c640000.trees"
#inpref="../singer_inferred/OD_N20k_r1e-6_grid0.01/ts/output_s0.01-0.01_r"+str(rep)+"_*_c640000*.trees"

### FOR TESTING
#inoutpath="../slimout/OD_N20k_r1e-7_grid0.01/"
#simulated=True
#inoutpath="../singer_inferred/OD_N20k_r1e-7_grid0.01/ts/"
#simulated=False
###
inoutpath="../slimout/OD_N20k_r1e-6_grid0.01/"
simulated=True
inoutpath="../singer_inferred/OD_N20k_r1e-6_grid0.01/ts/"
simulated=False
###
Ne=20000
#recrate=1e-7
recrate=1e-6
mutrate=1e-7
###
# allele frequency list
AFs=[]
# allele ages list
ages=[]
# total tree heights list
THs=[]
PIs=[]
PIssite=[]
TajDs=[]
TajDssite=[]
# multiallelic/recurrent mutation sites per simulation replicate
multiallelic=[]
recmut=[]
nreps=0
for rep in range(100):
    inpref=inoutpath+"output_s0.01-0.01_r"+str(rep)+"_*_c640000*.trees"
    multiallelic.append(0)
    recmut.append(0)
    rep=rep+1
    infile=glob.glob(inpref)
    if not infile: # mutation did not segregate till this generation so the trees file was not generated for this replicate
        print("mutation did not segregate till this generation so the trees file was not generated for replicate "+str(rep))
        continue
    elif len(infile)>1:
        print ("Check if there's something wrong here: There is more than one file for rep "+str(rep))
        break
    else:
        infile=infile[0]
        nreps+=1
    # Load the .trees file
    ts = tsk.load(infile)
    if simulated:
        # Recapitate!
        recap = pyslim.recapitate(ts, ancestral_Ne=Ne, recombination_rate=recrate)
        recsim = recap.simplify()
        # mutation rate map setting mutation rate at site under SA (0-based pos=4999) to zero, so that there is no overlap with neutral mutation
        rates_exclmidsite = msprime.RateMap(position=[0, 4999, 5000, 10000], rate=[mutrate, 0, mutrate])
        mutated = msprime.sim_mutations(recsim, rate=rates_exclmidsite) 
        mutsim = mutated.simplify()
    else:
        mutsim = ts.simplify()
    breakpoints = [i for i in mutsim.breakpoints()]
    treespans = [x-breakpoints[i] for i,x in enumerate(breakpoints[1:])]
    midpoints = [x+((x-breakpoints[i])/2) for i,x in enumerate(breakpoints[1:])]
    dist_to_BLS=[abs(x-4999) for x in midpoints]
    # statistics from true trees
    th=tree_heights(mutsim)
    THs.extend(list(zip(dist_to_BLS,th)))
    pi=mutsim.diversity(windows=breakpoints, mode="branch") # branch-based diversity is in units of time
    PIs.extend(list(zip(dist_to_BLS,pi*mutrate))) #multiply by mutation rate to get equivalence to usual pi
    pisite=mutsim.diversity(windows=breakpoints, mode="site") # branch-based diversity is in units of time
    PIssite.extend(list(zip(dist_to_BLS,pisite)))
    tajD = mutsim.Tajimas_D(windows=breakpoints, mode="branch")
    TajDs.extend(list(zip(dist_to_BLS, tajD)))
    tajDsite = mutsim.Tajimas_D(windows=breakpoints, mode="site")
    TajDssite.extend(list(zip(dist_to_BLS, tajDsite)))
    # statistics based on variants:
    for snp in mutsim.variants():
        dist_to_BLS=abs(snp.site.position-4999) 
        if (snp.num_alleles>2): #for now, skip >biallelic sites
            multiallelic[rep-1]+=1
#        elif (len(snp.site.mutations)>1):
#            recmut[rep-1]+=1 #should be the same as multiallelic BUT ITS NOT -> this is due to recurrent mutations to the same allele, or back mutation. More than 1 mutation per site, but only 2 alleles
        else:
            AF=np.mean(snp.genotypes) # genotypes are 0 or 1, so the mean is the frequency of the derived allele
            if simulated:
                age=max([mut.time for mut in snp.site.mutations]) # if there is more than one mutation in this site, take the oldest one
            else:# age for singer mutations has to be average between ages of nodes of mutation branch
                mutbranches=[x.edge for x in snp.site.mutations]
                maxages=[mutsim.node(mutsim.edge(x).parent).time for x in mutbranches]
                minages=[mutsim.node(mutsim.edge(x).child).time for x in mutbranches]
                age=max([np.mean(x) for x in zip(minages,maxages)])# if there is more than one mutation in this site, take the oldest one
            if(dist_to_BLS>0): #exclude BLS site
                AFs.append((dist_to_BLS, AF, rep))
                ages.append((dist_to_BLS, age, rep))
#    if mutsim.num_sites != len([v for v in mutsim.variants()]) : # these numbers are always the same!
#        print("number of variants: "+str(len([v for v in mutsim.variants()])))
#        print("number of sites: "+str(mutsim.num_sites))
#    print("proportion of multiallelics: "+ str(multiallelic[rep-1]/mutsim.num_sites)) # around 2.5% multiallelics

# some checks/visualizations:

# datashader for plotting density of points in scatter plot grid
# based on https://stackoverflow.com/questions/20105364/how-can-i-make-a-scatter-plot-colored-by-density
import datashader as ds
from datashader.mpl_ext import dsshow

# plot all points (5kb around BLS site)
toplot = pd.DataFrame(ages, columns=["Distance","Age","Rep"])
fig,ax=plt.subplots()
dsartist = dsshow( toplot, ds.Point("Distance", "Age"),
        ds.count(), plot_width=50, plot_height=50, aspect="auto", ax=ax) 
plt.colorbar(dsartist)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Allele age")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate)+" Simulated="+str(simulated))
plt.savefig(inoutpath+"output_s0.01-0.01_c640000_agedensity.png")
plt.close()

toplot = pd.DataFrame(AFs, columns=["Distance","Allele frequency","Rep"])
fig,ax=plt.subplots()
dsartist = dsshow( toplot, ds.Point("Distance", "Allele frequency"),
        ds.count(), plot_width=50, plot_height=50, aspect="auto", ax=ax) 
plt.colorbar(dsartist)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Allele frequency")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate)+" Simulated="+str(simulated))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_afdensity.png')
plt.close()

MAFs = [1-x[1] if x[1]>0.5 else x[1] for x in AFs ]
plt.scatter([x[0] for x in AFs], [MAFs[i] for i,x in enumerate(AFs)],
        alpha=0.1)
toplot = pd.DataFrame({'Distance':[x[0] for x in AFs], 'Minor allele frequency':[MAFs[i] for i,x in enumerate(AFs)]})
fig,ax=plt.subplots()
dsartist = dsshow( toplot, ds.Point("Distance", "Minor allele frequency"),
        ds.count(), plot_width=50, plot_height=50, aspect="auto", ax=ax) 
plt.colorbar(dsartist)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Minor allele frequency")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate)+" Simulated="+str(simulated))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_mafdensity.png')
plt.close()
#plt.show()

toplot = pd.DataFrame(THs, columns=["Distance","Tree height"])
fig,ax=plt.subplots()
dsartist = dsshow( toplot, ds.Point("Distance", "Tree height"),
        ds.count(), plot_width=50, plot_height=50, aspect="auto", ax=ax) 
plt.colorbar(dsartist)
plt.xlabel("Basepairs from BLS site (midpoint of tree span)")
plt.ylabel("Total tree height")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate)+" Simulated="+str(simulated))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_thdensity.png')
plt.close()
#plt.show()

toplot = pd.DataFrame(PIssite, columns=["Distance","Site-based diversity"])
fig,ax=plt.subplots()
dsartist = dsshow( toplot, ds.Point("Distance", "Site-based diversity"),
        ds.count(), plot_width=50, plot_height=50, aspect="auto", ax=ax) 
plt.colorbar(dsartist)
plt.xlabel("Basepairs from BLS site (midpoint of tree span)")
plt.ylabel("Site-based diversity")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate)+" Simulated="+str(simulated))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_pisitedensity.png')
plt.close()
#plt.show()

toplot = pd.DataFrame(PIs, columns=["Distance","Branch-based diversity"])
fig,ax=plt.subplots()
dsartist = dsshow( toplot, ds.Point("Distance", "Branch-based diversity"),
        ds.count(), plot_width=50, plot_height=50, aspect="auto", ax=ax) 
plt.colorbar(dsartist)
plt.xlabel("Basepairs from BLS site (midpoint of tree span)")
plt.ylabel("Branch length-based diversity")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate)+" Simulated="+str(simulated))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_pibranchdensity.png')
plt.close()
#plt.show()

plt.scatter([x[0] for x in TajDssite], [x[1] for x in TajDssite],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site (midpoint of tree span)")
plt.ylabel("Site-based Tajima's D")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate)+" Simulated="+str(simulated))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_TajDsite.png')
plt.close()
#plt.show()

plt.scatter([x[0] for x in TajDs], [x[1] for x in TajDs],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site (midpoint of tree span)")
plt.ylabel("Branch length-based Tajima's D")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate)+" Simulated="+str(simulated))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_TajDbranch.png')
plt.close()
#plt.show()

### plot only dist bp around BLS site
dist=100
plt.scatter([x[0] for x in ages if x[0]<=dist], [x[1] for x in ages if x[0]<=dist],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Allele age")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_age_'+str(dist)+'bp.png')
plt.close()
#plt.show()

MAFs = [1-x[1] if x[1]>0.5 else x[1] for x in AFs ]
plt.scatter([x[0] for x in AFs if x[0]<=dist], [MAFs[i] for i,x in enumerate(AFs) if x[0]<=dist],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Minor Allele Frequency")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_MAF_'+str(dist)+'bp.png')
plt.close()
#plt.show()

plt.scatter([x[0] for x in AFs if x[0]<=dist], [x[1] for x in AFs if x[0]<=dist],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site")
plt.ylabel("Allele Frequency")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_AF_'+str(dist)+'bp.png')
plt.close()
#plt.show()

plt.scatter([x[0] for x in THs if x[0]<=dist], [x[1] for x in THs if x[0]<=dist],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site (midpoint of tree span)")
plt.ylabel("Total tree height")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_TH_'+str(dist)+'bp.png')
plt.close()
#plt.show()
