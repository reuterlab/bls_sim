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


# Define function to calculate tree heights, giving uncoalesced sites the maximum time
def tree_heights(ts):
    heights = np.zeros(ts.num_trees)
    for tree in ts.trees():
        children = tree.children(tree.root)
        real_root = tree.root if len(children) > 1 else children[0]
        heights[tree.index] = tree.time(real_root)
    return heights

# total tree heights list
THs=[]

for rep in range(100):
    inpref="vcf/OD_N20k_r1e-8_grid0.01_m1e-8/output_s0.01-0.01_h0_r"+str(rep)+"_*_c160000_spl100.trees"
    infile=glob.glob(inpref)
    if not infile: # mutation did not segregate till this generation so the trees file was not generated for this replicate
        print("mutation did not segregate till this generation so the trees file was not generated for replicate "+str(rep))
        continue
    elif len(infile)>1:
        print ("Check if there's something wrong here: There is more than one file for rep "+str(rep))
        break
    else:
        infile=infile[0]
    # Load the .trees file
    ts = tsk.load(infile)
    mutsim = ts.simplify()
    breakpoints = [i for i in mutsim.breakpoints()]
    midpoints = [x+((x-breakpoints[i])/2) for i,x in enumerate(breakpoints[1:])]
    dist_to_BLS=[abs(x-4999) for x in midpoints]
    # statistics from true trees
    th=tree_heights(mutsim)
    THs.extend(list(zip(dist_to_BLS,th)))

# some checks/visualizations:

# datashader for plotting density of points in scatter plot grid
# based on https://stackoverflow.com/questions/20105364/how-can-i-make-a-scatter-plot-colored-by-density
import datashader as ds
from datashader.mpl_ext import dsshow

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

plt.scatter([x[0] for x in THs if x[0]<=dist], [x[1] for x in THs if x[0]<=dist],
        alpha=0.1)
plt.xlabel("Basepairs from BLS site (midpoint of tree span)")
plt.ylabel("Total tree height")
plt.title("Ne="+str(Ne)+" mu="+str(mutrate)+" r="+str(recrate))
plt.savefig(inoutpath+'/output_s0.01-0.01_c640000_TH_'+str(dist)+'bp.png')
plt.close()
#plt.show()
