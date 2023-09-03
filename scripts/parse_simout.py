import glob
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

outdir="/home/dbrandt/bls_sim/slimout/AP_N1e3/"
outdir="/home/debora/Dropbox/private/projects/uclpostdoc/bls_sim/slimout/AP_N1e3/"

files=glob.glob(outdir+"*.txt")

tgrid4k = np.zeros((10,10))
tgrid40k = np.zeros((10,10))
tgrid400k = np.zeros((10,10))
for file in files:
    with open(file) as f:
        next(f) # skip header line
        line = f.readline().strip().split(',')
        if line[0]: # if file has more than header
            # columns: t1,t2,h,4000,40000,400000,lost,fixed,maxfreq
            t1 = int((float(line[0])-0.1) * 10)
            t2 = int((float(line[1])-0.1) * 10)
            h = line[2]
            f4k = float(line[3])
            if f4k > 0:
                print(f4k)
            f40k = float(line[4])
            f400k = float(line[5])
            tlost = line[6]
            tfixed = line[7]
            maxfreq = line[8]
            tgrid4k[t1,t2] += f4k>0
            tgrid40k[t1,t2] += f40k>0
            tgrid400k[t1,t2] += f400k>0

plt.figure()
ax = sns.heatmap(tgrid4k, linewidth=0.5,
        cbar_kws={'label': 'Polymorphic sites'})
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('4000 generations')
#plt.show()
plt.savefig(outdir+"t4kgrid.png")

plt.figure()
ax = sns.heatmap(tgrid40k, linewidth=0.5,
        cbar_kws={'label': 'Polymorphic sites'})
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('40000 generations')
#plt.show()
plt.savefig(outdir+"t40kgrid.png")

plt.figure()
ax = sns.heatmap(tgrid400k, linewidth=0.5,
        cbar_kws={'label': 'Polymorphic sites'})
ax.invert_yaxis()
ax.set(xlabel='t2', ylabel='t1')
ax.set_title('400000 generations')
#plt.show()
plt.savefig(outdir+"t400kgrid.png")
