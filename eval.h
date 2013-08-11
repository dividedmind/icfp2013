#ifndef EVAL_H
#define EVAL_H

#include "bv.h"

uint64_t bv_eval(bv_expr *code, uint64_t x, uint64_t y, uint64_t z);

// returns real size or 0 on error (or oversize)
// result can be NULL (useful for checking)
char bv_eval_program(bv_expr prog, uint64_t arg, uint64_t *result);

#endif
