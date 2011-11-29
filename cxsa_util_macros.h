/* we want hv_fetch but with the U32 hash argument of hv_fetch_ent, so do it ourselves... */
#ifndef CXSA_HASH_FETCH
#  ifdef hv_common_key_len
#    define CXSA_HASH_FETCH(hv, key, len, hash) hv_common_key_len((hv), (key), (len), HV_FETCH_JUST_SV, NULL, (hash))
#    define CXSA_HASH_FETCH_LVALUE(hv, key, len, hash) hv_common_key_len((hv), (key), (len), (HV_FETCH_JUST_SV|HV_FETCH_LVALUE), NULL, (hash))
#  else
#    define CXSA_HASH_FETCH(hv, key, len, hash) hv_fetch(hv, key, len, 0)
#    define CXSA_HASH_FETCH_LVALUE(hv, key, len, hash) hv_fetch((hv), (key), (len), 1)
#  endif
#endif

#ifndef croak_xs_usage
#  define croak_xs_usage(cv,msg) croak(aTHX_ "Usage: %s(%s)", GvNAME(CvGV(cv)), msg)
#endif

/* Calls the _get method on the "self" SV* and provides it with
 * a single argument: The provided hash key string. Runs in scalar
 * context and assigns the result to the "sv" SV* */
#ifndef CXSA_CALL_GET_METHOD
#  define CXSA_CALL_GET_METHOD(key, keylen)           \
    STMT_START {                                      \
        int count;                                    \
        dSP;                                          \
                                                      \
        ENTER;                                        \
        SAVETMPS;                                     \
                                                      \
        PUSHMARK(SP);                                 \
        XPUSHs(self);                                 \
        XPUSHs(sv_2mortal(newSVpv((key), (keylen)))); \
        PUTBACK;                                      \
                                                      \
        count = call_method("_get", G_SCALAR);        \
        SPAGAIN;                                      \
                                                      \
        if (count != 1)                               \
          croak("Big trouble\n");                     \
        sv = POPs;                                    \
        SvREFCNT_inc(sv);                             \
                                                      \
        PUTBACK;                                      \
        FREETMPS;                                     \
        LEAVE;                                        \
    } STMT_END
#endif

/* Calls the _set method on the "self" SV* and provides it with
 * a two arguments: The provided hash key string and the provided
 * scalar value. Runs in void context */
#ifndef CXSA_CALL_SET_METHOD
#  define CXSA_CALL_SET_METHOD(key, keylen, newvalue) \
    STMT_START {                                      \
        dSP;                                          \
                                                      \
        ENTER;                                        \
        SAVETMPS;                                     \
                                                      \
        PUSHMARK(SP);                                 \
        XPUSHs(self);                                 \
        XPUSHs(sv_2mortal(newSVpv((key), (keylen)))); \
        XPUSHs((newvalue));                           \
        PUTBACK;                                      \
                                                      \
        if (0 != call_method("_set", G_VOID))         \
          croak("Big trouble\n");                     \
        SPAGAIN;                                      \
                                                      \
        PUTBACK;                                      \
        FREETMPS;                                     \
        LEAVE;                                        \
    } STMT_END
#endif
