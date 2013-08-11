#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#include "webapi.h"
#include "gen.h"
#include "print.h"

#define MAX_EXAMPLES 1024

// retuns zero im solved
static int solve_problem(bv_problem prob)
{
  if (prob.size == 0)
    return -20;
  
  bv_example examples[MAX_EXAMPLES];
  int excount = 0;
  int ret = -10;

  while (excount < MAX_EXAMPLES) {
    bv_expr sol = gen_solution(prob, examples, excount);
    if ((ret = guess_solution(prob, sol, examples + excount)) > 0)
      excount++;
    else
      break;
  }
  
  if (excount == MAX_EXAMPLES)
    puts("couldn't solve!!");
  
  return ret;
}

static void usage()
{
  puts("Usage: solve [-a] [size]\n"
  "\t-a -- automatically solve available problems\n"
  "\tsize -- max size or size of training problem\n\n"
  "Without arguments reads JSON problem spec from stdin.");
  exit(10);
}

int main(int argc, char **argv)
{
  srand(time(NULL));

  if (argc == 2) {
    int size = atoi(argv[1]);
    if (size) {
      if (solve_problem(get_training_problem(size)))
        exit(1);
    } else
      usage();
  } else if (argc == 3) {
    if (strcmp(argv[1], "-a") != 0) 
      usage();
    int size = atoi(argv[2]);
    if (size)
      ;//autosolve(size);
    else
      usage();
  } else {
    puts("Enter a problem: ");
    char BUF[1024];
    if (!fgets(BUF, 1024, stdin)) {
      puts("Error reading problem!");
      exit(11);
    } else if(solve_problem(parse_problem(BUF)))
      exit(1);
  }
  
  return 0;
}
