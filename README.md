# Projet technique - Recherche de motifs dans l'ADN/ARN

## Contexte

La recherche de motifs dans l'ADN/ARN est un problème classique en bioinformatique. Nous l'abordons ici en recherchant des nullomers, séquences de nucléotides qui ne sont, normalement, pas présentes dans certaines zones du génome.

Les plus petits nullomers humain comportent 11 bases nucléique.

## Contexte technique

Pour ce projet, nous avons utilisé le langage **C** et les outils **CUDA** pour utiliser la puissance de calcul des GPU.

Le compilateur utilisé est **nvcc**, le compilateur CUDA de NVIDIA qui permet de compiler du code C/C++ et CUDA.

## Données utilisées

Nous avons utilisé des fichiers texte contenant le génome de référence humain **GRCh38.p14** disponible sur le site du NCBI : https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001405.40/.

**IMPORTANT :** Afin d'alléger ce repository, nous avons uniquement mis une portion du CHR18. Vous par contre, télécharger le génome de référence complet sur le site du NCBI et le placer dans le dossier `sequences/`.

Certains fichiers de NCBI contiennent des bases nucléique à la fois représenté par des majuscules et des minuscules (A et a).
Or notre algorithme, pour des raisons de performance, ne prend en compte que les majuscules. Nous avons donc mis à disposition un fichier `maj.c` qui permet de convertir un fichier texte en entrée en un fichier texte en sortie avec uniquement des majuscules. 

## Algorithme REG

Pour rechercher les nullomers, nous avons créé un algorithme qui repose sur la technique de fenêtre glissante et qui représente la fenêtre sur un entier en utilisant chaque bit pour représenter les bases. C'est pour cela que nous avons choisi d'appeler cet algorithme **REG** pour **R**echerche par **E**ntier **G**lissant.

En C, un entier est représenté sur 32 bits. En convertissant, les bases A, C, G et T en 0, 1, 2 et 3, nous pouvons représenter une base sur 2 bits et donc une séquence de 16 bases sur 32 bits. Nous pouvons donc utiliser un entier pour représenter une fenêtre de 16 bases, parfait pour rechercher des nullomers de 11 bases.


## Fichiers disponibles

- `reg.c` : Algorithme REG en C
- `reg_mt.c` : Algorithme REG en C avec multithreading
- `reg.cu` : Algorithme REG en CUDA

Les fihiers utils sont également disponibles dans le dossier `utils/`. 
