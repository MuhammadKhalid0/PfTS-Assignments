/*
 * pi.c  --  compute-bound pi via numerical integration of 4/(1+x^2) on [0,1].
 *
 * Compute-bound, no significant memory traffic -> ideal for energy-to-solution
 * measurements where the only knobs are clock frequency and SIMD width.
 *
 * Build two variants on Fritz (Ice Lake, AVX-512):
 *   Scalar (no vectorization):
 *     icx  -O3 -no-vec -no-simd -march=icelake-server pi.c -o pi_scalar
 *   AVX-512 (full width):
 *     icx  -O3 -xICELAKE-SERVER -qopt-zmm-usage=high pi.c -o pi_avx512
 *
 * (gcc equivalents:)
 *     gcc  -O3 -fno-tree-vectorize -march=icelake-server pi.c -o pi_scalar
 *     gcc  -O3 -march=icelake-server -mprefer-vector-width=512 pi.c -o pi_avx512
 *
 * Increase N until the runtime is a few seconds so the energy reading is stable.
 */
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    long N = (argc > 1) ? atol(argv[1]) : 2000000000L;   /* 2e9 steps */
    double h = 1.0 / (double)N;
    double sum = 0.0;

    /* reduction loop is the hot kernel; the compiler vectorizes this */
    #pragma omp simd reduction(+:sum)
    for (long i = 0; i < N; ++i) {
        double x = (i + 0.5) * h;
        sum += 4.0 / (1.0 + x * x);
    }

    double pi = sum * h;
    printf("N = %ld   pi = %.15f\n", N, pi);
    return 0;
}
