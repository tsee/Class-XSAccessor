#include "ppport.h"

#include "cxsa_util_macros.h"

MODULE = Class::XSAccessor        PACKAGE = Class::XSAccessor
PROTOTYPES: DISABLE

void
cached_getter_init(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
    SV** svp;
  PPCODE:
    CXA_CHECK_HASH(self);
    CXAH_OPTIMIZE_ENTERSUB(cached_getter);
    if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
      PUSHs(*svp);
    else {
      SV * sv;
      CXSA_CALL_GET_METHOD(readfrom.key, readfrom.len);
      svp = hv_store((HV *)SvRV(self), readfrom.key, readfrom.len, sv, readfrom.hash);
      PUSHs(sv);
    }

void
cached_getter(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
    SV** svp;
  PPCODE:
    CXA_CHECK_HASH(self);
    if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
      PUSHs(*svp);
    else {
      SV * sv;
      CXSA_CALL_GET_METHOD(readfrom.key, readfrom.len);
      svp = hv_store((HV *)SvRV(self), readfrom.key, readfrom.len, sv, readfrom.hash);
      PUSHs(sv);
    }

void
cached_accessor_init(self, ...)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
    SV** svp;
  PPCODE:
    CXA_CHECK_HASH(self);
    CXAH_OPTIMIZE_ENTERSUB(cached_accessor);
    if (items > 1) {
      SV* newvalue = ST(1);
      CXSA_CALL_SET_METHOD(readfrom.key, readfrom.len, newvalue);
      PUSHs(newvalue);
    }
    else {
      if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
        PUSHs(*svp);
      else {
        SV * sv;
        CXSA_CALL_GET_METHOD(readfrom.key, readfrom.len);
        svp = hv_store((HV *)SvRV(self), readfrom.key, readfrom.len, sv, readfrom.hash);
        PUSHs(sv);
      }
    }

void
cached_accessor(self, ...)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
    SV** svp;
  PPCODE:
    CXA_CHECK_HASH(self);
    if (items > 1) {
      SV* newvalue = ST(1);
      CXSA_CALL_SET_METHOD(readfrom.key, readfrom.len, newvalue);
      PUSHs(newvalue);
    }
    else {
      if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
        PUSHs(*svp);
      else {
        SV * sv;
        CXSA_CALL_GET_METHOD(readfrom.key, readfrom.len);
        svp = hv_store((HV *)SvRV(self), readfrom.key, readfrom.len, sv, readfrom.hash);
        PUSHs(sv);
      }
    }

## Note that the newxs_* functions live in Hash.xs as
## ALIASes of the newxs_* functions there

