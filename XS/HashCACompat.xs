#include "ppport.h"

#include "cxsa_util_macros.h"

MODULE = Class::XSAccessor        PACKAGE = Class::XSAccessor
PROTOTYPES: DISABLE

void
ca_getter_init(self)
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
    CXAH_OPTIMIZE_ENTERSUB(ca_getter);
    if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
      PUSHs(*svp);
    else {
      SV * sv;
      CXSA_CALL_GET_METHOD(readfrom.key, readfrom.len);
      svp = hv_store((HV *)SvRV(self), readfrom.key, readfrom.len, sv, readfrom.hash);
      PUSHs(sv);
    }

void
ca_getter(self)
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
      hv_store((HV *)SvRV(self), readfrom.key, readfrom.len, sv, readfrom.hash);
      PUSHs(sv);
    }

void
newxs_ca_getter(name, key)
  char* name;
  char* key;
  PPCODE:
    /* WARNING: If this is called in your code, you're doing it WRONG! */
    INSTALL_NEW_CV_HASH_OBJ(name, CXAH(ca_getter_init), key);

