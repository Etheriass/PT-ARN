/**
* @file utils_cuda.cu
* @brief This file contains the functions used in the REG algorithm.    
*/

#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include "utils_cuda.cuh"

/**
* @brief Convert a char to an int.
* @param c char to convert
* @return int converted char
*/
char ATCG_to_int_intern(char c)
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
FILE *openSequence(char *path)
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
    int bin = ATCG_to_int_intern(seq[0]);
    for (int i = 1; i < strlen(seq); i++)
    {
        bin = bin << 2;
        bin = bin | ATCG_to_int_intern(seq[i]);
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


/**
 * @brief Get the sequence to search for.
 * @return char* sequence to search for
 */
char *input_seq(){
    char *seq = (char *)malloc(16);
    printf("Enter the sequence to search for: ");
    scanf("%s", seq);
    if (strlen(seq) > 16)
    {
        printf("Too long sequence. Please enter shorter sequence.\n");
        return input_seq();
    }
    int valid = 1;
    for (int i = 0; i < strlen(seq); i++)
    {
        if (seq[i] != 'A' && seq[i] != 'T' && seq[i] != 'C' && seq[i] != 'G')
        {
            valid = 0;
            break;
        }
    }
    if (!valid)
    {
        printf("Invalid DNA sequence. Please enter a valid DNA sequence.\n");
        return input_seq();
    }
    return seq;
}