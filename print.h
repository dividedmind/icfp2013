#ifndef PRINT_H
#define PRINT_H

#include "bv.h"

char * bv_print(bv_expr *expr, char * buf);
char * bv_print_program(bv_expr prog);

#endif
