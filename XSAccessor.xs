#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "CXSAccessor.h"

#define CXAA(name) XS_Class__XSAccessor__Array_ ## name
#define CXAH(name) XS_Class__XSAccessor_ ## name

/* FIXME: need to document this better */

/*
 * chocolateboy: 2009-09-06:
 *
 * First some preliminaries: a method call is performed as a subroutine call at the OP
 * level. there's some additional work to look up the method CV and push the invocant
 * on the stack, but the current OP inside an XSUB is the subroutine call OP, OP_ENTERSUB.
 *
 * two distinct invocations of the same method will have two entersub OPs and will receive
 * the same CV on the stack:
 *
 *     $foo->bar(...); # OP 1: CV 1
 *     $foo->bar(...); # OP 2: CV 1
 *
 * There are also situations in which the same entersub OP calls one or more CVs: 
 *
 *     $foo->$_() for (foo bar); # OP 1: CV 1, CV 2
 *
 * Inside each Class::XSAccessor XSUB, we can access the current entersub OP (PL_op).
 * The default entersub implementation (pp_entersub) has a lot of boilerplate for
 * dealing with all the different ways in which pp_entersub can be called. It sets up
 * and tears down a new scope; it deals with the fact that the code ref can be passed
 * in as a glob or CV; and it has numerous conditional statements to deal with the various
 * different type of CV.
 *
 * For our XSUB accessors, we don't need most of that. We don't need to open a new scope;
 * the subroutine is almost always a CV (that's what OP_METHOD and OP_METHOD_NAMED usually return)
 * and we don't need to deal with all the non-XSUB cases. This allows us to replace the
 * OP's implementation (op_ppaddr) with a version optimized for our simple XSUBs. (This
 * is inspired by B::XSUB::Dumber: nothingmuch++)
 *
 * We do this inside the accessor i.e. at runtime. We can also back out the optimization
 * if a call site proves to be dynamic e.g. if a method is redefined or the method is
 * called with multiple CVs.
 *
 * in practice, this is rarely the case. the vast majority of method calls in perl,
 * and in most dynamic languages (cf. Google's v8), behave like method calls in static
 * languages. for instance, 97% of method calls in perl 5.10.0's test suite are monomorphic
 *
 * We only replaces the op_ppaddr of entersub OPs that use the default pp_entersub.
 * this ensures we don't interfere with any modules that assign a new op_ppaddr e.g.
 * Data::Alias, Faster. it also ensures we don't tread on our own toes and repeatedly
 * re-assign the same optimized entersub
 */

#define CXAH_OPTIMIZE_ENTERSUB(name)                              \
STMT_START {                                                      \
    if (PL_op->op_ppaddr == CXA_DEFAULT_ENTERSUB) {               \
        PL_op->op_ppaddr = cxah_entersub_ ## name;                \
    } else {                                                      \
        CvXSUB(cv) = CXAH(name);                                  \
    }                                                             \
} STMT_END

#define CXAA_OPTIMIZE_ENTERSUB(name)                              \
STMT_START {                                                      \
    if (PL_op->op_ppaddr == CXA_DEFAULT_ENTERSUB) {               \
        PL_op->op_ppaddr = cxaa_entersub_ ## name;                \
    } else {                                                      \
        CvXSUB(cv) = CXAA(name);                                  \
    }                                                             \
} STMT_END

/*
 * VMS mangles XSUB names so that they're less than 32 characters, and
 * ExtUtils::ParseXS provides no way to XS-ify XSUB names that appear
 * anywhere else but in the XSUB definition.
 *
 * The mangling is deterministic, so we can translate from every other
 * platform => VMS here
 *
 * This will probably never get used.
 */

#ifdef VMS
#define Class__XSAccessor_getter_init Class_XSAccessor_getter_init
#define Class__XSAccessor_setter_init Class_XSAccessor_setter_init
#define Class__XSAccessor_chained_setter_init Cs_XSAs_cid_ser_init
#define Class__XSAccessor_chained_setter Clas_XSAcesor_chained_seter
#define Class__XSAccessor_accessor_init Clas_XSAcesor_acesor_init
#define Class__XSAccessor_chained_accessor_init Cs_XSAs_cid_as_init
#define Class__XSAccessor_chained_accessor Clas_XSAcesor_chained_acesor
#define Class__XSAccessor_predicate_init Clas_XSAcesor_predicate_init
#define Class__XSAccessor_constructor_init Cs_XSAs_csuor_init
#define Class__XSAccessor_constructor Class_XSAccessor_constructor
#define Class__XSAccessor_constant_false_init Cs_XSAs_csnt_fse_init
#define Class__XSAccessor_constant_false Clas_XSAcesor_constant_false
#define Class__XSAccessor_constant_true_init Cs_XSAs_csnt_te_init
#define Class__XSAccessor_constant_true Clas_XSAcesor_constant_true
#define Class__XSAccessor__Array_getter_init Cs_XSAs_Ay_ger_init
#define Class__XSAccessor__Array_getter Clas_XSAcesor_Aray_geter
#define Class__XSAccessor__Array_setter_init Cs_XSAs_Ay_ser_init
#define Class__XSAccessor__Array_setter Clas_XSAcesor_Aray_seter
#define Class__XSAccessor__Array_chained_setter_init Cs_XSAs_Ay_cid_ser_init
#define Class__XSAccessor__Array_chained_setter Cs_XSAs_Ay_cid_seter
#define Class__XSAccessor__Array_accessor_init Cs_XSAs_Ay_as_init
#define Class__XSAccessor__Array_accessor Clas_XSAcesor_Aray_acesor
#define Class__XSAccessor__Array_chained_accessor_init Cs_XSAs_Ay_cid_as_init
#define Class__XSAccessor__Array_chained_accessor Cs_XSAs_Ay_cid_acesor
#define Class__XSAccessor__Array_predicate_init Cs_XSAs_Ay_pda_init
#define Class__XSAccessor__Array_predicate Clas_XSAcesor_Aray_predicate
#define Class__XSAccessor__Array_constructor_init Cs_XSAs_Ay_csuor_init
#define Class__XSAccessor__Array_constructor Cs_XSAs_Ay_constructor
#define Class__XSAccessor__Array_constant_false_init Cs_XSAs_Ay_csnt_fse_init
#define Class__XSAccessor__Array_constant_false Cs_XSAs_Ay_csnt_false
#define Class__XSAccessor__Array_constant_true_init Cs_XSAs_Ay_csnt_te_init
#define Class__XSAccessor__Array_constant_true Cs_XSAs_Ay_csnt_true
#endif

#define CXAH_GENERATE_ENTERSUB(name)                                                   \
OP * cxah_entersub_ ## name(pTHX) {                                                    \
    dVAR; dSP; dTOPss;                                                                 \
                                                                                       \
    if (sv && (SvTYPE(sv) == SVt_PVCV) && (CvXSUB((CV *)sv) == CXAH(name ## _init))) { \
        POPs;                                                                          \
        PUTBACK;                                                                       \
        (void)CXAH(name)(aTHX_ (CV *)sv);                                              \
        return NORMAL;                                                                 \
    } else { /* not static: disable optimization */                                    \
        PL_op->op_ppaddr = CXA_DEFAULT_ENTERSUB;                                       \
    }                                                                                  \
                                                                                       \
    return CALL_FPTR(PL_op->op_ppaddr)(aTHX);                                          \
}

#define CXAA_GENERATE_ENTERSUB(name)                                                   \
OP * cxaa_entersub_ ## name(pTHX) {                                                    \
    dVAR; dSP; dTOPss;                                                                 \
                                                                                       \
    if (sv && (SvTYPE(sv) == SVt_PVCV) && (CvXSUB((CV *)sv) == CXAA(name ## _init))) { \
        POPs;                                                                          \
        PUTBACK;                                                                       \
        (void)CXAA(name)(aTHX_ (CV *)sv);                                              \
        return NORMAL;                                                                 \
    } else { /* not static: disable optimization */                                    \
        PL_op->op_ppaddr = CXA_DEFAULT_ENTERSUB;                                       \
    }                                                                                  \
                                                                                       \
    return CALL_FPTR(PL_op->op_ppaddr)(aTHX);                                          \
}

/* Install a new XSUB under 'name' and automatically set the file name */
#define INSTALL_NEW_CV(name, xsub)                                            \
STMT_START {                                                                  \
  if (newXS(name, xsub, (char*)__FILE__) == NULL)                             \
    croak("ARG! Something went really wrong while installing a new XSUB!");   \
} STMT_END

/* Install a new XSUB under 'name' and set the function index attribute
 * Requires a previous declaration of a CV* cv!
 **/
#define INSTALL_NEW_CV_WITH_INDEX(name, xsub, function_index)               \
STMT_START {                                                                \
  CV* cv = newXS(name, xsub, (char*)__FILE__);                              \
  if (cv == NULL)                                                           \
    croak("ARG! Something went really wrong while installing a new XSUB!"); \
  XSANY.any_i32 = function_index;                                           \
} STMT_END

/* Install a new XSUB under 'name' and set the function index attribute
 * for array-based objects. Requires a previous declaration of a CV* cv!
 **/
#define INSTALL_NEW_CV_ARRAY_OBJ(name, xsub, obj_array_index)                \
STMT_START {                                                                 \
  const U32 function_index = get_internal_array_index((I32)obj_array_index); \
  INSTALL_NEW_CV_WITH_INDEX(name, xsub, function_index);                     \
  CXSAccessor_arrayindices[function_index] = obj_array_index;                \
} STMT_END


/* Install a new XSUB under 'name' and set the function index attribute
 * for hash-based objects. Requires a previous declaration of a CV* cv!
 **/
#define INSTALL_NEW_CV_HASH_OBJ(name, xsub, obj_hash_key)                    \
STMT_START {                                                                 \
  autoxs_hashkey hashkey;                                                    \
  const U32 key_len = strlen(obj_hash_key);                                  \
  const U32 function_index = get_hashkey_index(aTHX_ obj_hash_key, key_len); \
  INSTALL_NEW_CV_WITH_INDEX(name, xsub, function_index);                     \
  hashkey.key = newSVpvn(obj_hash_key, key_len);                             \
  PERL_HASH(hashkey.hash, obj_hash_key, key_len);                            \
  CXSAccessor_hashkeys[function_index] = hashkey;                            \
} STMT_END

static Perl_ppaddr_t CXA_DEFAULT_ENTERSUB = NULL;

/* predeclare the XSUBs so we can refer to them in the optimized entersubs */

XS(CXAH(getter));
XS(CXAH(getter_init));
CXAH_GENERATE_ENTERSUB(getter);

XS(CXAH(setter));
XS(CXAH(setter_init));
CXAH_GENERATE_ENTERSUB(setter);

XS(CXAH(chained_setter));
XS(CXAH(chained_setter_init));
CXAH_GENERATE_ENTERSUB(chained_setter);

XS(CXAH(accessor));
XS(CXAH(accessor_init));
CXAH_GENERATE_ENTERSUB(accessor);

XS(CXAH(chained_accessor));
XS(CXAH(chained_accessor_init));
CXAH_GENERATE_ENTERSUB(chained_accessor);

XS(CXAH(predicate));
XS(CXAH(predicate_init));
CXAH_GENERATE_ENTERSUB(predicate);

XS(CXAH(constructor));
XS(CXAH(constructor_init));
CXAH_GENERATE_ENTERSUB(constructor);

XS(CXAH(constant_false));
XS(CXAH(constant_false_init));
CXAH_GENERATE_ENTERSUB(constant_false);

XS(CXAH(constant_true));
XS(CXAH(constant_true_init));
CXAH_GENERATE_ENTERSUB(constant_true);

XS(CXAA(getter));
XS(CXAA(getter_init));
CXAA_GENERATE_ENTERSUB(getter);

XS(CXAA(setter));
XS(CXAA(setter_init));
CXAA_GENERATE_ENTERSUB(setter);

XS(CXAA(chained_setter));
XS(CXAA(chained_setter_init));
CXAA_GENERATE_ENTERSUB(chained_setter);

XS(CXAA(accessor));
XS(CXAA(accessor_init));
CXAA_GENERATE_ENTERSUB(accessor);

XS(CXAA(chained_accessor));
XS(CXAA(chained_accessor_init));
CXAA_GENERATE_ENTERSUB(chained_accessor);

XS(CXAA(predicate));
XS(CXAA(predicate_init));
CXAA_GENERATE_ENTERSUB(predicate);

XS(CXAA(constructor));
XS(CXAA(constructor_init));
CXAA_GENERATE_ENTERSUB(constructor);

XS(CXAA(constant_false));
XS(CXAA(constant_false_init));
CXAA_GENERATE_ENTERSUB(constant_false);

XS(CXAA(constant_true));
XS(CXAA(constant_true_init));
CXAA_GENERATE_ENTERSUB(constant_true);

MODULE = Class::XSAccessor        PACKAGE = Class::XSAccessor
PROTOTYPES: DISABLE

BOOT:
CXA_DEFAULT_ENTERSUB = PL_ppaddr[OP_ENTERSUB];

INCLUDE: XS/Hash.xs

INCLUDE: XS/Array.xs
