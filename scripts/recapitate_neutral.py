# Python script that performs the recapitation:

# source /share/apps/source_files/python/python-3.9.5.source

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
parser.add_argument("--mu", help = "mutation rate (for neutral mutations)")
parser.add_argument("--re", help = "recombination rate")

args = parser.parse_args(args=None if sys.argv[1:] else ['--help'])

#infile = "../slimout/neutral/output_r1_s31148_j0_c40000.trees"
#pref = "../vcf/neutral/output_r1_s31148_j0_c40000"
#infile = "../slimout/neutral/output_r1_s31148_j0_c4000.trees"
#pref = "../vcf/neutral/output_r1_s31148_j0_c4000"
#infile="/SAN/reuterlab/balsel_detection/bls_sim/slimout/neutral_N2k_r1e-8/output_r1_s927707063_j4305489_c16000.trees"
#pref = "../vcf/neutral_N2k_r1e-8/output_r1_s927707063_j4305489_c16000"
Ne=int(args.ne)
recrate=float(args.re)
mutrate=float(args.mu)
nspl=int(args.nspl)

infile = args.input

if args.outpref:
    pref = args.outpref
else:
    pref = infile+"_"

# Load the .trees file
ts = tsk.load(infile)
# Recapitate!
recap = pyslim.recapitate(ts, ancestral_Ne=Ne, recombination_rate=recrate) # MAX: updated based on slim scripts
#recap.dump("../data/"+pref+"_recap.trees")
recsim = recap.simplify()
# inserted sanity check:
# orig_max_roots = max(t.num_roots for t in ts.trees())
# recap_max_roots = max(t.num_roots for t in recap.trees())
# print(f"Maximum number of roots before recapitation: {orig_max_roots}\n"
#       f"After recapitation: {recap_max_roots}")
mutated = msprime.sim_mutations(recsim, rate=mutrate) 

# print(f"The tree sequence now has {mutated.num_mutations} mutations,\n"
#       f"Before it had {recsim.num_mutations} mutations.\n"
#       f"The mean pairwise nucleotide diversity is now {mutated.diversity():0.3e}."
#       f"Before, it was {recsim.diversity():0.3e}."
#       )

if args.nspl:
    # subsample individuals
    indspl = random.sample([x.id for x in mutated.individuals()], k=nspl)
else:
    indspl = [x.id for x in mutated.individuals()]

#get pair of nodes corresponding to each individual
nodespl = [mutated.individual(x).nodes[0] for x in indspl]+[mutated.individual(x).nodes[1] for x in indspl]
mutsim_splind = mutated.simplify(samples=nodespl)

# choose central mutation
central_site_idx = np.argmin([abs(i-7499) for i in mutsim_splind.sites_position])
central_site = mutsim_splind.sites_position[central_site_idx]
if central_site-4999 < 0 or central_site+5000 > mutsim_splind.sequence_length:
    print ("ERROR: there is no suitable 10kb window. central_site = "+ str(central_site))
    exit(1)
else:
    mutsim_10kb = mutsim_splind.keep_intervals([(central_site-4999, central_site+5000)]).trim()

mutsim_10kb.dump(pref+".trees")

if args.vcf:
    # write to VCF file
    samplenames = ["ind_"+str(x) for x in indspl]
    with open(pref+".vcf" , "w") as vcf:
        mutsim_10kb.write_vcf(vcf, individual_names = samplenames)
