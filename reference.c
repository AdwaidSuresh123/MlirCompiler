// reference_matmul.c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void simple_matmul(float* A, float* B, float* C, int N) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            float sum = 0.0f;
            for (int k = 0; k < N; k++) {
                sum += A[i * N + k] * B[k * N + j];
            }
            C[i * N + j] = sum;
        }
    }
}

int main() {
    const int N = 128;
    const int size = N * N;
    
    float* A = malloc(size * sizeof(float));
    float* B = malloc(size * sizeof(float));
    float* C = malloc(size * sizeof(float));
    
    // Initialize
    for (int i = 0; i < size; i++) {
        A[i] = 1.0f;
        B[i] = 2.0f;
    }
    
    clock_t start = clock();
    simple_matmul(A, B, C, N);
    clock_t end = clock();
    
    double time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    double flops = 2.0 * N * N * N;
    double mflops = flops / time_used / 1e6;
    
    printf("Reference C implementation:\n");
    printf("Time: %.6f seconds\n", time_used);
    printf("Performance: %.2f MFLOPS\n", mflops);
    printf("Result check: C[0] = %f (expected: %f)\n", C[0], 256.0f);
    
    free(A);
    free(B);
    free(C);
    return 0;
}