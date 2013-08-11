#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "gen.h"
#include "eval.h"

// returns nonzero on failure
static char check_ops(bv_expr expr, bv_mask allowed, bv_mask needed)
{
  if (allowed >= BV_FOLD_MASK) {
    puts("folds not handled yet");
    return -1;
  }
  
  for (int i = 0; i < expr.size; i++) {
    bv_mask mask = 1 << (expr.code & 0xf);
    if (!(mask & allowed))
      return -2;
    needed &= ~mask;
    expr.code >>= 4;
  }
  
  if (needed)
    return -3;
  return 0;
}

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
    if (check_ops(sol, allowed_ops, needed_ops)) continue;

    sol.size++;
    
    return sol;
  }
}
