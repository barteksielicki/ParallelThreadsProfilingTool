#include "cuda_runtime.h"
#include <cuda_runtime_api.h>
#include <cmath>
#include <ctime>
#include <stdio.h>
#include <iostream>
#include "../../Library/ParallelThreadProfiler.cuh"
#pragma once
#include <string>
#include <vector>
#include <cuda_runtime_api.h>
#include <cooperative_groups.h>
#include <time.h>
#include <fstream>
#include <math.h>
using namespace std;
using clock_value_t = long long;



__device__ void sleep(clock_value_t sleep_cycles)
{
	clock_value_t start = clock64();
	clock_value_t cycles_elapsed;
	do { cycles_elapsed = clock64() - start; } while (cycles_elapsed < sleep_cycles);
}
__global__ void GPUDelays(long long int* global_now)
{
	RegisterTimeMarker(0); 
	sleep(5000000);
	RegisterTimeMarker(1);
}
int main()
{
	cudaError_t cudaStatus;
	ParallelThreadProfiler::InitialiseProfiling();
	cout << endl << "GPU computations started..." << endl;
	srand(time(NULL));
	long long int *rd;
	cudaMalloc((void **)&rd, sizeof(long long int));

	ParallelThreadProfiler::CreateLabel("start", 0);
	ParallelThreadProfiler::CreateLabel("end", 1);
	ParallelThreadProfiler::InitialiseKernelProfiling("delay_kernel", 32*512, 2);
	GPUDelays <<<32, 512>> > (rd);
	ParallelThreadProfiler::SaveResults();

	cudaStatus = cudaDeviceReset();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaDeviceReset failed!");
		return 1;
	}

	return 0;
}

