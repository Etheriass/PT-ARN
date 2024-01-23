/**
 @file reg.c
 @brief Contains the code for the REG algorithm.
*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>
#include "utils/utils.h"

#define SEQ "GTTAAGTTAAGT"
#define SEQ_LEN strlen(SEQ)

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
    char *buffer = (char *)malloc(size);
    size_t bytesRead = fread(buffer, 1, size, file);
    fclose(file);
    gettimeofday(&end_loading, NULL);
    printf("Loaded %ld octets in %fs\n", size, time_diff(&start_loading, &end_loading));

    // Initialize variables
    const int seq_hash = code_seq_bin(SEQ);
    long nb_lines = 0;
    int c = 0;
    int found = 0;
    const int effaceur = (pow(2, 2 * SEQ_LEN) - 1);
    gettimeofday(&start_searching, NULL);

    // Initialize the first window
    int win = ATCG_to_int(buffer[0]);
    for (short int j = 1; j < SEQ_LEN; j++)
    {
        win = win << 2;
        win = win | ATCG_to_int(buffer[j]);
    }
    // Slide the window and compare
    for (long i = SEQ_LEN; i < size; i++)
    {
        c = buffer[i];
        while (c == 78) // 'N'
        {
            i++;
            c = buffer[i];
        }
        if (c == 10) //'\n'
        {
            nb_lines++;
            i++;
            c = buffer[i];
        }

        win = win << 2;
        win = win | ATCG_to_int(c);
        win = win & effaceur;
        if (win == seq_hash)
        {
            found++;
            printf("Found at position %ld\n", i - nb_lines);
            // printf("Found at line %ld\n", nb_lines);
        }
    }

    gettimeofday(&end_searching, NULL);

    printf("Found %d times\n", found);
    printf("Time taken: %f seconds\n", time_diff(&start_searching, &end_searching));

    free(buffer);
    return EXIT_SUCCESS;
}
