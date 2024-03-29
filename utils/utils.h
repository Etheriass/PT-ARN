/**
 * @file utils.c
 * @brief This file contains the functions used in the REG algorithm.
 */

#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

/**
 * @brief Convert a char to an int.
 * @param c char to convert
 * @return int converted char
 */
int ATCG_to_int(char c);

/**
 * @brief Open the sequence file.
 * @param *path path to the file
 * @return FILE* file pointer
 */
FILE *openSequence(const char *path);

/**
 * @brief Get the size of the file.
 * @param *fp file pointer
 * @return long size of the file
 */
long get_size_file(FILE *fp);

/**
 * @brief Return the int corresponding to the given ADN sequence.
 * @param *seq sequence to convert
 * @return int converted sequence
 */
int code_seq_bin(const char *seq);

/**
 * @brief Return the time difference between two timeval.
 * @param *start start timeval
 * @param *end end timeval
 * @return float time difference
 */
float time_diff(struct timeval *start, struct timeval *end);

/**
 * @brief Get the sequence to search for.
 * @return char* sequence to search for
 */
char *input_seq();