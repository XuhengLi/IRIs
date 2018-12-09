/*
 *  A function illustrating how to link C code to code generated from LLVM 
 */

#include <stdio.h>

/*
 * Font information: one byte per row, 8 rows per character
 * In order, space, 0-9, A-Z
 */

int inputint(int b)
{
   int a;
   scanf("%d",&a);
   return a;
}



