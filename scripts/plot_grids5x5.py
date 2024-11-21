# NOTE: on CS cluster, run with python 3:
# source /share/apps/source_files/python/python-3.9.5.source
# python3 parse_simout.py

import glob
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
import sys

parser = argparse.ArgumentParser(description="plot 5x5 selection grids")
parser.add_argument("-i", "--indir", help="directory with slim output")
parser.add_argument("-o", "--outdir", help="directory for plot output")
parser.add_argument("-g", "--grid", help="grid interval")
args = parser.parse_args(args=None if sys.argv[1:] else ['--help'])

indir = args.indir
outdir = args.outdir
grid = args.grid

files=glob.glob(indir+"*.txt")

tot_h50 = np.zeros((5,5))
totbls_h50 = np.zeros((5,5)) # total number of sims that went indo bls phase (polym not lost before reaching 5%)
nlost_h50 = np.zeros((5,5))
proplost_h50 = np.zeros((5,5))
meantlost_h50 = np.zeros((5,5))
nfix_h50 = np.zeros((5,5))
propfix_h50 = np.zeros((5,5))
meantfix_h50 = np.zeros((5,5))
tgrid16k_h50 = np.zeros((5,5))
tgrid32k_h50 = np.zeros((5,5))
tgrid160k_h50 = np.zeros((5,5))
tgrid320k_h50 = np.zeros((5,5))
tgridprop16k_h50 = np.zeros((5,5))
tgridprop32k_h50 = np.zeros((5,5))
tgridprop160k_h50 = np.zeros((5,5))
tgridprop320k_h50 = np.zeros((5,5))
meanmaxfreq_h50 = np.zeros((5,5))

tot_h25 = np.zeros((5,5))
totbls_h25 = np.zeros((5,5)) # total number of sims that went indo bls phase (polym not lost before reaching 5%)
nlost_h25 = np.zeros((5,5))
proplost_h25 = np.zeros((5,5))
meantlost_h25 = np.zeros((5,5))
nfix_h25 = np.zeros((5,5))
propfix_h25 = np.zeros((5,5))
meantfix_h25 = np.zeros((5,5))
tgrid16k_h25 = np.zeros((5,5))
tgrid32k_h25 = np.zeros((5,5))
tgrid160k_h25 = np.zeros((5,5))
tgrid320k_h25 = np.zeros((5,5))
tgridprop16k_h25 = np.zeros((5,5))
tgridprop32k_h25 = np.zeros((5,5))
tgridprop160k_h25 = np.zeros((5,5))
tgridprop320k_h25 = np.zeros((5,5))
meanmaxfreq_h25 = np.zeros((5,5))

selalpha = np.zeros((5,5))
pstar = np.zeros((5,5))

OD_flag = False

if grid=='0.01':
    s_dic = {0.01:0, 0.02:1, 0.05:2, 0.09:3, 0.1:4}
if grid=='0.1':
    s_dic = {0.1:0, 0.2:1, 0.5:2, 0.9:3, 1:4}

for file in files:
    with open(file) as f:
        next(f) # skip header line
        line = f.readline().strip().split(',')
        if line[0]: # if file has more than header
            # columns: s1,s2,h,bls_start,4000,40000,400000,lost,fixed,maxfreq,invading_allele
            # new columns: sel1,sel2,h,bls_start,16000,32000,160000,320000,lost,fixed,maxfreq,newmut
            s1=round(float(line[0]), 2)
            s2=round(float(line[1]), 2)
            t1 = s_dic[s1]
            t2 = s_dic[s2]
            h = line[2]
            bls_start = line[3]
            f16k = float(line[4])
            f32k = float(line[5])
            f160k = float(line[6])
            f320k = float(line[7])
            tlost = line[8]
            tfixed = line[9]
            maxfreq = float(line[10])
            if h=="NA": #for overdominance
                OD_flag = True
                tgrid16k_h50[t1,t2]  += f16k>0  and f16k <1
                tgrid32k_h50[t1,t2]  += f32k>0  and f32k <1
                tgrid160k_h50[t1,t2] += f160k>0 and f160k <1
                tgrid320k_h50[t1,t2] += f320k>0 and f320k <1
                meanmaxfreq_h50[t1,t2] += maxfreq
                tot_h50[t1,t2] += 1
                if bls_start!="NA":
                    totbls_h50[t1,t2] += 1
                if tlost != "NA":
                    nlost_h50[t1,t2] += 1
                    meantlost_h50[t1,t2] += float(tlost)
                if tfixed != "NA":
                    nfix_h50[t1,t2] += 1
                    meantfix_h50[t1,t2] += float(tfixed)
            if h=="0.5" :
                h = float(h)
                tgrid16k_h50[t1,t2]  += f16k>0  and f16k <1
                tgrid32k_h50[t1,t2]  += f32k>0  and f32k <1
                tgrid160k_h50[t1,t2] += f160k>0 and f160k <1
                tgrid320k_h50[t1,t2] += f320k>0 and f320k <1
                meanmaxfreq_h50[t1,t2] += maxfreq
                tot_h50[t1,t2] += 1
                if bls_start!="NA":
                    totbls_h50[t1,t2] += 1
                if tlost != "NA":
                    nlost_h50[t1,t2] += 1
                    meantlost_h50[t1,t2] += float(tlost)
                if tfixed != "NA":
                    nfix_h50[t1,t2] += 1
                    meantfix_h50[t1,t2] += float(tfixed)
            if h=="0.25":
                h = float(h)
                tgrid16k_h25[t1,t2]  += f16k>0  and f16k <1
                tgrid32k_h25[t1,t2]  += f32k>0  and f32k <1
                tgrid160k_h25[t1,t2] += f160k>0 and f160k <1
                tgrid320k_h25[t1,t2] += f320k>0 and f320k <1
                meanmaxfreq_h25[t1,t2] += maxfreq
                tot_h25[t1,t2]+=1
                if bls_start!="NA":
                    totbls_h25[t1,t2] += 1
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
tgridprop16k_h50 = tgrid16k_h50/totbls_h50
tgridprop32k_h50 = tgrid32k_h50/totbls_h50
tgridprop160k_h50 = tgrid160k_h50/totbls_h50
tgridprop320k_h50 = tgrid320k_h50/totbls_h50
meanmaxfreq_h50 = meanmaxfreq_h50/tot_h50

### Create plots 


# Number of simulations

plt.figure()
ax = sns.heatmap(tot_h50, linewidth=0.5,
        cbar_kws={'label': 'Number of simulations processed'},
        xticklabels=sorted(s_dic.keys()),
        yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
#plt.show()
plt.savefig(outdir+"h50_nsim.png")

# Losses

plt.figure()
ax = sns.heatmap(proplost_h50, linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with lost mutation'},
                 vmin=0,vmax=1,
        xticklabels=sorted(s_dic.keys()),
        yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('Proportion of losses')
#plt.show()
plt.savefig(outdir+"h50_proplost.png")

plt.figure()
ax = sns.heatmap(meantlost_h50, linewidth=0.5,
        cbar_kws={'label': 'Mean time to loss of invading mutation'},
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('Mean time to loss')
#plt.show()
plt.savefig(outdir+"h50_meantlost.png")

# Fixations

plt.figure()
ax = sns.heatmap(propfix_h50, linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with fixed mutation'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('Proportion of fixations')
#plt.show()
plt.savefig(outdir+"h50_propfix.png")

plt.figure()
ax = sns.heatmap(meantfix_h50, linewidth=0.5,
        cbar_kws={'label': 'Mean time to fixation of invading mutation'},
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('Mean time to fixation')
#plt.show()
plt.savefig(outdir+"h50_meantfix.png")

# Polymporphism

#---------------------
## colorscale form 0-1
plt.figure()
ax = sns.heatmap(tgridprop16k_h50, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('16k generations')
#plt.show()
plt.savefig(outdir+"h50_t16kproppoly.png")

plt.figure()
ax = sns.heatmap(tgridprop32k_h50, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('32k generations')
#plt.show()
plt.savefig(outdir+"h50_t32kproppoly.png")

plt.figure()
ax = sns.heatmap(tgridprop160k_h50, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('160k generations')
#plt.show()
plt.savefig(outdir+"h50_t160kproppoly.png")

plt.figure()
ax = sns.heatmap(tgridprop320k_h50, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('320k generations')
#plt.show()
plt.savefig(outdir+"h50_t320kproppoly.png")

#------------------------
# no limits to colorscale 
plt.figure()
ax = sns.heatmap(tgridprop16k_h50, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('16k generations')
#plt.show()
plt.savefig(outdir+"h50_t16kproppoly_freescale.png")

plt.figure()
ax = sns.heatmap(tgridprop32k_h50, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('32k generations')
#plt.show()
plt.savefig(outdir+"h50_t32kproppoly_freescale.png")

plt.figure()
ax = sns.heatmap(tgridprop160k_h50, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('160k generations')
#plt.show()
plt.savefig(outdir+"h50_t160kproppoly_freescale.png")

plt.figure()
ax = sns.heatmap(tgridprop320k_h50, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
        cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
ax.set_title('320k generations')
#plt.show()
plt.savefig(outdir+"h50_t320kproppoly_freescale.png")

plt.figure()
ax = sns.heatmap(meanmaxfreq_h50, linewidth=0.5,
        cbar_kws={'label': 'Mean max frequency reached by invading mutation'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
ax.invert_yaxis()
ax.set(xlabel='s2', ylabel='s1')
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
    tgridprop16k_h25 = tgrid16k_h25/totbls_h25
    tgridprop32k_h25 = tgrid32k_h25/totbls_h25
    tgridprop160k_h25 = tgrid160k_h25/totbls_h25
    tgridprop320k_h25 = tgrid320k_h25/totbls_h25
    meanmaxfreq_h25 = meanmaxfreq_h25/tot_h25
    
    
    ### Create plots 
    
    # Number of simulations
    
    plt.figure()
    ax = sns.heatmap(tot_h25, linewidth=0.5,
            cbar_kws={'label': 'Number of simulations processed'},
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
    ax.invert_yaxis()
    ax.set(xlabel='s2', ylabel='s1')
    #plt.show()
    plt.savefig(outdir+"h25_nsim.png")
    
    # Losses
    
    plt.figure()
    ax = sns.heatmap(proplost_h25, linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with lost mutation'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
    ax.invert_yaxis()
    ax.set(xlabel='s2', ylabel='s1')
    ax.set_title('Proportion of losses')
    #plt.show()
    plt.savefig(outdir+"h25_proplost.png")
    
    plt.figure()
    ax = sns.heatmap(meantlost_h25, linewidth=0.5,
            cbar_kws={'label': 'Mean time to loss of invading mutation'},
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
    ax.invert_yaxis()
    ax.set(xlabel='s2', ylabel='s1')
    ax.set_title('Mean time to loss')
    #plt.show()
    plt.savefig(outdir+"h25_meantlost.png")
    
    # Fixations
    
    plt.figure()
    ax = sns.heatmap(propfix_h25, linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with fixed mutation'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
    ax.invert_yaxis()
    ax.set(xlabel='s2', ylabel='s1')
    ax.set_title('Proportion of fixations')
    #plt.show()
    plt.savefig(outdir+"h25_propfix.png")
    
    plt.figure()
    ax = sns.heatmap(meantfix_h25, linewidth=0.5,
            cbar_kws={'label': 'Mean time to fixation of invading mutation'},
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
    ax.invert_yaxis()
    ax.set(xlabel='s2', ylabel='s1')
    ax.set_title('Mean time to fixation')
    #plt.show()
    plt.savefig(outdir+"h25_meantfix.png")
    
    # Polymporphism
    
    plt.figure()
    ax = sns.heatmap(tgridprop16k_h25, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
    ax.invert_yaxis()
    ax.set(xlabel='s2', ylabel='s1')
    ax.set_title('16k generations')
    #plt.show()
    plt.savefig(outdir+"h25_t16kproppoly.png")
    
    plt.figure()
    ax = sns.heatmap(tgridprop32k_h25, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
    ax.invert_yaxis()
    ax.set(xlabel='s2', ylabel='s1')
    ax.set_title('32k generations')
    #plt.show()
    plt.savefig(outdir+"h25_t32kproppoly.png")
    
    plt.figure()
    ax = sns.heatmap(tgridprop160k_h25, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
    ax.invert_yaxis()
    ax.set(xlabel='s2', ylabel='s1')
    ax.set_title('160k generations')
    #plt.show()
    plt.savefig(outdir+"h25_t160kproppoly.png")
    
    plt.figure()
    ax = sns.heatmap(tgridprop320k_h25, annot=True, fmt='.2f', cmap="viridis", linewidth=0.5,
            cbar_kws={'label': 'Proportion of simulations with polymorphism'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
    ax.invert_yaxis()
    ax.set(xlabel='s2', ylabel='s1')
    ax.set_title('320k generations')
    #plt.show()
    plt.savefig(outdir+"h25_t320kproppoly.png")
    
    plt.figure()
    ax = sns.heatmap(meanmaxfreq_h25, linewidth=0.5,
            cbar_kws={'label': 'Mean max frequency reached by invading mutation'},
                 vmin=0,vmax=1,
                 xticklabels=sorted(s_dic.keys()),
                 yticklabels=sorted(s_dic.keys()))
    ax.invert_yaxis()
    ax.set(xlabel='s2', ylabel='s1')
    ax.set_title('Mean max freq')
    #plt.show()
    plt.savefig(outdir+"h25_meanmaxfreq.png")
