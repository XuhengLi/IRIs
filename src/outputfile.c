
#include<stdio.h>
#include<stdlib.h>

char* outputfile( char* fname, char* fcontent) {
    FILE *fp=fopen(fname, "w");
    fprintf(fp,"%s\n", fcontent);
    fclose(fp);
    return fcontent;
 }

