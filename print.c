#include <string.h>

#include "print.h"

// don't use in production, security bug
// buffer of > 300 bytes recommended
char * bv_print(bv_expr *expr, char * buf)
{
  if (expr->size < 1) goto bad;
  
  uint8_t op = expr->code & 0xf;
  expr->code >>= 4;
  expr->size--;
  
  switch (op) {
    case BV_0:
      *buf = '0';
      return buf + 1;
    case BV_1:
      *buf = '1';
      return buf + 1;
    case BV_X:
      *buf = 'x';
      return buf + 1;
    case BV_Y:
      *buf = 'y';
      return buf + 1;
    case BV_Z:
      *buf = 'z';
      return buf + 1;
    case BV_NOT:
      memcpy(buf, "(not ", 5);
      buf = bv_print(expr, buf + 5);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      return buf;
    case BV_SHL1:
      memcpy(buf, "(shl1 ", 6);
      buf = bv_print(expr, buf + 6);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      return buf;
    case BV_SHR1:
      memcpy(buf, "(shr1 ", 6);
      buf = bv_print(expr, buf + 6);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      return buf;
    case BV_SHR4:
      memcpy(buf, "(shr4 ", 6);
      buf = bv_print(expr, buf + 6);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      return buf;
    case BV_SHR16:
      memcpy(buf, "(shr16 ", 7);
      buf = bv_print(expr, buf + 7);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      return buf;
    case BV_AND:
      memcpy(buf, "(and ", 5);
      buf = bv_print(expr, buf + 5);
      if (buf == NULL) goto bad;
      *(buf++) = ' ';
      buf = bv_print(expr, buf);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      return buf;
    case BV_OR:
      memcpy(buf, "(or ", 4);
      buf = bv_print(expr, buf + 4);
      if (buf == NULL) goto bad;
      *(buf++) = ' ';
      buf = bv_print(expr, buf);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      return buf;
    case BV_XOR:
      memcpy(buf, "(xor ", 5);
      buf = bv_print(expr, buf + 5);
      if (buf == NULL) goto bad;
      *(buf++) = ' ';
      buf = bv_print(expr, buf);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      return buf;
    case BV_PLUS:
      memcpy(buf, "(plus ", 6);
      buf = bv_print(expr, buf + 6);
      if (buf == NULL) goto bad;
      *(buf++) = ' ';
      buf = bv_print(expr, buf);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      return buf;
    case BV_IF0:
      memcpy(buf, "(if0 ", 5);
      buf = bv_print(expr, buf + 5);
      if (buf == NULL) goto bad;
      *(buf++) = ' ';
      buf = bv_print(expr, buf);
      if (buf == NULL) goto bad;
      *(buf++) = ' ';
      buf = bv_print(expr, buf);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      return buf;
    case BV_FOLD:
      memcpy(buf, "(fold ", 6);
      buf = bv_print(expr, buf + 6);
      if (buf == NULL) goto bad;
      *(buf++) = ' ';
      buf = bv_print(expr, buf);
      if (buf == NULL) goto bad;
      *(buf++) = ' ';
      memcpy(buf, "(lambda (y z) ", 14);
      buf = bv_print(expr, buf + 14);
      if (buf == NULL) goto bad;
      *(buf++) = ')';
      *(buf++) = ')';
      return buf;
    default:
    bad:
      return NULL;
  };
}

char * bv_print_program(bv_expr prog)
{
  static char buf[1024] = "(lambda (x) ";
  
  char * fin = bv_print(&prog, buf + 12);
  if (fin == NULL) return "bad program";
  
  *(fin++) = ')';
  *fin = 0;
  return buf;
}
