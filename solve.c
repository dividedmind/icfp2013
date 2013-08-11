#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <signal.h>

#include "webapi.h"
#include "gen.h"
#include "print.h"
#include "gene.h"

#define MAX_EXAMPLES 1024

static int finish = 0;

static void int_handler(int __attribute__((unused)) sig)
{
  puts("Finishing after next one...");
  finish = 1;
}

// retuns zero im solved
// negative on error
// positive on couldn't solve
static int solve_problem(bv_problem prob)
{
  if (prob.size == 0)
    return -20;
  
  printf("Problem %s, size %d, ops 0x%lx\n", prob.id, prob.size, prob.ops);
  time_t start_time = time(NULL);

  population_t *population = make_population(prob);
  
  int ret;
  for (;;) {
    bv_expr sol = get_best(population);
    bv_example ex;
    if ((ret = guess_solution(prob, sol, &ex)) > 0)
      evolve_population(population, ex);
    else if (ret != -42) // try again on "error"
      break;
  }
  
  printf("%ld seconds.\n\n", time(NULL) - start_time);
  
  free(population);
  
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

// zero == all ok
int autosolve(int max_size)
{
  bv_problem * problems = get_myproblems(1);
  if (!problems) return -2;
  
  for (bv_problem * prob = problems; prob->size <= max_size && prob->size != 0; prob++) {
    int res;
    if ((res = solve_problem(*prob)) > 0)
      return res;
    if (finish)
      return 0;
  }
  
  return 0;
}

int main(int argc, char **argv)
{
  srand(time(NULL));
  signal(SIGINT, int_handler);

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
      return autosolve(size);
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
