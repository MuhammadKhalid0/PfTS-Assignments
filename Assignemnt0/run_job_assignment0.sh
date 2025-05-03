#!/bin/bash -l
#
#SBATCH --nodes=1
#SBATCH --time=00:08:00
#SBATCH --job-name=ln2
#SBATCH --export=NONE
#SBATCH --output=ln2_output.txt

# First non-empty, non-comment line ends SBATCH options
unset SLURM_EXPORT_ENV

# Load Intel compiler
module load intel

# Compile the code
icpx -O3 -xHost Assignment0.cpp -o Assignment0

# Run with fixed frequency using srun
echo "Running with fixed CPU frequency (2.4 GHz)..."
srun --cpu-freq=2400000-2400000:performance ./Assignment0

# Run again with performance governor (Turbo Mode)
echo "Running with performance governor..."
srun --cpu-freq=performance ./Assignment0
