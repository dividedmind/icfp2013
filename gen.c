#include <stdio.h>
#include <stdlib.h>

#include "gen.h"
#include "eval.h"
#include "print.h"

// returns nonzero on failure
static char check_ops(bv_expr expr, bv_mask allowed, bv_mask needed)
{
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

bv_expr gen_solution(bv_problem problem, bv_example *examples, size_t excount)
{
  problem.size--;
  
  bv_mask allowed_ops = (problem.ops & BV_OPS_MASK) | BV_BASE_MASK;
  bv_mask needed_ops = (problem.ops & BV_OPS_MASK) | BV_X_MASK;

  bv_expr sol;
  
  for(;;) {
    sol.size = 0;
    sol.code = 0;
    
    while (sol.size < problem.size) {
      char op = rand() & 0xf;
      if (!((1 << op) & allowed_ops)) continue;
      sol.code = (sol.code << 4) | op;
      sol.size++;
    }
    
    if (bv_eval_program(sol, 0, NULL) != sol.size) continue;
    if (check_ops(sol, allowed_ops, needed_ops)) continue;
    
    char ok = 1;
    for (unsigned int i = 0; i < excount; i++) {
      uint64_t result;
      bv_eval_program(sol, examples[i].input, &result);
      if (result != examples[i].output) {
        ok = 0;
        break;
      }
    }
    
    if (!ok) continue;
    
    return sol;
  }
}
