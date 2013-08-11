#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "webapi.h"
#include "gen.h"
#include "print.h"

int main(int argc, char **argv)
{
  srand(time(NULL));

  int size = 10;
  if (argc == 2)
    size = atoi(argv[1]);
  
  bv_problem prob;
  if (size) 
    prob = get_training_problem(size);
  else {
    char BUF[1024];
    gets(BUF);
    prob = parse_problem(BUF);
  }
  printf("%x %lx\n", prob.size, prob.ops);
  
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
