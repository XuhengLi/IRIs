#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <stdarg.h>
#include "liblist_type.h"

static inline void init_list(struct iris_list_head *head)
{
    head->length = 0;
    head->size = 0;
    head->data.i = NULL;
}

int iris_list_resize(struct iris_list_head *head, int newsize, int unit)
{
    int new_allocated;

    new_allocated = (newsize >> 3) + (newsize < 9 ? 3 : 6);
    if (new_allocated * unit > IRIS_SIZE_MAX - newsize * unit) {
        errno = -ENOMEM;
        return errno;
    } else
        new_allocated += newsize;

    head->data.i = realloc(head->data.i, new_allocated * unit);

    if (head->data.i == NULL)
        return errno;

    head->size = new_allocated;
    return 0;
}

struct iris_list_head *__new_list()
{
    struct iris_list_head *head;

    head = malloc(sizeof(struct iris_list_head));
    init_list(head);

    if (head == NULL)
        return NULL;


    return head;
}

int __append1(struct iris_list_head **head, int unit)
{
    int err = 0;

    if (*head == NULL)
        *head = __new_list();

    if (*head == NULL)
        return errno;

    if ((*head)->size < (*head)->length + 1)
        err = iris_list_resize(*head, (*head)->length + 1, unit);

    return err;
}

struct iris_list_head *append_int(struct iris_list_head *head, int num, ...)
{
    int err, i, value;
    va_list valist;

    va_start(valist, num);
    for (i = 0; i < num; i++) {
        value = va_arg(valist, int);
        err = __append1(&head, sizeof(int));
        if (err)
            perror("IRIs error: ");

        memcpy(&(head->data.i[head->length]),
                                 &value, sizeof(int));
        head->length += 1;
    }
    va_end(valist);

    return head;
}

struct iris_list_head *append_double(struct iris_list_head *head, int num, ...)
{
    int err, i;
    double value;
    va_list valist;

    va_start(valist, num);
    for (i = 0; i < num; i++) {
        value = va_arg(valist, double);
        err = __append1(&head, sizeof(double));
        if (err)
            perror("IRIs error: ");

        memcpy(&(head->data.f[head->length]),
                                 &value, sizeof(double));
        head->length += 1;
    }
    va_end(valist);

    return head;
}

struct iris_list_head *append_char(struct iris_list_head *head, int num, ...)
{
    int err, i;
    char value;
    va_list valist;

    va_start(valist, num);
    for (i = 0; i < num; i++) {
        value = va_arg(valist, int);
        err = __append1(&head, sizeof(char));
        if (err)
            perror("IRIs error: ");

        memcpy(&(head->data.c[head->length]),
                                 &value, sizeof(char));
        head->length += 1;
    }
    va_end(valist);

    return head;
}

struct iris_list_head *new_int(int num, ...)
{
    int err, i, value;
    struct iris_list_head *head = NULL;
    va_list valist;

    va_start(valist, num);
    for (i = 0; i < num; i++) {
        value = va_arg(valist, int);
        err = __append1(&head, sizeof(int));
        if (err)
            perror("IRIs error: ");

        memcpy(&(head->data.i[head->length]),
                                 &value, sizeof(int));
        head->length += 1;
    }
    va_end(valist);

    return head;
}

struct iris_list_head *new_double(int num, ...)
{
    int err, i;
    double value;
    struct iris_list_head *head = NULL;
    va_list valist;

    va_start(valist, num);
    for (i = 0; i < num; i++) {
        value = va_arg(valist, double);
        err = __append1(&head, sizeof(double));
        if (err)
            perror("IRIs error: ");

        memcpy(&(head->data.f[head->length]),
                                 &value, sizeof(double));
        head->length += 1;
    }
    va_end(valist);

    return head;
}

struct iris_list_head *new_char(int num, ...)
{
    int err, i, value;
    struct iris_list_head *head = NULL;
    va_list valist;

    va_start(valist, num);
    for (i = 0; i < num; i++) {
        value = va_arg(valist, int);
        err = __append1(&head, sizeof(char));
        if (err)
            perror("IRIs error: ");

        memcpy(&(head->data.c[head->length]),
                                 &value, sizeof(char));
        head->length += 1;
    }
    va_end(valist);

    return head;
}
// struct iris_list_head *append_string(struct iris_list_head *head, char *value)
// {
//     int err;

//     err = __append1(&head, &value, sizeof(char) * (strlen(value) + 1));
//     if (err)
//         perror("IRIs error: ");

//     return head;
// }

