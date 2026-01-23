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
import matplotlib.pyplot as plt
import argparse
import random
import sys
import warnings
warnings.simplefilter('ignore', msprime.TimeUnitsMismatchWarning)

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

#infile="../slimout/OD_N2k_r1e-8_grid0.1/output_s0.1-0.1_r1_s682405976_j4305864_c16000.trees"
#pref = "../vcf/OD_N2k_r1e-8_grid0.1/output_s0.1-0.1_r1_s682405976_j4305864_c16000"
#Ne=2000
#recrate=1e-8
#mutrate=1e-8
#nspl=100

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
recap = pyslim.recapitate(ts, ancestral_Ne=Ne, recombination_rate=recrate)
#recap.dump("../data/"+pref+"_recap.trees")
recsim = recap.simplify()
# replace ancestral state from selected site (which comes from slim as an empty string) to be zero
# see https://tskit.dev/pyslim/docs/latest/tutorial.html#writing-out-genotypes-to-vcf
nts=pyslim.generate_nucleotides(recsim)
nts=pyslim.convert_alleles(nts)
# inserted sanity check:
# orig_max_roots = max(t.num_roots for t in ts.trees())
# recap_max_roots = max(t.num_roots for t in recap.trees())
# print(f"Maximum number of roots before recapitation: {orig_max_roots}\n"
#       f"After recapitation: {recap_max_roots}")
# mutation rate map setting mutation rate at site under SA (0-based pos=4999) to zero, so that there is no overlap with neutral mutation
rates_exclmidsite = msprime.RateMap(position=[0, 4999, 5000, 10000], rate=[mutrate, 0, mutrate])
# Ne*u ~ 0.001 in humans, 0.01 in Dmel
# u=1e-7 -> Ne*u = {1e-4, 1e-3, 1e-2} with Ne = {1e3, 1e4, 1e5}
mutated = msprime.sim_mutations(nts, rate=rates_exclmidsite) 

print(f"The tree sequence now has {mutated.num_mutations} mutations,\n"
      f"Before it had {recsim.num_mutations} mutations.\n"
      f"The mean pairwise nucleotide diversity is now {mutated.diversity():0.3e}."
      f"Before, it was {recsim.diversity():0.3e}."
      )
      
mutsim = mutated.simplify()
if args.nspl:
    # subsample individuals
    indspl = random.sample([x.id for x in mutsim.individuals()], k=nspl)
else:
    indspl = [x.id for x in mutsim.individuals()]
#get pair of nodes corresponding to each individual
nodespl = [mutated.individual(x).nodes[0] for x in indspl]+[mutated.individual(x).nodes[1] for x in indspl]
mutsim_splind = mutated.simplify(samples=nodespl)

mutsim_splind.dump(pref+".trees")

if args.vcf:
    # write to VCF file
    samplenames = ["ind_"+str(x) for x in indspl]
    with open(pref+".vcf" , "w") as vcf:
        mutsim_splind.write_vcf(vcf, individual_names = samplenames)
