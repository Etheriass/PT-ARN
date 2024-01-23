/**
 * @file reg.cu
 * @brief Contains the code for the CUDA version of the REG algorithm
 */

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
// #include "utils.cuh"

#define SEQ "GTTAAGTTAAGT" //"GTTAAGTTAA"
#define SEQ_LEN strlen(SEQ)

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

/*
 * @brief Open the sequence file.
 * @param *path path to the file
 * @return FILE* file pointer
 */
FILE *openSequence(const char *path)
{
    FILE *fp;
    fp = fopen(path, "r");
    if (fp == NULL)
    {
        printf("Error while opening file : %s\n", path);
        exit(EXIT_FAILURE);
    }
    return fp;
}

/*
 * @brief Get the size of the file.
 * @param *fp file pointer
 * @return long size of the file
 */
long get_size_file(FILE *fp)
{
    fseek(fp, 0L, SEEK_END);
    long size = ftell(fp);
    rewind(fp);
    return size;
}

/*
 * @brief Return the int corresponding to the given ADN sequence.
 * @param *seq sequence to convert
 * @return int converted sequence
 */
int code_seq_bin(const char *seq)
{
    int bin = ATCG_to_int(seq[0]);
    for (int i = 1; i < strlen(seq); i++)
    {
        bin = bin << 2;
        bin = bin | ATCG_to_int(seq[i]);
    }
    return bin;
}

/*
 * @brief Return the time difference between two timeval.
 * @param *start start timeval
 * @param *end end timeval
 * @return float time difference
 */
float time_diff(struct timeval *start, struct timeval *end)
{
    return (end->tv_sec - start->tv_sec) + 1e-6 * (end->tv_usec - start->tv_usec);
}

__global__ void researchThread(char *part, long size, int seq_hash, int effaceur)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int nb_threads = blockDim.x * blockDim.y * gridDim.x * gridDim.y;
    long part_size = size / nb_threads;
    long start = id == 0 ? id * part_size : id * part_size - SEQ_LEN + 1;
    long end = id * part_size + part_size;

    // Initialize the first window
    long i = start;
    int win = ATCG_to_int(part[i]);
    for (short int j = 1; j < SEQ_LEN; j++)
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
    printf("Researching '%s' :\n", SEQ);
    struct timeval start_loading, end_loading, start_loading_gpu, end_loading_gpu, start_searching, end_searching;

    int seq_hash = code_seq_bin(SEQ);
    int effaceur = (int)(pow(2, 2 * SEQ_LEN) - 1);

    // Get the file and its size
    gettimeofday(&start_loading, NULL);
    const char *path = "sequences/GRCH38";
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
    int threads_per_blocks = 128; // Adjust to the GPU
    int blocks_per_grid = 10;     // Adjust to the GPU

    // launch threads
    gettimeofday(&start_searching, NULL);
    researchThread<<<blocks_per_grid, threads_per_blocks>>>(d_buffer, size, seq_hash, effaceur);

    // Wait for threads to finish
    cudaDeviceSynchronize();
    gettimeofday(&end_searching, NULL);

    // printf("Found %d times\n", found);
    printf("Time taken: %f seconds\n", time_diff(&start_searching, &end_searching));

    free(buffer);
    cudaFree(d_buffer);
    return EXIT_SUCCESS;
}
