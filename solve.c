#include <stdio.h>

#include "webapi.h"

int main(int argc, char **argv)
{
  bv_problem prob = get_training_problem(6);
  
  printf("%x %lx\n", prob.size, prob.ops);
  
  return 0;
}
