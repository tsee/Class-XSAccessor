#ifndef _cxsa_memory_h_
#define _cxsa_memory_h_

#include "EXTERN.h"
/* for the STRLEN typedef, for better or for worse */
#include "perl.h"

/* these macros are really what you should be calling: */

#define cxa_free(ptr) Safefree(ptr)
#define cxa_malloc(v,n,t) Newx(v,n,t)
#define cxa_zmalloc(v,n,t) Newxz(v,n,t)
#define cxa_realloc(v,n,t) Renew(v,n,t)
#define cxa_memcpy(dest, src, n, t) Copy(src, dest, n, t)
#define cxa_memzero(ptr, n, t) Zero(ptr, n, t)

/* TODO: A function call on every memory operation seems expensive.
 *       Right now, it's not so bad and benchmarks show no harm done.
 *       The hit should really only matter during global destruction and
 *       BEGIN{} when accessors are set up.
 */

#endif
