#!/bin/bash -l
#
# energy_pi.sh  --  Energy-to-solution of pi on Fritz (Ice Lake)
#
# Submit with:   sbatch energy_pi.sh
#
# Measures whole-chip energy (likwid ENERGY group, PWR_PKG_ENERGY) on core 0
# for six cases:  {Turbo, 2.4 GHz, 1.2 GHz} x {scalar, AVX-512}.
#
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=72
#SBATCH --constraint=hwperf          # REQUIRED: enable hardware perf counters
#SBATCH --time=00:30:00
#SBATCH --job-name=energy_pi
#SBATCH --export=NONE

unset SLURM_EXPORT_ENV

module load likwid
module load intel        # or: module load gcc   (match how you compiled)

# --- problem size: pick N so each run takes a few seconds ---
N=2000000000

# Frequencies in kHz for the --cpu-freq option.
#   Turbo  -> do NOT pass --cpu-freq (default = turbo on demand)
#   2.4GHz -> base clock (nominal) of the 8360Y
#   1.2GHz -> minimum
FREQ_BASE=2400000
FREQ_LOW=1200000

run_case () {
    local label="$1"; shift
    local freqopt="$1"; shift     # "" for turbo, or "MIN-MAX:performance"
    local exe="$1"; shift

    echo "=================================================================="
    echo ">>> CASE: ${label}"
    echo "=================================================================="

    if [ -z "$freqopt" ]; then
        srun --cpu-freq=Performance \
             likwid-perfctr -C 0 -g ENERGY ./${exe} ${N}
    else
        srun --cpu-freq=${freqopt} \
             likwid-perfctr -C 0 -g ENERGY ./${exe} ${N}
    fi
    echo
}

# Six cases ---------------------------------------------------------------
run_case "Turbo Mode  | scalar"   ""                              pi_scalar
run_case "Turbo Mode  | AVX-512"  ""                              pi_avx512

run_case "2.4 GHz     | scalar"   "${FREQ_BASE}-${FREQ_BASE}:performance"  pi_scalar
run_case "2.4 GHz     | AVX-512"  "${FREQ_BASE}-${FREQ_BASE}:performance"  pi_avx512

run_case "1.2 GHz     | scalar"   "${FREQ_LOW}-${FREQ_LOW}:performance"    pi_scalar
run_case "1.2 GHz     | AVX-512"  "${FREQ_LOW}-${FREQ_LOW}:performance"    pi_avx512

echo "ALL DONE. Read 'Energy [J]' and 'Power [W]' lines from each block."
