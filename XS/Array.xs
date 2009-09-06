MODULE = Class::XSAccessor		PACKAGE = Class::XSAccessor::Array
PROTOTYPES: DISABLE

void
getter(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = AutoXS_arrayindices[ix];
    SV** elem;
  PPCODE:
    if ((elem = av_fetch((AV *)SvRV(self), index, 1)))
      XPUSHs(elem[0]);
    else
      XSRETURN_UNDEF;


void
setter(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = AutoXS_arrayindices[ix];
  PPCODE:
    if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
      croak("Failed to write new value to array.");
    XPUSHs(newvalue);


void
chained_setter(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = AutoXS_arrayindices[ix];
  PPCODE:
    if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
      croak("Failed to write new value to array.");
    XPUSHs(self);



void
accessor(self, ...)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = AutoXS_arrayindices[ix];
    SV** elem;
  PPCODE:
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
        croak("Failed to write new value to array.");
      XPUSHs(newvalue);
    }
    else {
      if ((elem = av_fetch((AV *)SvRV(self), index, 1)))
        XPUSHs(elem[0]);
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
    const I32 index = AutoXS_arrayindices[ix];
    SV** elem;
  PPCODE:
    if (items > 1) {
      SV* newvalue = ST(1);
      if (NULL == av_store((AV*)SvRV(self), index, newSVsv(newvalue)))
        croak("Failed to write new value to array.");
      XPUSHs(self);
    }
    else {
      if ((elem = av_fetch((AV *)SvRV(self), index, 1)))
        XPUSHs(elem[0]);
      else
        XSRETURN_UNDEF;
    }


void
predicate(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the array index from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const I32 index = AutoXS_arrayindices[ix];
    SV** elem;
  PPCODE:
    if ( (elem = av_fetch((AV *)SvRV(self), index, 1)) && SvOK(elem[0]) )
      XSRETURN_YES;
    else
      XSRETURN_NO;



void
constructor(class, ...)
    SV* class;
  ALIAS:
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
    obj = sv_bless( newRV((SV*)array), gv_stashpv(classname, 1) );

    /* we ignore arguments. See Class::XSAccessor's XS code for
     * how we'd use them in case of bless {@_} => $class.
     */
    XPUSHs(sv_2mortal(obj));



void
constant_false(self)
    SV* self;
  PPCODE:
    {
      XSRETURN_NO;
    }

   
void
constant_true(self)
    SV* self;
  PPCODE:
    {
      XSRETURN_YES;
    }



void
newxs_getter(name, index)
  char* name;
  unsigned int index;
  PPCODE:
    char* file = __FILE__;
    const unsigned int functionIndex = get_internal_array_index( (I32)index );
    {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      cv = newXS(name, XS_Class__XSAccessor__Array_getter, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
      XSANY.any_i32 = functionIndex;

      AutoXS_arrayindices[functionIndex] = index;
    }


void
newxs_setter(name, index, chained)
  char* name;
  unsigned int index;
  bool chained;
  PPCODE:
    char* file = __FILE__;
    const unsigned int functionIndex = get_internal_array_index( (I32)index );
    {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      if (chained)
        cv = newXS(name, XS_Class__XSAccessor__Array_chained_setter, file);
      else
        cv = newXS(name, XS_Class__XSAccessor__Array_setter, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
      XSANY.any_i32 = functionIndex;

      AutoXS_arrayindices[functionIndex] = index;
    }


void
newxs_accessor(name, index, chained)
  char* name;
  unsigned int index;
  bool chained;
  PPCODE:
    char* file = __FILE__;
    const unsigned int functionIndex = get_internal_array_index( (I32)index );
    {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      if (chained)
        cv = newXS(name, XS_Class__XSAccessor__Array_chained_accessor, file);
      else
        cv = newXS(name, XS_Class__XSAccessor__Array_accessor, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
      XSANY.any_i32 = functionIndex;

      AutoXS_arrayindices[functionIndex] = index;
    }


void
newxs_predicate(name, index)
  char* name;
  unsigned int index;
  PPCODE:
    char* file = __FILE__;
    const unsigned int functionIndex = get_internal_array_index( (I32)index );
    {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      cv = newXS(name, XS_Class__XSAccessor__Array_predicate, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
      XSANY.any_i32 = functionIndex;

      AutoXS_arrayindices[functionIndex] = index;
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
      cv = newXS(name, XS_Class__XSAccessor__Array_constructor, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
    }



void
newxs_boolean(name, truth)
  char* name;
  bool truth;
  PPCODE:
    char* file = __FILE__;
    if (truth) {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      cv = newXS(name, XS_Class__XSAccessor__Array_constant_true, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
    }
    else {
      CV * cv;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      cv = newXS(name, XS_Class__XSAccessor__Array_constant_false, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
    }


