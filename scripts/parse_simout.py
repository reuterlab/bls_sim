import glob
import numpy as np

outdir="/home/dbrandt/bls_sim/slimout/AP_N1e3"

files=glob.glob(outdir+"*.txt")

tgrid = np.zeros((10,10))b
for file in files:
    with open(file) as f:
        next(f) # skip header line
        line = f.readline().strip().split()
        # columns: t1,t2,h,4000,40000,400000,lost,fixed,maxfreq
        t1 = line[0]
        t2 = line[1]
        h = line[2]
        f4k = line[3]
        f40k = line[4]
        f100k = line[5]
        tlost = line[6]
        tfixed = line[7]
        maxfreq = line[8]

