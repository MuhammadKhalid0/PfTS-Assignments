#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <math.h>

#define S 1.00000000001

double getTimeStamp() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (double)tv.tv_sec + 1e-6 * tv.tv_usec;
}

void initialize_arrays(double *a, double *b, double *c, double *d, int N) {
    for (int i = 0; i < N; ++i) {
        a[i] = 0.0;
        b[i] = 1.0 + i * 0.001;
        c[i] = 2.0 + i * 0.002;
        d[i] = 3.0 + i * 0.003;
    }
}

void run_kernel(const char *label, int kernel_type) {
    printf("\n%s Performance (MFlop/s):\n", label);
    printf("N, MFlop/s\n");

    for (int r = 8; r <= 44; ++r) {
        int N = (int)(1.5 * r);
        double *a = (double *)malloc(N * sizeof(double));
        double *b = (double *)malloc(N * sizeof(double));
        double *c = (double *)malloc(N * sizeof(double));
        double *d = (double *)malloc(N * sizeof(double));

        if (!a || !b || !c || !d) {
            printf("Memory allocation failed!\n");
            exit(EXIT_FAILURE);
        }

        initialize_arrays(a, b, c, d, N);

        int NITER = 1;
        double start, end, runtime;

        do {
            start = getTimeStamp();
            for (int k = 0; k < NITER; ++k) {
                for (int i = 0; i < N; ++i) {
                    if (kernel_type == 0) {
                        // Schönauer triad
                        a[i] = b[i] + c[i] * d[i];
                    } else {
                        // DAXPY
                        a[i] = S * b[i] + a[i];
                    }
                }
                if (a[N / 2] < 0.) printf("%lf\n", a[N / 2]); // prevent optimization
            }
            end = getTimeStamp();
            runtime = end - start;
            if (runtime < 0.1) NITER *= 2;
        } while (runtime < 0.1);

        // Count FLOPs
        int flops_per_iter = (kernel_type == 0) ? 2 : 2;
        double mflops = (double)(NITER * N * flops_per_iter) / (runtime * 1.0e6);

        printf("%d, %.2f\n", N, mflops);

        free(a);
        free(b);
        free(c);
        free(d);
    }
}

int main() {
    run_kernel("Schönauer Triad", 0);
    run_kernel("DAXPY", 1);
    return 0;
}
