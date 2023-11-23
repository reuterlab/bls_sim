# NOTE: on CS cluster, run with python 3:
# module load python/3.8.5
# python3 parse_simout.py

import glob
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
import sys

parser = argparse.ArgumentParser(description="plot grids")
parser.add_argument("-o", "--outdir", help="directory with slim output")
args = parser.parse_args(args=None if sys.argv[1:] else ['--help'])

outdir = args.outdir
files=glob.glob(outdir+"/*.txt")

tgrid4k_h50 = np.zeros((10,10))
tgrid40k_h50 = np.zeros((10,10))
tgrid400k_h50 = np.zeros((10,10))
tgrid4k_h25 = np.zeros((10,10))
tgrid40k_h25 = np.zeros((10,10))
tgrid400k_h25 = np.zeros((10,10))
tot_h50 = np.zeros((10,10))
tot_h25 = np.zeros((10,10))
for file in files:
    with open(file) as f:
        next(f) # skip header line
        line = f.readline().strip().split(',')
        if line[0]: # if file has more than header
            # columns: s1,s2,h,bls_start,4000,40000,400000,lost,fixed,maxfreq,invading_allele
            t1 = int((round(float(line[0])-0.1, 2)) * 10)
            t2 = int((round(float(line[1])-0.1, 2)) * 10)
            h = float(line[2])
            f4k = float(line[4])
            f40k = float(line[5])
            f400k = float(line[6])
            tlost = line[7]
            tfixed = line[8]
            maxfreq = line[9]
            if h==0.5:
                tgrid4k_h50[t1,t2] += f4k>0
                tgrid40k_h50[t1,t2] += f40k>0
                tgrid400k_h50[t1,t2] += f400k>0
                tot_h50[t1,t2]+=1
            if h==0.25:
                tgrid4k_h25[t1,t2] += f4k>0
                tgrid40k_h25[t1,t2] += f40k>0
                tgrid400k_h25[t1,t2] += f400k>0
                tot_h25[t1,t2]+=1

plt.figure()
ax = sns.heatmap(tot_h25, linewidth=0.5,
        cbar_kws={'label': 'Number of simulations processed'},
                 xticklabels=[float(i/10) for i in range(10)],
                 yticklabels=[float(i/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
#plt.show()
plt.savefig(outdir+"/h25_nsim.png")

plt.figure()
ax = sns.heatmap(tot_h50, linewidth=0.5,
        cbar_kws={'label': 'Number of simulations processed'},
                 xticklabels=[float(i/10) for i in range(10)],
                 yticklabels=[float(i/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
#plt.show()
plt.savefig(outdir+"/h50_nsim.png")

# for h=0.25
plt.figure()
ax = sns.heatmap(tgrid4k_h25, linewidth=0.5,
        cbar_kws={'label': 'Simulations with polymorphism'},
                 xticklabels=[float(i/10) for i in range(10)],
                 yticklabels=[float(i/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('4000 generations')
#plt.show()
plt.savefig(outdir+"/h25_t4kgrid.png")

plt.figure()
ax = sns.heatmap(tgrid40k_h25, linewidth=0.5,
        cbar_kws={'label': 'Simulations with polymorphism'},
                 xticklabels=[float(i/10) for i in range(10)],
                 yticklabels=[float(i/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('40000 generations')
#plt.show()
plt.savefig(outdir+"/h25_t40kgrid.png")

plt.figure()
ax = sns.heatmap(tgrid400k_h25, linewidth=0.5,
        cbar_kws={'label': 'Simulations with polymorphism'},
                 xticklabels=[float(i/10) for i in range(10)],
                 yticklabels=[float(i/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('400000 generations')
#plt.show()
plt.savefig(outdir+"/h25_t400kgrid.png")

#for h=0.5
plt.figure()
ax = sns.heatmap(tgrid4k_h50, linewidth=0.5,
        cbar_kws={'label': 'Simulations with polymorphism'},
                 xticklabels=[float(i/10) for i in range(10)],
                 yticklabels=[float(i/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('4000 generations')
#plt.show()
plt.savefig(outdir+"/h50_t4kgrid.png")

plt.figure()
ax = sns.heatmap(tgrid40k_h50, linewidth=0.5,
        cbar_kws={'label': 'Simulations with polymorphism'},
                 xticklabels=[float(i/10) for i in range(10)],
                 yticklabels=[float(i/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('40000 generations')
#plt.show()
plt.savefig(outdir+"/h50_t40kgrid.png")

plt.figure()
ax = sns.heatmap(tgrid400k_h50, linewidth=0.5,
        cbar_kws={'label': 'Simulations with polymorphism'},
                 xticklabels=[float(i/10) for i in range(10)],
                 yticklabels=[float(i/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('400000 generations')
#plt.show()
plt.savefig(outdir+"/h50_t400kgrid.png")
