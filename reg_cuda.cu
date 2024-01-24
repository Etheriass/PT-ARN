/**
 * @file reg_cuda.cu
 * @brief Contains the code for the CUDA version of the REG algorithm
 */

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include "utils/utils_cuda.cuh"

__host__ __device__ int ATCG_to_int(char c)
{
    switch (c)
    {
    case 65: //'A'
        return 0;
        break;
    case 84: //'T'
        return 1;
        break;
    case 67: //'C'
        return 2;
        break;
    case 71: //'G':
        return 3;
        break;
    default:
        return c;
        break;
    }
}

__global__ void researchThread(char *part, long size, int seq_hash, int seq_len, int effaceur)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int nb_threads = blockDim.x * blockDim.y * gridDim.x * gridDim.y;
    long part_size = size / nb_threads;
    long start = id == 0 ? id * part_size : id * part_size - seq_len + 1;
    long end = id * part_size + part_size;

    // Initialize the first window
    long i = start;
    int win = ATCG_to_int(part[i]);
    for (short int j = 1; j < seq_len; j++)
    {
        i++;
        win = win << 2;
        win = win | ATCG_to_int(part[i]);
    }
    if (win == seq_hash)
    {
        printf("Thread %d found at position %ld\n", id, i);
    }

    // Slide the window and compare
    while (i < end)
    {
        i++;
        int c = part[i];
        while (c == 78) // 'N'
        {
            i++;
            c = part[i];
        }
        if (c == 10) //'\n'
        {
            i++;
            c = part[i];
        }

        win = win << 2;
        win = win | ATCG_to_int(c);
        win = win & effaceur;

        if (win == seq_hash)
        {
            printf("Thread %d found at position %ld\n", id, i);
        }
    }
}

int main()
{
    // Initialization
    printf("----- REG -----\n\n");
    char *seq = input_seq();
    struct timeval start_loading, end_loading, start_loading_gpu, end_loading_gpu, start_searching, end_searching;

    // Initialize variables
    int seq_len = strlen(seq);
    int seq_hash = code_seq_bin(seq);
    int effaceur = (int)(pow(2, 2 * seq_len) - 1);

    // Get the file and its size
    char path[60];
    printf("Enter the path of the file to search in: ");
    scanf("%s", path);
    gettimeofday(&start_loading, NULL);
    FILE *file = openSequence(path);
    long size = get_size_file(file);

    // Load the file in memory
    char *buffer = (char *)malloc(size);
    size_t bytesRead = fread(buffer, 1, size, file);
    fclose(file);
    gettimeofday(&end_loading, NULL);
    printf("Loaded %ld octets in %fs\n", size, time_diff(&start_loading, &end_loading));

    // Copy the buffer to the GPU
    gettimeofday(&start_loading_gpu, NULL);
    char *d_buffer; //= (char *)malloc(size);
    cudaMalloc((void **)&d_buffer, size);
    cudaMemcpy(d_buffer, buffer, size, cudaMemcpyHostToDevice);
    gettimeofday(&end_loading_gpu, NULL);
    printf("Loaded %ld octets in %fs on the GPU\n", size, time_diff(&start_loading_gpu, &end_loading_gpu));

    // Config threads
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, 0);
    int blocks_per_grid = deviceProp.multiProcessorCount;
    int threads_per_blocks = 128; // Adjust if needed

    // launch threads
    printf("Researching '%s' on %d threads :\n", seq, blocks_per_grid * threads_per_blocks);
    gettimeofday(&start_searching, NULL);
    researchThread<<<blocks_per_grid, threads_per_blocks>>>(d_buffer, size, seq_hash, seq_len, effaceur);

    // Wait for threads to finish
    cudaDeviceSynchronize();
    gettimeofday(&end_searching, NULL);

    // printf("Found %d times\n", found);
    printf("Time taken: %f seconds\n", time_diff(&start_searching, &end_searching));

    free(buffer);
    cudaFree(d_buffer);
    return EXIT_SUCCESS;
}
