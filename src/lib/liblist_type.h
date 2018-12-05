#ifndef _LIBLIST_TYPE_H
#define _LIBLIST_TYPE_H

#define LIST_POISON1  ((void *) 0x100)
#define LIST_POISON2  ((void *) 0x200)

struct list_head {
    struct list_head *next, *prev;
};

struct iris_list_node {
    union data {
        int i;
        float f;
        char *str;
        struct iris_list_node *p;
    };

};

#endif