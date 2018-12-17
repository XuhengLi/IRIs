#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <stdarg.h>

char* sassign(char *dst, char *src)
{
    free(dst);
    dst = malloc(sizeof(char) * (strlen(src) + 1));

    dst = strcpy(dst, src);
    return dst;
}