#include <stdio.h>
#include <string.h>
#include <stdlib.h>


char* cmd(char* word)
{
  char *str = malloc(40 * sizeof(char));
  strcat (str,word);
  strcat (str,">abc.txt");
  //printf("%s",str);
  system(word); 
  
  char *text = malloc(80 * sizeof(char));
  FILE *fp=fopen("abc.txt", "r");
  int i=0;
  while(!feof(fp)) {
     text[i++] = fgetc(fp);
  }
  text[i]='\0';
  printf("%s",text);
  fclose(fp);
  return text;
  
    
}

