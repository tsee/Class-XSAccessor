MODULE = Class::XSAccessor		PACKAGE = Class::XSAccessor::Array
PROTOTYPES: DISABLE

void
getter_init(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
    SV** elem;
  PPCODE:
    CXA_CHECK_ARRAY(self);
    CXAA_OPTIMIZE_ENTERSUB(getter);
    if ((elem = av_fetch((AV *)SvRV(self), index, 1)))
      PUSHs(elem[0]);
    else
      XSRETURN_UNDEF;

void
getter(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
    SV** elem;
  PPCODE:
    CXA_CHECK_ARRAY(self);
    if ((elem = av_fetch((AV *)SvRV(self), index, 1)))
      PUSHs(elem[0]);
    else
      XSRETURN_UNDEF;

void
lvalue_accessor_init(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
    SV** elem;
    SV* sv;
  PPCODE:
    CXA_CHECK_ARRAY(self);
    CXAA_OPTIMIZE_ENTERSUB(lvalue_accessor);
    if ((elem = av_fetch((AV *)SvRV(self), index, 1))) {
      sv = *elem;
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
lvalue_accessor(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
    SV** elem;
    SV* sv;
  PPCODE:
    CXA_CHECK_ARRAY(self);
    if ((elem = av_fetch((AV *)SvRV(self), index, 1))) {
      sv = *elem;
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
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
  PPCODE:
    CXA_CHECK_ARRAY(self);
    CXAA_OPTIMIZE_ENTERSUB(setter);
    if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
      croak("Failed to write new value to array.");
    PUSHs(newvalue);

void
setter(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
  PPCODE:
    CXA_CHECK_ARRAY(self);
    if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
      croak("Failed to write new value to array.");
    PUSHs(newvalue);

void
chained_setter_init(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
  PPCODE:
    CXA_CHECK_ARRAY(self);
    CXAA_OPTIMIZE_ENTERSUB(chained_setter);
    if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
      croak("Failed to write new value to array.");
    PUSHs(self);

void
chained_setter(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
  PPCODE:
    CXA_CHECK_ARRAY(self);
    if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
      croak("Failed to write new value to array.");
    PUSHs(self);

void
accessor_init(self, ...)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
    SV** elem;
  PPCODE:
    CXA_CHECK_ARRAY(self);
    CXAA_OPTIMIZE_ENTERSUB(accessor);
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
        croak("Failed to write new value to array.");
      PUSHs(newvalue);
    }
    else {
      if ((elem = av_fetch((AV *)SvRV(self), index, 1)))
        PUSHs(elem[0]);
      else
        XSRETURN_UNDEF;
    }

void
accessor(self, ...)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
    SV** elem;
  PPCODE:
    CXA_CHECK_ARRAY(self);
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
        croak("Failed to write new value to array.");
      PUSHs(newvalue);
    }
    else {
      if ((elem = av_fetch((AV *)SvRV(self), index, 1)))
        PUSHs(elem[0]);
      else
        XSRETURN_UNDEF;
    }

void
chained_accessor_init(self, ...)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
    SV** elem;
  PPCODE:
    CXA_CHECK_ARRAY(self);
    CXAA_OPTIMIZE_ENTERSUB(chained_accessor);
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
        croak("Failed to write new value to array.");
      PUSHs(self);
    }
    else {
      if ((elem = av_fetch((AV *)SvRV(self), index, 1)))
        PUSHs(elem[0]);
      else
        XSRETURN_UNDEF;
    }

void
chained_accessor(self, ...)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
    SV** elem;
  PPCODE:
    CXA_CHECK_ARRAY(self);
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
        croak("Failed to write new value to array.");
      PUSHs(self);
    }
    else {
      if ((elem = av_fetch((AV *)SvRV(self), index, 1)))
        PUSHs(elem[0]);
      else
        XSRETURN_UNDEF;
    }

void
predicate_init(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
    SV** elem;
  PPCODE:
    CXA_CHECK_ARRAY(self);
    CXAA_OPTIMIZE_ENTERSUB(predicate);
    if ( (elem = av_fetch((AV *)SvRV(self), index, 1)) && SvOK(elem[0]) )
      XSRETURN_YES;
    else
      XSRETURN_NO;

void
predicate(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = CXSAccessor_arrayindices[ix];
    SV** elem;
  PPCODE:
    CXA_CHECK_ARRAY(self);
    if ( (elem = av_fetch((AV *)SvRV(self), index, 1)) && SvOK(elem[0]) )
      XSRETURN_YES;
    else
      XSRETURN_NO;

void
constructor_init(class, ...)
    SV* class;
  PREINIT:
    AV* array;
    SV* obj;
    const char* classname;
  PPCODE:
    CXAA_OPTIMIZE_ENTERSUB(constructor);
    if (sv_isobject(class)) {
      classname = sv_reftype(SvRV(class), 1);
    }
    else {
      if (!SvPOK(class))
        croak("Need an object or class name as first argument to the constructor.");
      classname = SvPV_nolen(class);
    }
    
    array = (AV *)sv_2mortal((SV *)newAV());
    obj = sv_bless( newRV_inc((SV*)array), gv_stashpv(classname, 1) );

    /* we ignore arguments. See Class::XSAccessor's XS code for
     * how we'd use them in case of bless {@_} => $class.
     */
    PUSHs(sv_2mortal(obj));

void
constructor(class, ...)
    SV* class;
  PREINIT:
    AV* array;
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
    
    array = (AV *)sv_2mortal((SV *)newAV());
    obj = sv_bless( newRV_inc((SV*)array), gv_stashpv(classname, 1) );

    /* we ignore arguments. See Class::XSAccessor's XS code for
     * how we'd use them in case of bless {@_} => $class.
     */
    PUSHs(sv_2mortal(obj));

void
newxs_getter(name, index)
  char* name;
  U32 index;
  PPCODE:
    INSTALL_NEW_CV_ARRAY_OBJ(name, CXAA(getter_init), index);

void
newxs_lvalue_accessor(name, index)
  char* name;
  U32 index;
  PPCODE:
    INSTALL_NEW_CV_ARRAY_OBJ(name, CXAA(getter_init), index);
    // Make the CV lvalue-able. "cv" was set by the previous macro
    CvLVALUE_on(cv);

void
newxs_setter(name, index, chained)
  char* name;
  U32 index;
  bool chained;
  PPCODE:
    if (chained)
      INSTALL_NEW_CV_ARRAY_OBJ(name, CXAA(chained_setter_init), index);
    else
      INSTALL_NEW_CV_ARRAY_OBJ(name, CXAA(setter_init), index);

void
newxs_accessor(name, index, chained)
  char* name;
  U32 index;
  bool chained;
  PPCODE:
    if (chained)
      INSTALL_NEW_CV_ARRAY_OBJ(name, CXAA(chained_accessor_init), index);
    else
      INSTALL_NEW_CV_ARRAY_OBJ(name, CXAA(accessor_init), index);

void
newxs_predicate(name, index)
  char* name;
  U32 index;
  PPCODE:
    INSTALL_NEW_CV_ARRAY_OBJ(name, CXAA(predicate_init), index);

void
newxs_constructor(name)
  char* name;
  PPCODE:
    INSTALL_NEW_CV(name, CXAA(constructor_init));
