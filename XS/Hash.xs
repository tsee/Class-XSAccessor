#include "ppport.h"

#include "cxsa_util_macros.h"

MODULE = Class::XSAccessor        PACKAGE = Class::XSAccessor
PROTOTYPES: DISABLE

void
getter_init(self)
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
    CXAH_OPTIMIZE_ENTERSUB(getter);
    if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
      PUSHs(*svp);
    else
      XSRETURN_UNDEF;

void
getter(self)
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
    else
      XSRETURN_UNDEF;


void
lvalue_accessor_init(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
    SV** svp;
    SV* sv;
  PPCODE:
    CXA_CHECK_HASH(self);
    CXAH_OPTIMIZE_ENTERSUB(lvalue_accessor);
    if ((svp = CXSA_HASH_FETCH_LVALUE((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash))) {
      sv = *svp;
      sv_upgrade(sv, SVt_PVLV);
      sv_magic(sv, 0, PERL_MAGIC_ext, Nullch, 0);
      SvSMAGICAL_on(sv);
      LvTYPE(sv) = '~';
      LvTARG(sv) = SvREFCNT_inc(sv);
      SvMAGIC(sv)->mg_virtual = &cxsa_lvalue_acc_magic_vtable;
      ST(0) = sv;
      XSRETURN(1);
    }
    else
      XSRETURN_UNDEF;

void
lvalue_accessor(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
    SV** svp;
    SV* sv;
  PPCODE:
    CXA_CHECK_HASH(self);
    if ((svp = CXSA_HASH_FETCH_LVALUE((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash))) {
      sv = *svp;
      sv_upgrade(sv, SVt_PVLV);
      sv_magic(sv, 0, PERL_MAGIC_ext, Nullch, 0);
      SvSMAGICAL_on(sv);
      LvTYPE(sv) = '~';
      SvREFCNT_inc(sv);
      LvTARG(sv) = SvREFCNT_inc(sv);
      SvMAGIC(sv)->mg_virtual = &cxsa_lvalue_acc_magic_vtable;
      ST(0) = sv;
      XSRETURN(1);
    }
    else
      XSRETURN_UNDEF;

void
setter_init(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
  PPCODE:
    CXA_CHECK_HASH(self);
    CXAH_OPTIMIZE_ENTERSUB(setter);
    if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    PUSHs(newvalue);

void
setter(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
  PPCODE:
    CXA_CHECK_HASH(self);
    if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    PUSHs(newvalue);

void
chained_setter_init(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
  PPCODE:
    CXA_CHECK_HASH(self);
    CXAH_OPTIMIZE_ENTERSUB(chained_setter);
    if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    PUSHs(self);

void
chained_setter(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
  PPCODE:
    CXA_CHECK_HASH(self);
    if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    PUSHs(self);

void
accessor_init(self, ...)
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
    CXAH_OPTIMIZE_ENTERSUB(accessor);
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      PUSHs(newvalue);
    }
    else {
      if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
        PUSHs(*svp);
      else
        XSRETURN_UNDEF;
    }

void
accessor(self, ...)
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
      if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      PUSHs(newvalue);
    }
    else {
      if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
        PUSHs(*svp);
      else
        XSRETURN_UNDEF;
    }


void
chained_accessor_init(self, ...)
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
    CXAH_OPTIMIZE_ENTERSUB(chained_accessor);
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      PUSHs(self);
    }
    else {
      if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
        PUSHs(*svp);
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
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
    SV** svp;
  PPCODE:
    CXA_CHECK_HASH(self);
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      PUSHs(self);
    }
    else {
      if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
        PUSHs(*svp);
      else
        XSRETURN_UNDEF;
    }

void
predicate_init(self)
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
    CXAH_OPTIMIZE_ENTERSUB(predicate);
    if ( ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash))) && SvOK(*svp) )
      XSRETURN_YES;
    else
      XSRETURN_NO;

void
predicate(self)
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
    if ( ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash))) && SvOK(*svp) )
      XSRETURN_YES;
    else
      XSRETURN_NO;

void
constructor_init(class, ...)
    SV* class;
  PREINIT:
    int iStack;
    HV* hash;
    SV* obj;
    const char* classname;
  PPCODE:
    CXAH_OPTIMIZE_ENTERSUB(constructor);

    classname = SvROK(class) ? sv_reftype(SvRV(class), 1) : SvPV_nolen_const(class);
    hash = newHV();
    obj = sv_bless(newRV_noinc((SV *)hash), gv_stashpv(classname, 1));

    if (items > 1) {
      /* if @_ - 1 (for $class) is even: most compilers probably convert items % 2 into this, but just in case */
      if (items & 1) {
        for (iStack = 1; iStack < items; iStack += 2) {
          /* we could check for the hv_store_ent return value, but perl doesn't in this situation (see pp_anonhash) */
          (void)hv_store_ent(hash, ST(iStack), newSVsv(ST(iStack+1)), 0);
        }
      } else {
        croak("Uneven number of arguments to constructor.");
      }
    }

    PUSHs(sv_2mortal(obj));

void
constructor(class, ...)
    SV* class;
  PREINIT:
    int iStack;
    HV* hash;
    SV* obj;
    const char* classname;
  PPCODE:
    classname = SvROK(class) ? sv_reftype(SvRV(class), 1) : SvPV_nolen_const(class);
    hash = newHV();
    obj = sv_bless(newRV_noinc((SV *)hash), gv_stashpv(classname, 1));

    if (items > 1) {
      /* if @_ - 1 (for $class) is even: most compilers probably convert items % 2 into this, but just in case */
      if (items & 1) {
        for (iStack = 1; iStack < items; iStack += 2) {
          /* we could check for the hv_store_ent return value, but perl doesn't in this situation (see pp_anonhash) */
          (void)hv_store_ent(hash, ST(iStack), newSVsv(ST(iStack+1)), 0);
        }
      } else {
        croak("Uneven number of arguments to constructor.");
      }
    }

    PUSHs(sv_2mortal(obj));

void
constant_false_init(self)
  SV *self;
  PPCODE:
    PERL_UNUSED_VAR(self);
    CXAH_OPTIMIZE_ENTERSUB(constant_false);
    {
      XSRETURN_NO;
    }

void
constant_false(self)
  SV *self;
  PPCODE:
    PERL_UNUSED_VAR(self);
    {
      XSRETURN_NO;
    }
   
void
constant_true_init(self)
    SV* self;
  PPCODE:
    PERL_UNUSED_VAR(self);
    CXAH_OPTIMIZE_ENTERSUB(constant_true);
    {
      XSRETURN_YES;
    }

void
constant_true(self)
    SV* self;
  PPCODE:
    PERL_UNUSED_VAR(self);
    {
      XSRETURN_YES;
    }

void
test_init(self, ...)
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
    warn("cxah: accessor: inside test_init");
    CXAH_OPTIMIZE_ENTERSUB_TEST(test);
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      PUSHs(newvalue);
    }
    else {
      if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
        PUSHs(*svp);
      else
        XSRETURN_UNDEF;
    }

void
test(self, ...)
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
    warn("cxah: accessor: inside test");
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      PUSHs(newvalue);
    }
    else {
      if ((svp = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
        PUSHs(*svp);
      else
        XSRETURN_UNDEF;
    }

void
newxs_getter(name, key)
  char* name;
  char* key;
  ALIAS:
    Class::XSAccessor::newxs_lvalue_accessor = 1
    Class::XSAccessor::newxs_predicate = 2
    Class::XSAccessor::newxs_cached_getter = 3
  PPCODE:
    switch (ix) {
    case 0: /* newxs_getter */
      INSTALL_NEW_CV_HASH_OBJ(name, CXAH(getter_init), key);
      break;
    case 1: { /* newxs_lvalue_accessor */
      CV* cv;
        INSTALL_NEW_CV_HASH_OBJ(name, CXAH(lvalue_accessor_init), key);
        /* Make the CV lvalue-able. "cv" was set by the previous macro */
        CvLVALUE_on(cv);
      }
      break;
    case 2:
      INSTALL_NEW_CV_HASH_OBJ(name, CXAH(predicate_init), key);
      break;
    case 3: /* note: cached_getter(_init) implementation lives in HashCached.xs */
      INSTALL_NEW_CV_HASH_OBJ(name, CXAH(cached_getter_init), key);
      break;
    default:
      croak("Invalid alias of newxs_getter called");
      break;
    }

void
newxs_setter(name, key, chained)
    char* name;
    char* key;
    bool chained;
  ALIAS:
    Class::XSAccessor::newxs_accessor = 1
    Class::XSAccessor::newxs_cached_accessor = 2
  PPCODE:
    if (ix == 0) { /* newxs_setter */
      if (chained)
        INSTALL_NEW_CV_HASH_OBJ(name, CXAH(chained_setter_init), key);
      else
        INSTALL_NEW_CV_HASH_OBJ(name, CXAH(setter_init), key);
      }
    else if (ix == 1) { /* newxs_accessor */
      if (chained)
        INSTALL_NEW_CV_HASH_OBJ(name, CXAH(chained_accessor_init), key);
      else
        INSTALL_NEW_CV_HASH_OBJ(name, CXAH(accessor_init), key);
    }
    else { /* newxs_cached_accessor, see HashCached.xs for implementation */
      if (chained)
        croak("No chained variant of the cached accessor implemented");
      else
        INSTALL_NEW_CV_HASH_OBJ(name, CXAH(cached_accessor_init), key);
    }

void
newxs_constructor(name)
  char* name;
  PPCODE:
    INSTALL_NEW_CV(name, CXAH(constructor_init));

void
newxs_boolean(name, truth)
  char* name;
  bool truth;
  PPCODE:
    if (truth)
      INSTALL_NEW_CV(name, CXAH(constant_true_init));
    else
      INSTALL_NEW_CV(name, CXAH(constant_false_init));

void
newxs_test(name, key)
  char* name;
  char* key;
  PPCODE:
      INSTALL_NEW_CV_HASH_OBJ(name, CXAH(test_init), key);


