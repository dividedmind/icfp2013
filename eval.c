#include "bv.h"

/*
 * eats used bytes from bv_code
 * sets size to -1 if it's bad
 */
int16_t bv_eval(bv_expr *prog, uint64_t x, uint64_t y, uint64_t z)
{
  if (prog->size < 1) goto bad;
  
  uint8_t op = prog->code & 0xf;
  prog->code >>= 4;
  prog->size--;
  
  switch (op) {
    case BV_0:
      return 0;
    case BV_1:
      return 1;
    case BV_X:
      return x;
    case BV_Y:
      return y;
    case BV_Z:
      return z;
    case BV_NOT:
      return ~bv_eval(prog, x, y, z);
    case BV_SHL1:
      return bv_eval(prog, x, y, z) << 1;
    case BV_SHR1:
      return bv_eval(prog, x, y, z) >> 1;
    case BV_SHR4:
      return bv_eval(prog, x, y, z) >> 4;
    case BV_SHR16:
      return bv_eval(prog, x, y, z) >> 16;
    case BV_AND:
      return bv_eval(prog, x, y, z) & bv_eval(prog, x, y, z);
    case BV_OR:
      return bv_eval(prog, x, y, z) | bv_eval(prog, x, y, z);
    case BV_XOR:
      return bv_eval(prog, x, y, z) ^ bv_eval(prog, x, y, z);
    case BV_PLUS:
      return bv_eval(prog, x, y, z) + bv_eval(prog, x, y, z); // relies on wrapping plus
    case BV_IF0:
    {
      uint64_t cond = bv_eval(prog, x, y, z);
      uint64_t ifzero = bv_eval(prog, x, y, z);
      uint64_t otherwise = bv_eval(prog, x, y, z);
      return cond ? otherwise : ifzero;
    }
    case BV_FOLD:
    {
      prog->size--;
      uint64_t expr = bv_eval(prog, x, y, z);
      uint64_t acc = bv_eval(prog, x, y, z);
      for (int i = 0; i < 8; i++) { // will the compiler unroll?
        bv_expr inner = *prog;
        acc = bv_eval(&inner, x, expr & 0xf, acc);
        expr >>= 8;
      }
      bv_eval(prog, x, y, z); // just eat it
      return acc;
    }
    default:
    bad:
      prog->size = -1;
      return 0;
  };
}
