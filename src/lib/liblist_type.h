#ifndef _LIBLIST_TYPE_H
#define _LIBLIST_TYPE_H

#define LIST_POISON1    ((void *) 0x100)
#define LIST_POISON2    ((void *) 0x200)
#define IRIS_SIZE_MAX   0x10000

struct iris_list_head *append_int(struct iris_list_head *head, int value);
struct iris_list_head *append_double(struct iris_list_head *head, double value);
struct iris_list_head *append_char(struct iris_list_head *head, char value);


struct list_head {
    struct list_head *prev, *next;
};

struct iris_list_head {
    union data {
        int *i;
        double *f;
        char *c;
        char **s;
        struct iris_list_node *p;
    } data;
    int length;
    int size;
};

#endif