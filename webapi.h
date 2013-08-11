#ifndef WEBAPI_H
#define WEBAPI_H

#include "bv.h"

bv_problem get_training_problem(int size);
void guess_solution(bv_problem problem, bv_expr solution);

#endif
