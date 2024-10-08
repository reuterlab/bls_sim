# Run scripts to produce simulation summary plots

function checkdir {
    dir=${1%/}
    if [ ! -d $dir ]; then
        tar xzvf $dir.tar.gz --wildcards "*.txt"
        mv $dir /SAN/reuterlab/balsel_detection/bls_sim/slimout/
    fi
}

function run_plotgrid {
    simpref=$1
    grid=$2
    INDIR='/SAN/reuterlab/balsel_detection/bls_sim/slimout/'$simpref'/'
    OUTDIR='/SAN/reuterlab/balsel_detection/bls_sim/grid_plots/'$simpref'/'
    checkdir $INDIR
    mkdir $OUTDIR
    qsub -v INDIR=$INDIR,OUTDIR=$OUTDIR,GRID=$2 job_plotgrid.sh
}

run_plotgrid 'OD_N20k_r1e-8_grid0.1' '0.1'
run_plotgrid 'OD_N20k_r1e-8_grid0.01' '0.01'
run_plotgrid 'AP_N20k_r1e-8_grid0.1' 0.1
run_plotgrid 'AP_N20k_r1e-8_grid0.01' 0.01
run_plotgrid 'SA_N20k_r1e-8_grid0.1' 0.1
run_plotgrid 'SA_N20k_r1e-8_grid0.01' 0.01

run_plotgrid 'OD_N2k_r1e-8_grid0.1' 0.1
run_plotgrid 'OD_N2k_r1e-8_grid0.01' 0.01
run_plotgrid 'AP_N2k_r1e-8_grid0.01' 0.01
run_plotgrid 'AP_N2k_r1e-8_grid0.1' 0.1
run_plotgrid 'SA_N2k_r1e-8_grid0.01' 0.01
run_plotgrid 'SA_N2k_r1e-8_grid0.1' 0.1

run_plotgrid 'OD_N20k_r1e-7_grid0.1' 0.1
run_plotgrid 'OD_N20k_r1e-7_grid0.01' 0.01
run_plotgrid 'AP_N20k_r1e-7_grid0.1' 0.1
run_plotgrid 'AP_N20k_r1e-7_grid0.01' 0.01
run_plotgrid 'SA_N20k_r1e-7_grid0.1' 0.1
run_plotgrid 'SA_N20k_r1e-7_grid0.01' 0.01

run_plotgrid 'OD_N2k_r1e-7_grid0.1' 0.1
run_plotgrid 'OD_N2k_r1e-7_grid0.01' 0.01
run_plotgrid 'AP_N2k_r1e-7_grid0.01' 0.01
run_plotgrid 'AP_N2k_r1e-7_grid0.1' 0.1
run_plotgrid 'SA_N2k_r1e-7_grid0.01' 0.01
run_plotgrid 'SA_N2k_r1e-7_grid0.1' 0.1
