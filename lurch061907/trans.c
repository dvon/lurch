#include "lurch.h"
#define _FALSE 0
#define _TRUE 1

enum { _IN, _OUT };


void _before_all(void) {}
void _before(void) {}
void _before_each(void) {}
void _score(void) {}
void _after_all(void) {}
void _after(void) {}
void _after_each(void) {}
void _hash(unsigned int *h) {}
void _print(char *c) { *c = '\0'; }
void _tr_incr(_Tran *tr) {}
int _in(int and) { return _trans(and, _IN); }
int _out(int and) { return _trans(and, _OUT); }
int _trans(int and, int caller)
{
  switch (and)
    {
      default : return _TRUE;
    }
}
