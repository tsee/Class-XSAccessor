#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "AutoXS.h"

MODULE = Class::XSAccessor        PACKAGE = Class::XSAccessor

void
getter(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = AutoXS_hashkeys[ix];
    HE* he;
  PPCODE:
    /*if (he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, 0)) {*/
    if (he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash))
      XPUSHs(HeVAL(he));
    else
      XSRETURN_UNDEF;



void
setter(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = AutoXS_hashkeys[ix];
    HE* he;
  PPCODE:
    if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    XPUSHs(newvalue);


void
chained_setter(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = AutoXS_hashkeys[ix];
    HE* he;
  PPCODE:
    if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    XPUSHs(self);


void
accessor(self, ...)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = AutoXS_hashkeys[ix];
    HE* he;
  PPCODE:
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      XPUSHs(newvalue);
    }
    else {
      if (he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash))
        XPUSHs(HeVAL(he));
      else
        XSRETURN_UNDEF;
    }


void
chained_accessor(self, ...)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = AutoXS_hashkeys[ix];
    HE* he;
  PPCODE:
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      XPUSHs(self);
    }
    else {
      if (he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash))
        XPUSHs(HeVAL(he));
      else
        XSRETURN_UNDEF;
    }


void
predicate(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = AutoXS_hashkeys[ix];
    HE* he;
  PPCODE:
    if ( (he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash)) && SvOK(HeVAL(he)) )
       XSRETURN_YES;
    else
      XSRETURN_NO;


void
constructor(class, ...)
    SV* class;
  ALIAS:
  PREINIT:
    unsigned int iStack;
    HV* hash;
    SV* obj;
    const char* classname;
  PPCODE:
    if (sv_isobject(class)) {
      classname = sv_reftype(SvRV(class), 1);
    }
    else {
      if (!SvPOK(class))
        croak("Need an object or class name as first argument to the constructor.");
      classname = SvPV_nolen(class);
    }
    
    hash = (HV *)sv_2mortal((SV *)newHV());
    obj = sv_bless( newRV((SV*)hash), gv_stashpv(classname, 1) );

    if (items > 1) {
      if (!(items % 2))
        croak("Uneven number of argument to constructor.");

      for (iStack = 1; iStack < items; iStack += 2) {
        hv_store_ent(hash, ST(iStack), newSVsv(ST(iStack+1)), 0);
      }
    }
    XPUSHs(sv_2mortal(obj));


void
newxs_getter(name, key)
  char* name;
  char* key;
  PPCODE:
    char* file = __FILE__;
    const unsigned int functionIndex = get_next_hashkey();
    {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      cv = newXS(name, XS_Class__XSAccessor_getter, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
      XSANY.any_i32 = functionIndex;

      /* Precompute the hash of the key and store it in the global structure */
      autoxs_hashkey hashkey;
      const unsigned int len = strlen(key);
      hashkey.key = newSVpvn(key, len);
      PERL_HASH(hashkey.hash, key, len);
      AutoXS_hashkeys[functionIndex] = hashkey;
    }


void
newxs_setter(name, key, chained)
  char* name;
  char* key;
  bool chained;
  PPCODE:
    char* file = __FILE__;
    const unsigned int functionIndex = get_next_hashkey();
    {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      if (chained)
        cv = newXS(name, XS_Class__XSAccessor_chained_setter, file);
      else
        cv = newXS(name, XS_Class__XSAccessor_setter, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
      XSANY.any_i32 = functionIndex;

      /* Precompute the hash of the key and store it in the global structure */
      autoxs_hashkey hashkey;
      const unsigned int len = strlen(key);
      hashkey.key = newSVpvn(key, len);
      PERL_HASH(hashkey.hash, key, len);
      AutoXS_hashkeys[functionIndex] = hashkey;
    }


void
newxs_accessor(name, key, chained)
  char* name;
  char* key;
  bool chained;
  PPCODE:
    char* file = __FILE__;
    const unsigned int functionIndex = get_next_hashkey();
    {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      if (chained)
        cv = newXS(name, XS_Class__XSAccessor_chained_accessor, file);
      else
        cv = newXS(name, XS_Class__XSAccessor_accessor, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
      XSANY.any_i32 = functionIndex;

      /* Precompute the hash of the key and store it in the global structure */
      autoxs_hashkey hashkey;
      const unsigned int len = strlen(key);
      hashkey.key = newSVpvn(key, len);
      PERL_HASH(hashkey.hash, key, len);
      AutoXS_hashkeys[functionIndex] = hashkey;
    }


void
newxs_predicate(name, key)
  char* name;
  char* key;
  PPCODE:
    char* file = __FILE__;
    const unsigned int functionIndex = get_next_hashkey();
    {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      cv = newXS(name, XS_Class__XSAccessor_predicate, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
      XSANY.any_i32 = functionIndex;

      /* Precompute the hash of the key and store it in the global structure */
      autoxs_hashkey hashkey;
      const unsigned int len = strlen(key);
      hashkey.key = newSVpvn(key, len);
      PERL_HASH(hashkey.hash, key, len);
      AutoXS_hashkeys[functionIndex] = hashkey;
    }

void
newxs_constructor(name)
  char* name;
  PPCODE:
    char* file = __FILE__;
    {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      cv = newXS(name, XS_Class__XSAccessor_constructor, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
    }

