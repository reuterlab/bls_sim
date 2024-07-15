Ne=2000
mu=1e-8
n=100
# S = number of segregating sites in concatenated file/number of concatenated files/ sites per file
S=14800/3000/10000

a = 0 ; for (i in 1:99){a=a+1/i}
E_S = 4*Ne*mu*a
S
E_S

