
#include<stdio.h>
#include<stdlib.h>

 char *inputfile( char * str, int length) {
  char *text = malloc(length * sizeof(char));
  FILE *fp=fopen(str, "r");
  int i=0;
  while(!feof(fp)) {
     text[i++] = fgetc(fp);
  }
  text[i]='\0';
  fclose(fp);
  return text;
}

