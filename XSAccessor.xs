#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "CXSAccessor.h"

MODULE = Class::XSAccessor        PACKAGE = Class::XSAccessor
PROTOTYPES: DISABLE

INCLUDE: XS/Hash.xs

INCLUDE: XS/Array.xs

