
#include<stdio.h>
#include<stdlib.h>

#define BUFFER 100

char *inputstring(char *str) {
  char *text = malloc(BUFFER * sizeof(char));
    
  printf("%s", str);
  scanf("%s",text);
  return text;
}

