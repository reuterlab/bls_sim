# Python script that performs the recapitation:

# Edited by Max, starting November 24
# - simplify to adapt to simulations with a single population and without scaling
# - add Ne variable provided as argument

# source /share/apps/source_files/python/python-3.9.5.source
# python3 recapitate.py -i [tsfile] -o [output path and prefix] --vcf --nspl 200 --ne $Ne
# python3 recapitate.py -i /SAN/reuterlab/balsel_detection/bls_sim/slimout_test/OD_N1e3_grid0.01/output_s0.3-0.3_r1_s373688260_j3200352_c4000.trees -o /SAN/reuterlab/balsel_detection/bls_sim/slimout_test/OD_N1e3_grid0.01/output_s0.3-0.3_r1_s373688260_j3200352_c4000_test  --vcf --nspl 200 --ne 1000

import tskit as tsk # installed via mamba 
import msprime #installed via pip bc mamba didnt work
import pyslim #installed via 'pip install pyslim'
import numpy as np
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

args = parser.parse_args(args=None if sys.argv[1:] else ['--help'])

#infile = "../slimout/neutral/output_r1_s31148_j0_c40000.trees"
#pref = "../vcf/neutral/output_r1_s31148_j0_c40000"
#infile = "../slimout/neutral/output_r1_s31148_j0_c4000.trees"
#pref = "../vcf/neutral/output_r1_s31148_j0_c4000"

infile = args.input

if args.outpref:
    pref = args.outpref
else:
    pref = infile+"_"

# Load the .trees file
ts = tsk.load(infile)

# Define function to calculate tree heights, giving uncoalesced sites the maximum time
def tree_heights(ts):
    heights = np.zeros(ts.num_trees)
    for tree in ts.trees():
        children = tree.children(tree.root)
        real_root = tree.root if len(children) > 1 else children[0]
        heights[tree.index] = tree.time(real_root)
    return sum(heights)/len(heights)

# Recapitate!
#recap = pyslim.recapitate(ts, ancestral_Ne=int(1000), recombination_rate=0.5e-8)
recap = pyslim.recapitate(ts, ancestral_Ne=int(args.ne), recombination_rate=0.5e-8) # MAX: updated based on slim scripts
#recap.dump("../data/"+pref+"_recap.trees")
recsim = recap.simplify()
# inserted sanity check:
# orig_max_roots = max(t.num_roots for t in ts.trees())
# recap_max_roots = max(t.num_roots for t in recap.trees())
# print(f"Maximum number of roots before recapitation: {orig_max_roots}\n"
#       f"After recapitation: {recap_max_roots}")

# Ne*u ~ 0.001 in humans, 0.01 in Dmel
# u=1e-7 with Ne = {1e3, 1e4, 1e5} -> Ne*u = {1e-4, 1e-3, 1e-2}
mutated = msprime.sim_mutations(recsim, rate=1e-7) 

print(f"The tree sequence now has {mutated.num_mutations} mutations,\n"
      f"Before it had {recsim.num_mutations} mutations.\n"
      f"The mean pairwise nucleotide diversity is now {mutated.diversity():0.3e}."
      f"Before, it was {recsim.diversity():0.3e}."
      )
      
mutsim_15kb = mutated.simplify()

# choose central mutation
central_site_idx = np.argmin([abs(i-7499) for i in mutsim_15kb.sites_position])
central_site = mutsim_15kb.sites_position[central_site_idx]
if central_site-4999 < 0 or central_site+5000 > mutsim_15kb.sequence_length:
    print ("ERROR: there is no suitable 10kb window")
    exit(1)
else:
    mutsim = mutsim_15kb.keep_intervals([(central_site-4999, central_site+5000)]).trim()

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
