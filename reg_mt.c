/**
 @file reg_mt.c
 @brief Contains the code for the multithreaded version of the REG algorithm.
*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>
#include <pthread.h>
#include "utils/utils.h"

#define SEQ "GTTAAGTTAAGT"  // sequence to research
#define SEQ_LEN strlen(SEQ) // length of the sequence
#define THREADS 4           // number of threads

// Global variables
char *buffer;
int seq_hash;
int effaceur;
int found = 0;
typedef struct
{
    long start;
    long end;
} ThreadData;

void *researchThread(void *arg)
{
    ThreadData *data = (ThreadData *)arg;
    long i = data->start;

    // Initialize the first window
    int win = ATCG_to_int(buffer[i]);
    for (short int j = 1; j < SEQ_LEN; j++)
    {
        i++;
        win = win << 2;
        win = win | ATCG_to_int(buffer[i]);
    }

    // Slide the window and compare
    while (i < data->end)
    {
        i++;
        int c = buffer[i];
        while (c == 78) // 'N'
        {
            i++;
            c = buffer[i];
        }
        if (c == 10) //'\n'
        {
            i++;
            c = buffer[i];
        }
        if (c == -1)
        {
            break;
        }

        win = win << 2;
        win = win | ATCG_to_int(c);
        win = win & effaceur;
        if (win == seq_hash)
        {
            found++;
            // printf("Found at position %ld", i);
        }
    }
}

int main()
{
    // Initialization
    printf("Researching '%s' :\n", SEQ);
    struct timeval start_loading, end_loading, start_searching, end_searching;

    // Get the file and its size
    gettimeofday(&start_loading, NULL);
    const char *path = "sequences/GRCH38";
    FILE *file = openSequence(path);
    long size = get_size_file(file);

    // Load the file in memory
    buffer = (char *)malloc(size);
    size_t bytesRead = fread(buffer, 1, size, file);
    fclose(file);
    gettimeofday(&end_loading, NULL);
    printf("Loaded %ld octets in %fs\n", size, time_diff(&start_loading, &end_loading));

    // Initialize variables
    seq_hash = code_seq_bin(SEQ);
    effaceur = (pow(2, 2 * SEQ_LEN) - 1);
    gettimeofday(&start_searching, NULL);

    // Launch threads
    pthread_t threads[THREADS];
    ThreadData *thread_data = (ThreadData *)malloc(THREADS * sizeof(ThreadData));
    for (int i = 0; i < THREADS; i++)
    {
        thread_data[i].start = i * (size / THREADS);
        thread_data[i].end = (i + 1) * (size / THREADS);
        pthread_create(&threads[i], NULL, researchThread, (void *)&thread_data[i]);
    }

    // Wait for threads to finish
    for (int i = 0; i < THREADS; ++i)
    {
        pthread_join(threads[i], NULL);
    }
    gettimeofday(&end_searching, NULL);

    printf("Found %d times\n", found);
    printf("Time taken: %f seconds\n", time_diff(&start_searching, &end_searching));
    
    free(thread_data);
    free(buffer);
    return 0;
}
