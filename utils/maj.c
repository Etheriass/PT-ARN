#include <stdio.h>
#include <stdlib.h>

/*
Simple programme qui copie le contenu d'un fichier d'ADN en remplaçant les 
lettres minuscules par les lettres majuscules.
*/
int main() {
    FILE *sourceFile, *destinationFile;
    char sourceFileName[] = "../sequences/GRCh38";
    char destinationFileName[] = "../sequences/GRCH38";
    char ch;

    sourceFile = fopen(sourceFileName, "r");
    if (sourceFile == NULL) {
        perror("Erreur lors de l'ouverture du fichier source");
        exit(EXIT_FAILURE);
    }

    destinationFile = fopen(destinationFileName, "w");
    if (destinationFile == NULL) {
        fclose(sourceFile);
        perror("Erreur lors de l'ouverture du fichier destination");
        exit(EXIT_FAILURE);
    }

    while ((ch = fgetc(sourceFile)) != EOF) {
        if (ch == 'a')
            ch = 'A';
        if (ch == 't')
            ch = 'T';
        if (ch == 'c')
            ch = 'C';
        if (ch == 'g')
            ch = 'G';
        fputc(ch, destinationFile);
    }

    fclose(sourceFile);
    fclose(destinationFile);

    printf("Copie terminée avec succès.\n");

    return 0;
}
