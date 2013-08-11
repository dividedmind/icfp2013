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
  char tfold = (problem.ops & BV_TFOLD_MASK) > 0;
  if ((problem.ops & BV_FOLD_MASK) > 0)
    problem.size--;
  
  bv_mask allowed_ops, needed_ops;
  
  if (tfold) {
    allowed_ops = (problem.ops & BV_OPS_MASK) | BV_BASET_MASK;
    needed_ops = (problem.ops & BV_OPS_MASK);
    problem.size -= 4;
  } else {
    allowed_ops = (problem.ops & BV_OPS_MASK) | BV_BASE_MASK;
    needed_ops = (problem.ops & BV_OPS_MASK) | BV_X_MASK;
  }

  bv_expr sol;
  
  int total = 0;
  for(;;) {
    bv_mask allowed;
    start:
    allowed = allowed_ops;
    
    sol.code = 0;
    sol.size = problem.size;
    int size_left = problem.size;
    int depth = 1;
    int zdepth = -3, foldtrips = 0;
    while (size_left) {
      if (depth < 1)
        goto start;
      int op = rand() & 0xf;
      bv_mask mask = 1ull << op;
      if (!(mask & allowed))
        continue;
      if (size_left < 2 && (mask & BV_SIZE2_MASK))
        continue;
      if (size_left < 3 && (mask & BV_SIZE3_MASK))
        continue;
      if (size_left < 4 && (mask & BV_SIZE4_MASK))
        continue;
      sol.code |= 1ull * op << ((problem.size - size_left) * 4);
      size_left--;
      if (op == BV_FOLD) {
        allowed &= ~BV_FOLD_MASK;
        zdepth = depth;
      }
      switch(op) {
        case BV_0:
        case BV_1:
        case BV_X:
        case BV_Y:
        case BV_Z:
          depth--;
        case BV_NOT:
        case BV_SHL1:
        case BV_SHR1:
        case BV_SHR4:
        case BV_SHR16:
          break;
        case BV_IF0:
        case BV_FOLD:
          depth++;
        case BV_AND:
        case BV_OR:
        case BV_XOR:
        case BV_PLUS:
          depth++;
      };
      if (depth == zdepth)
        allowed |= BV_Z_MASK | BV_Y_MASK;
      if (depth < zdepth) {
        allowed &= ~(BV_Z_MASK | BV_Y_MASK);
        zdepth = -3;
      }
    }
    
    if (tfold) {
      sol.code = (sol.code << 12) | 0x02f; // fold x 0
      sol.size += 3;
    }
    
    if (excount == 0 && !bv_eval_program(sol, 10, NULL)) continue;

    fprintf(stderr, "Tries: %d\r", total++);
    
    char ok = 1;
    for (unsigned int i = 0; i < excount; i++) {
      uint64_t result;
      if (!bv_eval_program(sol, examples[i].input, &result) || result != examples[i].output) {
        ok = 0;
        break;
      }
    }
    
    if (!ok) continue;
    
    return sol;
  }
}
