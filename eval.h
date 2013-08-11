#ifndef EVAL_H
#define EVAL_H

#include "bv.h"

int16_t bv_eval(bv_expr *code, uint64_t x, uint64_t y, uint64_t z);

#endif
