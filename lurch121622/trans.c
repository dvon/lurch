#include "lurch.h"
#define _FALSE 0
#define _TRUE 1

enum { _IN, _OUT };

int lk = 0, r_want = 0, r_lock = 0, sleep_q = 0;
enum { Wakeme, Running } State = Running;

void _before()
{
  lk = r_want = r_lock = sleep_q = 0;
  State = Running;
}

void _hash(unsigned int *h)
{
  _hash_int(lk, h);
  _hash_int(r_want, h);
  _hash_int(r_lock, h);
  _hash_int(sleep_q, h);
  _hash_int(State, h);
}

void _print(char *tmp)
{
  sprintf(tmp, "   lk = %i\n", lk);
  sprintf(&tmp[strlen(tmp)], "   r_want = %i\n", r_want);
  sprintf(&tmp[strlen(tmp)], "   r_lock = %i\n", r_lock);
  sprintf(&tmp[strlen(tmp)], "   sleep_q = %i\n", sleep_q);

  State == Wakeme ?
    sprintf(&tmp[strlen(tmp)], "   State = Wakeme\n") :
    sprintf(&tmp[strlen(tmp)], "   State = Running\n");
}

void _before_all(void) {}
/* void _before(void) {} */
void _before_each(void) {}
void _score(void) {}
void _after_all(void) {}
void _after(void) {}
void _after_each(void) {}
/* void _hash(unsigned int *h) {} */
/* void _print(char *c) { *c = '\0'; } */
void _tr_incr(_Tran *tr) {}
int _in(int and) { return _trans(and, _IN); }
int _out(int and) { return _trans(and, _OUT); }
int _trans(int and, int caller)
{
  switch (and)
    {
      case 1 :
        if (caller == _IN) return (lk == 0);
        if (caller == _OUT) {lk = 1;} return _TRUE;
      case 2 :
        if (caller == _IN) return _TRUE;
        if (caller == _OUT) {r_want = 1;} return _TRUE;
      case 3 :
        if (caller == _IN) return _TRUE;
        if (caller == _OUT) {State = Wakeme;} return _TRUE;
      case 4 :
        if (caller == _IN) return _TRUE;
        if (caller == _OUT) {lk = 0;} return _TRUE;
      case 5 :
        if (caller == _IN) return (State == Running);
        if (caller == _OUT) return _TRUE;
      case 6 :
        if (caller == _IN) return (r_lock == 1);
        if (caller == _OUT) return _TRUE;
      case 7 :
        if (caller == _IN) return (r_lock == 0);
        if (caller == _OUT) return _TRUE;
      case 8 :
        if (caller == _IN) return (r_lock == 0);
        if (caller == _OUT) return _TRUE;
      case 9 :
        if (caller == _IN) return (r_lock != 0);
        if (caller == _OUT) return _TRUE;
      case 10 :
        if (caller == _IN) return _TRUE;
        if (caller == _OUT) {r_lock = 1;} return _TRUE;
      case 11 :
        if (caller == _IN) return _TRUE;
        if (caller == _OUT) {lk = 0;} return _TRUE;
      case 12 :
        if (caller == _IN) return _TRUE;
        if (caller == _OUT) {r_lock = 0;} return _TRUE;
      case 13 :
        if (caller == _IN) return (lk == 0);
        if (caller == _OUT) return _TRUE;
      case 14 :
        if (caller == _IN) return (sleep_q == 0);
        if (caller == _OUT) {sleep_q = 1;} return _TRUE;
      case 15 :
        if (caller == _IN) return _TRUE;
        if (caller == _OUT) {r_want = 0;} return _TRUE;
      case 16 :
        if (caller == _IN) return _TRUE;
        if (caller == _OUT) {State = Running;} return _TRUE;
      case 17 :
        if (caller == _IN) return (State == Wakeme);
        if (caller == _OUT) return _TRUE;
      case 18 :
        if (caller == _IN) return (State != Wakeme);
        if (caller == _OUT) return _TRUE;
      case 19 :
        if (caller == _IN) return _TRUE;
        if (caller == _OUT) {sleep_q = 0;} return _TRUE;
      case 20 :
        if (caller == _IN) return (r_want == 1);
        if (caller == _OUT) return _TRUE;
      case 21 :
        if (caller == _IN) return (r_want != 1);
        if (caller == _OUT) return _TRUE;
      default : return _TRUE;
    }
}
