#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "eval.h"
#include "gen.h"

#include "gene.h"

population_t *make_population(bv_problem problem)
{
  population_t *pop = calloc(sizeof(population_t), 1);
  
#pragma omp parallel for
  for (int i = 0; i < POP_SIZE; i++)
    pop->members[i].solution = gen_solution(problem, NULL, 0);
  
  return pop;
}

static int bits_lit[256] = { 1 };

static void calculate_bitlits()
{
  for (int i = 0; i < 256; i++) {
    int a = i;
    bits_lit[i] = 0;
    while (a) {
      bits_lit[i] += a & 1;
      a >>= 1;
    }
  }
}

static int hamming_distance(uint64_t a, uint64_t b)
{
  if (bits_lit[0])
    calculate_bitlits();
  
  uint64_t diff = a ^ b;
  int dist = 0;
  while (diff) {
    dist += bits_lit[diff & 0xff];
    diff >>= 8;
  }
  return dist;
}

static int score_solution(bv_expr sol, population_t *pop)
{
  int score = 0;
  for (unsigned int i = 0; i < pop->example_count; i++) {
    uint64_t result;
    if (!bv_eval_program(sol, pop->examples[i].input, &result))
      return 64 * pop->example_count;
    score += hamming_distance(result, pop->examples[i].output);
  }
  return score;
}

static void score_population(population_t * pop)
{
#pragma omp parallel for
  for (int i = 0; i < POP_SIZE; i++)
    pop->members[i].score = score_solution(pop->members[i].solution, pop);
}

static int score_cmp(const void *_a, const void *_b)
{
  const genotype_t *a = _a, *b = _b;
  return a->score - b->score;
}

static int skewed_rand()
{
  return POP_SIZE * (1.0 - sqrt(1.0 * rand() / RAND_MAX));
}

static __int128 random_mask()
{
  __int128 result = 0;
  for (int i = 0; i < 5; i++) {
    result <<= 31;
    result |= lrand48();
  }
  return result;
}

void reproduce(population_t *pop)
{
  const int REP_COUNT = POP_SIZE >> 4;
  genotype_t newones[REP_COUNT];
  
#pragma omp parallel for
  for (int i =0; i < REP_COUNT; i++) {
    const genotype_t *a = &pop->members[skewed_rand()], *b  = &pop->members[skewed_rand()];
    __int128 mask = random_mask();
    newones[i].solution.size = a->solution.size;
    newones[i].solution.code = (a->solution.code & mask) | (b->solution.code & ~mask);
    int mutation = rand();
    if (mutation & 1) {
      mutation >>= 1;
      mask = 1ull << (mutation & 0x7f);
      if (mutation & 0x80)
        newones[i].solution.code |= mask;
      else
        newones[i].solution.code &= ~mask;
    }
    newones[i].score = score_solution(newones[i].solution, pop);
  }
  memcpy(pop->members + POP_SIZE - REP_COUNT, newones, sizeof(newones));
}

void evolve_population(population_t *population, bv_example example)
{
  population->examples[population->example_count++] = example;
  score_population(population);
  
  qsort(population->members, POP_SIZE, sizeof(genotype_t), score_cmp);
  while (population->members[0].score > 0)
    reproduce(population);
}

bv_expr get_best(population_t *population)
{
  return population->members[0].solution;
}
