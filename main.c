#include <stdio.h>

#include "eval.h"

int main(int argc, char **argv)
{
  bv_expr code = { 2, 1 };
  printf("%d\n", bv_eval(&code, 2, 3, 4));
  return 0;
}
