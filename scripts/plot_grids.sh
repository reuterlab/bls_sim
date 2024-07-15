# Run scripts to produce simulation summary plots

simpref='OD_N2k_r1e-8_grid0.01'
OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/grid_plots/'$simpref'/'
mkdir $OUTDIR
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/'$simpref'/',OUTDIR=$OUTDIR,GRID=0.01 job_plotgrid.sh

simpref='OD_N2k_r1e-8_grid0.1'
OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/grid_plots/'$simpref'/'
mkdir $OUTDIR
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/'$simpref'/',OUTDIR=$OUTDIR,GRID=0.1 job_plotgrid.sh

simpref='AP_N2k_r1e-8_grid0.01'
OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/grid_plots/'$simpref'/'
mkdir $OUTDIR
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/'$simpref'/',OUTDIR=$OUTDIR,GRID=0.01 job_plotgrid.sh

simpref='AP_N2k_r1e-8_grid0.1'
OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/grid_plots/'$simpref'/'
mkdir $OUTDIR
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/'$simpref'/',OUTDIR=$OUTDIR,GRID=0.1 job_plotgrid.sh

simpref='SA_N2k_r1e-8_grid0.01'
OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/grid_plots/'$simpref'/'
mkdir $OUTDIR
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/'$simpref'/',OUTDIR=$OUTDIR,GRID=0.01 job_plotgrid.sh

simpref='SA_N2k_r1e-8_grid0.1'
OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/grid_plots/'$simpref'/'
mkdir $OUTDIR
qsub -v INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/'$simpref'/',OUTDIR=$OUTDIR,GRID=0.1 job_plotgrid.sh
