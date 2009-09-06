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
    HE* he;
  PPCODE:
    CXAH_OPTIMIZE_ENTERSUB(getter);
    if ((he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash)))
      XPUSHs(HeVAL(he));
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
    HE* he;
  PPCODE:
    if ((he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash)))
      XPUSHs(HeVAL(he));
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
    CXAH_OPTIMIZE_ENTERSUB(setter);
    if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    XPUSHs(newvalue);

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
    if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    XPUSHs(newvalue);

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
    CXAH_OPTIMIZE_ENTERSUB(chained_setter);
    if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    XPUSHs(self);

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
    if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    XPUSHs(self);

void
accessor_init(self, ...)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
    HE* he;
  PPCODE:
    CXAH_OPTIMIZE_ENTERSUB(accessor);
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      XPUSHs(newvalue);
    }
    else {
      if ((he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash)))
        XPUSHs(HeVAL(he));
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
    HE* he;
  PPCODE:
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      XPUSHs(newvalue);
    }
    else {
      if ((he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash)))
        XPUSHs(HeVAL(he));
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
    HE* he;
  PPCODE:
    CXAH_OPTIMIZE_ENTERSUB(chained_accessor);
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      XPUSHs(self);
    }
    else {
      if ((he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash)))
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
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
    HE* he;
  PPCODE:
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == hv_store_ent((HV*)SvRV(self), readfrom.key, newSVsv(newvalue), readfrom.hash))
        croak("Failed to write new value to hash.");
      XPUSHs(self);
    }
    else {
      if ((he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash)))
        XPUSHs(HeVAL(he));
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
    HE* he;
  PPCODE:
    CXAH_OPTIMIZE_ENTERSUB(predicate);
    if ( ((he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash))) && SvOK(HeVAL(he)) )
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
    HE* he;
  PPCODE:
    if ( ((he = hv_fetch_ent((HV *)SvRV(self), readfrom.key, 0, readfrom.hash))) && SvOK(HeVAL(he)) )
       XSRETURN_YES;
    else
      XSRETURN_NO;

void
constructor_init(class, ...)
    SV* class;
  ALIAS:
  PREINIT:
    int iStack;
    HV* hash;
    SV* obj;
    const char* classname;
  PPCODE:
    CXAH_OPTIMIZE_ENTERSUB(constructor);
    if (sv_isobject(class)) {
      classname = sv_reftype(SvRV(class), 1);
    }
    else {
      if (!SvPOK(class))
        croak("Need an object or class name as first argument to the constructor.");
      classname = SvPV_nolen(class);
    }
    
    hash = (HV *)sv_2mortal((SV *)newHV());
    obj = sv_bless( newRV_inc((SV*)hash), gv_stashpv(classname, 1) );

    if (items > 1) {
      if (!(items % 2))
        croak("Uneven number of argument to constructor.");

      for (iStack = 1; iStack < items; iStack += 2) {
        hv_store_ent(hash, ST(iStack), newSVsv(ST(iStack+1)), 0);
      }
    }
    XPUSHs(sv_2mortal(obj));

void
constructor(class, ...)
    SV* class;
  ALIAS:
  PREINIT:
    int iStack;
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
    obj = sv_bless( newRV_inc((SV*)hash), gv_stashpv(classname, 1) );

    if (items > 1) {
      if (!(items % 2))
        croak("Uneven number of argument to constructor.");

      for (iStack = 1; iStack < items; iStack += 2) {
        hv_store_ent(hash, ST(iStack), newSVsv(ST(iStack+1)), 0);
      }
    }
    XPUSHs(sv_2mortal(obj));

void
constant_false_init(self)
    SV* self;
  PPCODE:
    CXAH_OPTIMIZE_ENTERSUB(constant_false);
    {
      XSRETURN_NO;
    }

void
constant_false(self)
    SV* self;
  PPCODE:
    {
      XSRETURN_NO;
    }
   
void
constant_true_init(self)
    SV* self;
  PPCODE:
    CXAH_OPTIMIZE_ENTERSUB(constant_true);
    {
      XSRETURN_YES;
    }

void
constant_true(self)
    SV* self;
  PPCODE:
    {
      XSRETURN_YES;
    }

void
newxs_getter(name, key)
  char* name;
  char* key;
  PPCODE:
    INSTALL_NEW_CV_HASH_OBJ(name, CXAH(getter_init), key);

void
newxs_setter(name, key, chained)
  char* name;
  char* key;
  bool chained;
  PPCODE:
    if (chained)
      INSTALL_NEW_CV_HASH_OBJ(name, CXAH(chained_setter_init), key);
    else
      INSTALL_NEW_CV_HASH_OBJ(name, CXAH(setter_init), key);

void
newxs_accessor(name, key, chained)
  char* name;
  char* key;
  bool chained;
  PPCODE:
    if (chained)
      INSTALL_NEW_CV_HASH_OBJ(name, CXAH(chained_accessor_init), key);
    else
      INSTALL_NEW_CV_HASH_OBJ(name, CXAH(accessor_init), key);

void
newxs_predicate(name, key)
  char* name;
  char* key;
  PPCODE:
    INSTALL_NEW_CV_HASH_OBJ(name, CXAH(predicate_init), key);

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
