#ifndef GENE_H
#define GENE_H

#include "bv.h"

typedef struct {
  bv_expr solution;
  int64_t score;
} genotype_t;

#define POP_SIZE 1024
#define ENV_SIZE 1024

typedef struct {
  genotype_t members[POP_SIZE];
  bv_example examples[ENV_SIZE];
  size_t example_count;
} population_t;

// free normally
population_t *make_population(bv_problem problem);
void evolve_population(population_t *population, bv_example example);
bv_expr get_best(population_t *population);

#endif
