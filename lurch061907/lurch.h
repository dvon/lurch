#include <stdio.h>

#include <limits.h>
#include <math.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define _FALSE 0
#define _TRUE 1
#define _MAX_NAME 256
#define _MAX_PRINT 256
#define _CE_DIR "ce"
#define _GSTALL_SIZE 1024
#define _PROG_STATS 1
#define _LAST_STATS 0

typedef struct _State
{
  char *c;
  int m, s;
  struct _State *next;
} _State;

typedef struct _Sptr
{
  _State *st;
  struct _Sptr *next;
} _Sptr;

typedef struct _Tran
{
  _State *par, *kid;
  _Sptr *in, *out;
  int id, nv, wt, bias, tb;
  float ct, qwt;
  struct _Tran *next;
} _Tran;

typedef struct _Tptr
{
  _Tran *tr;
  struct _Tptr *next;
} _Tptr;

typedef struct _Flt
{
  char name[_MAX_NAME];
  unsigned int h;
  unsigned int seed;
  int len, depth, iter, times;
  struct _Flt *next;
} _Flt;

typedef struct _Gstate
{
  unsigned int h;
  int depth;
  int n;
  struct _Gstate *left;
  struct _Gstate *right;
} _Gstate;

typedef struct _Hptr
{
  unsigned int h;
#ifdef GS
  int i;
  int j;
#endif
  struct _Hptr *left;
  struct _Hptr *right;
} _Hptr;

typedef struct _Eptr
{
  unsigned int h;
  struct _Eptr *next;
} _Eptr;

void _hash_string(char *c, unsigned int *h);
void _hash_int(int i, unsigned int *h);

