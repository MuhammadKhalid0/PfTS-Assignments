#include <iostream>
#include <time.h>
using namespace std;

// Time measurement function using Linux CLOCK_MONOTONIC
double getTimeStamp() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double) ts.tv_sec + (double) ts.tv_nsec * 1.e-9;
}

int main() {
    double sum, x, delta_x, S, E;
    int N = 10;
    do {
        S = getTimeStamp();
        delta_x = 1.0 / N;
        sum = 0.0;
        for (int i = 0; i < N; i++) {
            x = (i + 0.5) * delta_x;
            sum += 1.0 / (1.0 + x);
        }
        double ln = sum * delta_x;
        E = getTimeStamp();
        if (E - S > 1e-4) {
            cout << "ln(2) ≈ " << ln << " with N = " << N << endl;
            cout << "Elapsed time: " << (E - S) << " seconds" << endl;

            double time_per_iter = (E - S) / N;
            double cpu_cycles = time_per_iter * 2.4e9; // 2.4 GHz = 2.4e9 Hz

            cout << "Time per iteration: " << time_per_iter << " seconds" << endl;
            cout << "Estimated CPU cycles per iteration: " << cpu_cycles << endl;

            break;
        }
        N *= 2;
    } while (1);
    
    return 0;
}
