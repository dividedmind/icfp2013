#ifndef WEBAPI_H
#define WEBAPI_H

#include "bv.h"

bv_problem get_training_problem(int size);

// positive on mismatch, negative on error
char guess_solution(bv_problem problem, bv_expr solution, bv_example *ex);

#endif
