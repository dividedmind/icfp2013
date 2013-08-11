#include <stdio.h>

#include "webapi.h"
#include "gen.h"
#include "print.h"

int main(int argc, char **argv)
{
  bv_problem prob = get_training_problem(5);
  printf("%x %lx\n", prob.size, prob.ops);
  
  if (prob.ops >= BV_FOLD_MASK) {
    puts("can't handle folds yet");
    return 0;
  }

  bv_example examples[1024];
  int excount = 0;

  while (excount < 1024) {
    bv_expr sol = gen_solution(prob, examples, excount);
    if (guess_solution(prob, sol, examples + excount) > 0)
      excount++;
    else
      break;
  }
  
  return 0;
}
