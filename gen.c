#include <stdlib.h>
#include <time.h>

#include "gen.h"
#include "eval.h"

bv_expr gen_solution(bv_problem problem)
{
  bv_mask allowed_ops = (problem.ops & BV_OPS_MASK) | BV_BASE_MASK;
  bv_mask needed_ops = (problem.ops & BV_OPS_MASK) | BV_X_MASK;

  bv_expr sol;
  
  srandom(time(NULL));
  
  for(;;) {
    sol.size = problem.size - 1;
    sol.code = random();
    
    if ((sol.size = bv_eval_program(sol, 0, NULL)) == 0) continue;

    sol.size++;
    
    return sol;
  }
}
