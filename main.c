#include <stdio.h>

#include "eval.h"
#include "print.h"

int main(int argc, char **argv)
{
  bv_expr code = { 0x16666l, 6 };
  printf("%s\n", bv_print_program(code));
  return 0;
}
