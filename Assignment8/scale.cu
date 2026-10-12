#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
__global__ void scale_kernel(double* a, long n)
{
    long tid    = threadIdx.x + blockDim.x * (long)blockIdx.x;
    long stride = blockDim.x  * (long)gridDim.x;
    for (long i = tid; i < n; i += stride)
        a[i] = 2.0 * a[i];
}

static void check(cudaError_t err, const char* msg)
{
    if (err != cudaSuccess) {
        fprintf(stderr, "CUDA error at %s: %s\n", msg, cudaGetErrorString(err));
        exit(1);
    }
}

int main(int argc, char** argv)
{
    if (argc != 5) {
        fprintf(stderr,
            "Usage: %s <n_elements> <repetitions> <num_blocks> <block_size>\n",
            argv[0]);
        return 1;
    }

    long n          = atol(argv[1]);
    int  reps       = atoi(argv[2]);
    int  num_blocks = atoi(argv[3]);
    int  block_size = atoi(argv[4]);
    size_t bytes    = n * sizeof(double);

    printf("Problem size : %ld elements (%.2f MB)\n", n, bytes / 1e6);
    printf("Repetitions  : %d\n", reps);
    printf("Grid         : %d blocks x %d threads = %d total threads\n\n",
           num_blocks, block_size, num_blocks * block_size);
    double* h_a = (double*)malloc(bytes);
    if (!h_a) { fprintf(stderr, "malloc failed\n"); return 1; }
    for (long i = 0; i < n; i++) h_a[i] = 1.0;
    double* d_a;
    check(cudaMalloc(&d_a, bytes), "cudaMalloc");
    cudaEvent_t t0, t1;
    check(cudaEventCreate(&t0), "eventCreate t0");
    check(cudaEventCreate(&t1), "eventCreate t1");
    check(cudaEventRecord(t0), "record t0 H2D");
    check(cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice), "H2D memcpy");
    check(cudaEventRecord(t1), "record t1 H2D");
    check(cudaEventSynchronize(t1), "sync H2D");

    float h2d_ms;
    check(cudaEventElapsedTime(&h2d_ms, t0, t1), "elapsed H2D");
    check(cudaDeviceSynchronize(), "pre-kernel sync");

    check(cudaEventRecord(t0), "record t0 kernel");
    for (int r = 0; r < reps; r++)
        scale_kernel<<<num_blocks, block_size>>>(d_a, n);
    check(cudaEventRecord(t1), "record t1 kernel");
    check(cudaEventSynchronize(t1), "post-kernel sync");

    float kernel_ms;
    check(cudaEventElapsedTime(&kernel_ms, t0, t1), "elapsed kernel");

    check(cudaEventRecord(t0), "record t0 D2H");
    check(cudaMemcpy(h_a, d_a, bytes, cudaMemcpyDeviceToHost), "D2H memcpy");
    check(cudaEventRecord(t1), "record t1 D2H");
    check(cudaEventSynchronize(t1), "sync D2H");

    float d2h_ms;
    check(cudaEventElapsedTime(&d2h_ms, t0, t1), "elapsed D2H");

    double kernel_bw = (2.0 * bytes * reps) / (kernel_ms * 1e-3) / 1e9;
    double h2d_bw    = bytes / (h2d_ms  * 1e-3) / 1e9;
    double d2h_bw    = bytes / (d2h_ms  * 1e-3) / 1e9;

    printf("H2D transfer : %8.3f ms  |  %7.2f GB/s\n", h2d_ms,  h2d_bw);
    printf("Kernel       : %8.3f ms  |  %7.2f GB/s  (effective BW, %d reps)\n",
           kernel_ms, kernel_bw, reps);
    printf("D2H transfer : %8.3f ms  |  %7.2f GB/s\n", d2h_ms,  d2h_bw);
    if (h_a[0] != 2.0 || h_a[n-1] != 2.0)
        fprintf(stderr, "WARNING: result looks wrong (h_a[0]=%.1f)\n", h_a[0]);

    cudaFree(d_a);
    free(h_a);
    cudaEventDestroy(t0);
    cudaEventDestroy(t1);
    return 0;
}
