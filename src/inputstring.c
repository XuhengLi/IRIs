
#include<stdio.h>
#include<stdlib.h>

#define BUFFER 100

char *inputstring( int a) {
  char *text = malloc(BUFFER * sizeof(char));
    
  scanf("%s",text);
  return text;
}

