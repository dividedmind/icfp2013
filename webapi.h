#ifndef WEBAPI_H
#define WEBAPI_H

#include "bv.h"

bv_problem get_training_problem(int size);

bv_problem parse_problem(const char * json);

// positive on mismatch, negative on error
char guess_solution(bv_problem problem, bv_expr solution, bv_example *ex);

// freshly allocated list, terminated with size 0
// sorted by size asc
bv_problem * get_myproblems(int only_unsolved);

#endif
