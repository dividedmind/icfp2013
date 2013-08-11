#include <stdio.h>

#include "webapi.h"
#include "gen.h"
#include "print.h"

int main(int argc, char **argv)
{
  bv_problem prob;
  prob.size = 6;
  prob.ops = 0x2000;
  
  if (prob.ops >= BV_FOLD_MASK) {
    puts("can't handle folds yet");
    return 0;
  }
  
  bv_expr sol = gen_solution(prob);
  puts(bv_print_program(sol));
  
  return 0;
}
