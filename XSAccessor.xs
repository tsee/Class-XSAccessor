#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "CXSAccessor.h"

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
  cv = newXS(name, xsub, (char*)__FILE__);                                  \
  if (cv == NULL)                                                           \
    croak("ARG! Something went really wrong while installing a new XSUB!"); \
  XSANY.any_i32 = function_index;                                           \
} STMT_END

MODULE = Class::XSAccessor        PACKAGE = Class::XSAccessor
PROTOTYPES: DISABLE

INCLUDE: XS/Hash.xs

INCLUDE: XS/Array.xs

