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
parser.add_argument("-i", "--indir", help="directory with slim output")
parser.add_argument("-o", "--outdir", help="directory with slim output")
args = parser.parse_args(args=None if sys.argv[1:] else ['--help'])

indir = args.indir
outdir = args.outdir

files=glob.glob(indir+"*.txt")

tot_h50 = np.zeros((10,10))
nlost_h50 = np.zeros((10,10))
proplost_h50 = np.zeros((10,10))
meantlost_h50 = np.zeros((10,10))
nfix_h50 = np.zeros((10,10))
propfix_h50 = np.zeros((10,10))
meantfix_h50 = np.zeros((10,10))
tgrid4k_h50 = np.zeros((10,10))
tgrid40k_h50 = np.zeros((10,10))
tgrid400k_h50 = np.zeros((10,10))
tgridprop4k_h50 = np.zeros((10,10))
tgridprop40k_h50 = np.zeros((10,10))
tgridprop400k_h50 = np.zeros((10,10))
meanmaxfreq_h50 = np.zeros((10,10))

tot_h25 = np.zeros((10,10))
nlost_h25 = np.zeros((10,10))
proplost_h25 = np.zeros((10,10))
meantlost_h25 = np.zeros((10,10))
nfix_h25 = np.zeros((10,10))
propfix_h25 = np.zeros((10,10))
meantfix_h25 = np.zeros((10,10))
tgrid4k_h25 = np.zeros((10,10))
tgrid40k_h25 = np.zeros((10,10))
tgrid400k_h25 = np.zeros((10,10))
tgridprop4k_h25 = np.zeros((10,10))
tgridprop40k_h25 = np.zeros((10,10))
tgridprop400k_h25 = np.zeros((10,10))
meanmaxfreq_h25 = np.zeros((10,10))

OD_flag = False

for file in files:
    with open(file) as f:
        next(f) # skip header line
        line = f.readline().strip().split(',')
        if line[0]: # if file has more than header
            # columns: s1,s2,h,bls_start,4000,40000,400000,lost,fixed,maxfreq,invading_allele
            t1 = int((round(float(line[0])-0.1, 2)) * 10)
            t2 = int((round(float(line[1])-0.1, 2)) * 10)
            h = line[2]
            f4k = float(line[4])
            f40k = float(line[5])
            f400k = float(line[6])
            tlost = line[7]
            tfixed = line[8]
            maxfreq = float(line[9])
            
            if h=="NA": #for overdominance
                OD_flag = True
                tgrid4k_h50[t1,t2]   += f4k>0   and f4k <1
                tgrid40k_h50[t1,t2]  += f40k>0  and f40k <1
                tgrid400k_h50[t1,t2] += f400k>0 and f400k <1
                tot_h50[t1,t2] += 1
                meanmaxfreq_h50[t1,t2] += maxfreq
                if tlost != "NA":
                    nlost_h50[t1,t2] += 1
                    meantlost_h50[t1,t2] += float(tlost)
                if tfixed != "NA":
                    nfix_h50[t1,t2] += 1
                    meantfix_h50[t1,t2] += float(tfixed)
            if h=="0.5" :
                h = float(h)
                tgrid4k_h50[t1,t2]   += f4k>0   and f4k <1
                tgrid40k_h50[t1,t2]  += f40k>0  and f40k <1
                tgrid400k_h50[t1,t2] += f400k>0 and f400k <1
                tot_h50[t1,t2] += 1
                meanmaxfreq_h50[t1,t2] += maxfreq
                if tlost != "NA":
                    nlost_h50[t1,t2] += 1
                    meantlost_h50[t1,t2] += float(tlost)
                if tfixed != "NA":
                    nfix_h50[t1,t2] += 1
                    meantfix_h50[t1,t2] += float(tfixed)
            if h=="0.25":
                h = float(h)
                tgrid4k_h25[t1,t2]   += f4k>0   and f4k <1
                tgrid40k_h25[t1,t2]  += f40k>0  and f40k <1
                tgrid400k_h25[t1,t2] += f400k>0 and f400k <1
                tot_h25[t1,t2]+=1
                meanmaxfreq_h25[t1,t2] += maxfreq
                if tlost != "NA":
                    nlost_h25[t1,t2] += 1
                    meantlost_h25[t1,t2] += float(tlost)
                if tfixed != "NA":
                    nfix_h25[t1,t2] += 1
                    meantfix_h25[t1,t2] += float(tfixed)

#=======================
# for h=0.5

### Create composite metrics 

proplost_h50 = nlost_h50/tot_h50
meantlost_h50 = meantlost_h50/nlost_h50
propfix_h50 = nfix_h50/tot_h50
meantfix_h50 = meantfix_h50/nfix_h50
tgridprop4k_h50 = tgrid4k_h50/tot_h50
tgridprop40k_h50 = tgrid40k_h50/tot_h50
tgridprop400k_h50 = tgrid400k_h50/tot_h50
meanmaxfreq_h50 = meanmaxfreq_h50/tot_h50


### Create plots 

# Number of simulations

plt.figure()
ax = sns.heatmap(tot_h50, linewidth=0.5,
        cbar_kws={'label': 'Number of simulations processed'},
                 xticklabels=[float((i+1)/10) for i in range(10)],
                 yticklabels=[float((i+1)/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
#plt.show()
plt.savefig(outdir+"h50_nsim.png")

# Losses

plt.figure()
ax = sns.heatmap(proplost_h50, linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with lost mutation'},
                 xticklabels=[float((i+1)/10) for i in range(10)],
                 yticklabels=[float((i+1)/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('Proportion of losses')
#plt.show()
plt.savefig(outdir+"h50_proplost.png")

plt.figure()
ax = sns.heatmap(meantlost_h50, linewidth=0.5,
        cbar_kws={'label': 'Mean time to loss of invading mutation'},
                 xticklabels=[float((i+1)/10) for i in range(10)],
                 yticklabels=[float((i+1)/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('Mean time to loss')
#plt.show()
plt.savefig(outdir+"h50_meantlost.png")

# Fixations

plt.figure()
ax = sns.heatmap(propfix_h50, linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with fixed mutation'},
                 xticklabels=[float((i+1)/10) for i in range(10)],
                 yticklabels=[float((i+1)/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('Proportion of fixations')
#plt.show()
plt.savefig(outdir+"h50_propfix.png")

plt.figure()
ax = sns.heatmap(meantfix_h50, linewidth=0.5,
        cbar_kws={'label': 'Mean time to fixation of invading mutation'},
                 xticklabels=[float((i+1)/10) for i in range(10)],
                 yticklabels=[float((i+1)/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('Mean time to fixation')
#plt.show()
plt.savefig(outdir+"h50_meantfix.png")

# Polymporphism

plt.figure()
ax = sns.heatmap(tgridprop4k_h50, linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 xticklabels=[float((i+1)/10) for i in range(10)],
                 yticklabels=[float((i+1)/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('4000 generations')
#plt.show()
plt.savefig(outdir+"h50_t4kproppoly.png")

plt.figure()
ax = sns.heatmap(tgridprop40k_h50, linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 xticklabels=[float((i+1)/10) for i in range(10)],
                 yticklabels=[float((i+1)/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('40000 generations')
#plt.show()
plt.savefig(outdir+"h50_t40kproppoly.png")

plt.figure()
ax = sns.heatmap(tgridprop400k_h50, linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 xticklabels=[float((i+1)/10) for i in range(10)],
                 yticklabels=[float((i+1)/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('400000 generations')
#plt.show()
plt.savefig(outdir+"h50_t400kproppoly.png")

plt.figure()
ax = sns.heatmap(meanmaxfreq_h50, linewidth=0.5,
        cbar_kws={'label': 'Mean max frequency reached by invading mutation'},
                 xticklabels=[float((i+1)/10) for i in range(10)],
                 yticklabels=[float((i+1)/10) for i in range(10)])
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('Mean max freq')
#plt.show()
plt.savefig(outdir+"h50_meanmaxfreq.png")



#=======================
# for h=0.25

if not OD_flag:
    
    ### Create composite metrics 
    
    proplost_h25 = nlost_h25/tot_h25
    meantlost_h25 = meantlost_h25/nlost_h25
    propfix_h25 = nfix_h25/tot_h25
    meantfix_h25 = meantfix_h25/nfix_h25
    tgridprop4k_h25 = tgrid4k_h25/tot_h25
    tgridprop40k_h25 = tgrid40k_h25/tot_h25
    tgridprop400k_h25 = tgrid400k_h25/tot_h25
    meanmaxfreq_h25 = meanmaxfreq_h25/tot_h25
    
    
    ### Create plots 
    
    # Number of simulations
    
    plt.figure()
    ax = sns.heatmap(tot_h25, linewidth=0.5,
            cbar_kws={'label': 'Number of simulations processed'},
                     xticklabels=[float((i+1)/10) for i in range(10)],
                     yticklabels=[float((i+1)/10) for i in range(10)])
    ax.invert_yaxis()
    ax.set(xlabel='t2', ylabel='t1')
    #plt.show()
    plt.savefig(outdir+"h25_nsim.png")
    
    # Losses
    
    plt.figure()
    ax = sns.heatmap(proplost_h25, linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with lost mutation'},
                     xticklabels=[float((i+1)/10) for i in range(10)],
                     yticklabels=[float((i+1)/10) for i in range(10)])
    ax.invert_yaxis()
    ax.set(xlabel='t2', ylabel='t1')
    ax.set_title('Proportion of losses')
    #plt.show()
    plt.savefig(outdir+"h25_proplost.png")
    
    plt.figure()
    ax = sns.heatmap(meantlost_h25, linewidth=0.5,
            cbar_kws={'label': 'Mean time to loss of invading mutation'},
                     xticklabels=[float((i+1)/10) for i in range(10)],
                     yticklabels=[float((i+1)/10) for i in range(10)])
    ax.invert_yaxis()
    ax.set(xlabel='t2', ylabel='t1')
    ax.set_title('Mean time to loss')
    #plt.show()
    plt.savefig(outdir+"h25_meantlost.png")
    
    # Fixations
    
    plt.figure()
    ax = sns.heatmap(propfix_h25, linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with fixed mutation'},
                     xticklabels=[float((i+1)/10) for i in range(10)],
                     yticklabels=[float((i+1)/10) for i in range(10)])
    ax.invert_yaxis()
    ax.set(xlabel='t2', ylabel='t1')
    ax.set_title('Proportion of fixations')
    #plt.show()
    plt.savefig(outdir+"h25_propfix.png")
    
    plt.figure()
    ax = sns.heatmap(meantfix_h25, linewidth=0.5,
            cbar_kws={'label': 'Mean time to fixation of invading mutation'},
                     xticklabels=[float((i+1)/10) for i in range(10)],
                     yticklabels=[float((i+1)/10) for i in range(10)])
    ax.invert_yaxis()
    ax.set(xlabel='t2', ylabel='t1')
    ax.set_title('Mean time to fixation')
    #plt.show()
    plt.savefig(outdir+"h25_meantfix.png")
    
    # Polymporphism
    
    plt.figure()
    ax = sns.heatmap(tgridprop4k_h25, linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                     xticklabels=[float((i+1)/10) for i in range(10)],
                     yticklabels=[float((i+1)/10) for i in range(10)])
    ax.invert_yaxis()
    ax.set(xlabel='t2', ylabel='t1')
    ax.set_title('4000 generations')
    #plt.show()
    plt.savefig(outdir+"h25_t4kproppoly.png")
    
    plt.figure()
    ax = sns.heatmap(tgridprop40k_h25, linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                     xticklabels=[float((i+1)/10) for i in range(10)],
                     yticklabels=[float((i+1)/10) for i in range(10)])
    ax.invert_yaxis()
    ax.set(xlabel='t2', ylabel='t1')
    ax.set_title('40000 generations')
    #plt.show()
    plt.savefig(outdir+"h25_t40kproppoly.png")
    
    plt.figure()
    ax = sns.heatmap(tgridprop400k_h25, linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                     xticklabels=[float((i+1)/10) for i in range(10)],
                     yticklabels=[float((i+1)/10) for i in range(10)])
    ax.invert_yaxis()
    ax.set(xlabel='t2', ylabel='t1')
    ax.set_title('400000 generations')
    #plt.show()
    plt.savefig(outdir+"h25_t400kproppoly.png")
    
    plt.figure()
    ax = sns.heatmap(meanmaxfreq_h25, linewidth=0.5,
            cbar_kws={'label': 'Mean max frequency reached by invading mutation'},
                     xticklabels=[float((i+1)/10) for i in range(10)],
                     yticklabels=[float((i+1)/10) for i in range(10)])
    ax.invert_yaxis()
    ax.set(xlabel='t2', ylabel='t1')
    ax.set_title('Mean max freq')
    #plt.show()
    plt.savefig(outdir+"h25_meanmaxfreq.png")
    
