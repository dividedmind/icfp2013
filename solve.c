#include <stdio.h>

#include "webapi.h"
#include "gen.h"
#include "print.h"

int main(int argc, char **argv)
{
  bv_problem prob = get_training_problem(10);
  printf("%x %lx\n", prob.size, prob.ops);
  
  if (prob.ops >= BV_FOLD_MASK) {
    puts("can't handle folds yet");
    return 0;
  }
  
  bv_expr sol = gen_solution(prob);
  bv_example ex;
  if (guess_solution(prob, sol, &ex) > 0)
    printf("Counterexample: %lx -> %lx\n", ex.input, ex.output);
  
  return 0;
}
