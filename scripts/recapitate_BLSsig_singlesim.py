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

#infile = "../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_r1_s85005425_j4117742_c80000.trees"
#pref = "../vcf/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_r1_s85005425_j4117742_c80000"
#infile = "../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_r1_s85005425_j4117742_c320000.trees"
#pref = "../vcf/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_r1_s85005425_j4117742_c320000"
#infile = "../slimout/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_r1_s85005425_j4117742_c640000.trees"
#pref = "../vcf/OD_N20k_r1e-6_grid0.01/output_s0.01-0.01_r1_s85005425_j4117742_c640000"
infile= "/home/debora/Dropbox/private/projects/uclpostdoc/bls_sim/singer_inferred/ts/output_s0.01-0.01_r1_s161300005_j3200395_c400000_spl100_0.trees"
Ne=1000
recrate=1e-9
mutrate=1e-7

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

# Load the .trees file
ts = tsk.load(infile)
# Recapitate!
recap = pyslim.recapitate(ts, ancestral_Ne=Ne, recombination_rate=recrate)
#recap.dump("../data/"+pref+"_recap.trees")
recsim = recap.simplify()
# inserted sanity check:
# orig_max_roots = max(t.num_roots for t in ts.trees())
# recap_max_roots = max(t.num_roots for t in recap.trees())
# print(f"Maximum number of roots before recapitation: {orig_max_roots}\n"
#       f"After recapitation: {recap_max_roots}")
# mutation rate map setting mutation rate at site under SA (0-based pos=4999) to zero, so that there is no overlap with neutral mutation
rates_exclmidsite = msprime.RateMap(position=[0, 4999, 5000, 10000], rate=[mutrate, 0, mutrate])
# Ne*u ~ 0.001 in humans, 0.01 in Dmel
# u=1e-7 -> Ne*u = {1e-4, 1e-3, 1e-2} with Ne = {1e3, 1e4, 1e5}
mutated = msprime.sim_mutations(recsim, rate=rates_exclmidsite) 

print(f"The tree sequence now has {mutated.num_mutations} mutations,\n"
      f"Before it had {recsim.num_mutations} mutations.\n"
      f"The mean pairwise nucleotide diversity is now {mutated.diversity():0.3e}."
      f"Before, it was {recsim.diversity():0.3e}."
      )
      
mutsim = mutated.simplify()
breakpoints = [i for i in mutsim.breakpoints()]
treespans = [x-breakpoints[i] for i,x in enumerate(breakpoints[1:])]
th=tree_heights(mutsim)

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

# plot mutation ages along sequence

#-----------------------------------------------------

# WRITE VCF
if args.nspl:
    # subsample individuals
    indspl = random.sample([x.id for x in mutsim.individuals()], k=int(args.nspl))
else:
    indspl = [x.id for x in mutsim.individuals()]
if args.vcf:
    # write to VCF file
    samplenames = ["ind_"+str(x) for x in indspl]
    with open(pref+".vcf" , "w") as vcf:
        mutsim.write_vcf(vcf, individuals=indspl, individual_names = samplenames)

# some checks/visualizations:
#nodespl = list(np.concatenate([mutsim.individual(x).nodes for x in indspl]))
#sfs=mutsim.allele_frequency_spectrum(sample_sets=[nodespl], polarised=True, span_normalise=False)
#np.savetxt(pref+"_SFS.csv", sfs, delimiter=",")
#
#plt.bar(np.arange(mutsim.num_samples + 1), sfs)
#plt.title("Polarised allele frequency spectrum")
#plt.show()
#
#print(tree_heights(mutsim))
