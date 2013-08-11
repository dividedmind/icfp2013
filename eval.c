#include "bv.h"

/*
 * eats used bytes from bv_code
 * sets size to -1 if it's bad
 */
uint64_t bv_eval(bv_expr *prog, uint64_t x)
{
  uint64_t y = 0, z = 0;
  uint64_t stack[64];
  int top = -1;
  int size = prog->size;
  
  while (size > 0) {
    char op = (prog->code >> ((size - 1) * 4)) & 0xf;
    size--;
    
    switch (op) {
      case BV_0:
        stack[++top] = 0;
        continue;
      case BV_1:
        stack[++top] = 1;
        continue;
      case BV_X:
        stack[++top] = x;
        continue;
      case BV_Y:
        stack[++top] = y;
        continue;
      case BV_Z:
        stack[++top] = z;
        continue;
      case BV_NOT:
        stack[top] = ~stack[top];
        continue;
      case BV_SHL1:
        stack[top] <<= 1;
        continue;
      case BV_SHR1:
        stack[top] >>= 1;
        continue;
      case BV_SHR4:
        stack[top] >>= 4;
        continue;
      case BV_SHR16:
        stack[top] >>= 16;
        continue;
      case BV_AND:
        top--;
        stack[top] &= stack[top + 1];
        continue;
      case BV_OR:
        top--;
        stack[top] |= stack[top + 1];
        continue;
      case BV_XOR:
        top--;
        stack[top] ^= stack[top + 1];
        continue;
      case BV_PLUS:
        top--;
        stack[top] += stack[top + 1];
        continue;
      case BV_IF0:
        top -= 2;
        stack[top] = stack[top + 2] ? stack[top] : stack[top + 1];
        continue;
      default:
        goto bad;
    };
  };

  if (top == 0)
    return stack[top];
  
bad:
  prog->size = -1;
  return 0;
}

char bv_eval_program(bv_expr prog, uint64_t arg, uint64_t *result)
{
  int start_size = prog.size;
  
  uint64_t res = bv_eval(&prog, arg);
  
  if (prog.size == -1) return 0;
  
  if (result) *result = res;
  return 1;
}
