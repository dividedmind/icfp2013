#ifndef BV_H
#define BV_H

#include <stdint.h>

#define BV_0 0
#define BV_1 1
#define BV_X 2
#define BV_Y 3
#define BV_Z 4
#define BV_NOT 5
#define BV_SHL1 6
#define BV_SHR1 7
#define BV_SHR4 8
#define BV_SHR16 9
#define BV_AND 0xA
#define BV_OR 0xB
#define BV_XOR 0xC
#define BV_PLUS 0xD
#define BV_IF0 0xE
#define BV_FOLD 0xF

typedef struct {
  __int128 code;
  int16_t size;
} bv_expr;

#define BV_0_MASK 1
#define BV_1_MASK 2
#define BV_X_MASK 4
#define BV_Y_MASK 8
#define BV_Z_MASK 0x10
#define BV_NOT_MASK 0x20
#define BV_SHL1_MASK 0x40
#define BV_SHR1_MASK 0x80
#define BV_SHR4_MASK 0x100
#define BV_SHR16_MASK 0x200
#define BV_AND_MASK 0x400
#define BV_OR_MASK 0x800
#define BV_XOR_MASK 0x1000
#define BV_PLUS_MASK 0x2000
#define BV_IF0_MASK 0x4000
#define BV_FOLD_MASK 0x8000
#define BV_TFOLD_MASK 0x10000
#define BV_BONUS_MASK 0x20000

#define BV_OPS_MASK 0xffe0 // only plain ops
#define BV_BASE_MASK 0x7 // constants + x
#define BV_BASET_MASK 0x1b // constants + yz

typedef int64_t bv_mask;

typedef struct {
  int16_t size;
  bv_mask ops;
  char id[32];
} bv_problem;

typedef struct {
  uint64_t input;
  uint64_t output;
} bv_example;

#endif
