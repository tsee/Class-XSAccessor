typedef struct {
  U32 hash;
  SV* key;
} autoxs_hashkey;

/* prototype section */

I32 get_hashkey_index(pTHX_ const char* key, const I32 len);
I32 _new_hashkey();
void _resize_array(I32** array, U32* len, U32 newlen);
void _resize_array_init(I32** array, U32* len, U32 newlen, I32 init);
I32 _new_internal_arrayindex();
I32 get_internal_array_index(I32 object_ary_idx);

/* initialization section */

U32 CXSAccessor_no_hashkeys = 0;
U32 CXSAccessor_free_hashkey_no = 0;
autoxs_hashkey* CXSAccessor_hashkeys = NULL;
HV* CXSAccessor_reverse_hashkeys = NULL;

U32 CXSAccessor_no_arrayindices = 0;
U32 CXSAccessor_free_arrayindices_no = 0;
I32* CXSAccessor_arrayindices = NULL;

U32 CXSAccessor_reverse_arrayindices_length = 0;
I32* CXSAccessor_reverse_arrayindices = NULL;


/* implementation section */

I32 get_hashkey_index(pTHX_ const char* key, const I32 len) {
  I32 index;

  /* init */
  if (CXSAccessor_reverse_hashkeys == NULL)
    CXSAccessor_reverse_hashkeys = newHV();

  index = 0;
  if ( hv_exists(CXSAccessor_reverse_hashkeys, key, len) ) {
    SV** index_sv = hv_fetch(CXSAccessor_reverse_hashkeys, key, len, 0);

    /* simply return the index that corresponds to an earlier
     * use with the same hash key name */

    if ( (index_sv == NULL) || (!SvIOK(*index_sv)) ) {
      /* shouldn't happen */
      index = _new_hashkey();
    }
    else /* Note to self: Check that this I32 cast is sane */
      return (I32)SvIVX(*index_sv);
  }
  else /* does not exist */
    index = _new_hashkey();

  /* store the new hash key in the reverse lookup table */
  hv_store(CXSAccessor_reverse_hashkeys, key, len, newSViv(index), 0);
  return index;
}

/* this is private, call get_hashkey_index instead */
I32 _new_hashkey() {
  if (CXSAccessor_no_hashkeys == CXSAccessor_free_hashkey_no) {
    U32 extend = 1 + CXSAccessor_no_hashkeys * 2;
    /*printf("extending hashkey storage by %u\n", extend);*/
    autoxs_hashkey* tmphashkeys;
    Newx(tmphashkeys, CXSAccessor_no_hashkeys + extend, autoxs_hashkey);
    Copy(CXSAccessor_hashkeys, tmphashkeys, CXSAccessor_no_hashkeys, autoxs_hashkey);
    Safefree(CXSAccessor_hashkeys);
    CXSAccessor_hashkeys = tmphashkeys;
    CXSAccessor_no_hashkeys += extend;
  }
  return CXSAccessor_free_hashkey_no++;
}


void _resize_array(I32** array, U32* len, U32 newlen) {
  I32* tmparraymap;
  Newx(tmparraymap, newlen * sizeof(I32), I32);
  Copy(*array, tmparraymap, *len, I32);
  Safefree(*array);
  *array = tmparraymap;
  *len = newlen;
}

void _resize_array_init(I32** array, U32* len, U32 newlen, I32 init) {
  U32 i;
  I32* tmparraymap;
  Newx(tmparraymap, newlen * sizeof(I32), I32);
  Copy(*array, tmparraymap, *len, I32);
  Safefree(*array);
  *array = tmparraymap;
  for (i = *len; i < newlen; ++i)
    (*array)[i] = init;
  *len = newlen;
}


/* this is private, call get_internal_array_index instead */
I32 _new_internal_arrayindex() {
  if (CXSAccessor_no_arrayindices == CXSAccessor_free_arrayindices_no) {
    U32 extend = 2 + CXSAccessor_no_arrayindices * 2;
    /*printf("extending array index storage by %u\n", extend);*/
    _resize_array(&CXSAccessor_arrayindices, &CXSAccessor_no_arrayindices, extend);
  }
  return CXSAccessor_free_arrayindices_no++;
}

I32 get_internal_array_index(I32 object_ary_idx) {
  I32 new_index;

  if (CXSAccessor_reverse_arrayindices_length <= (U32)object_ary_idx)
    _resize_array_init( &CXSAccessor_reverse_arrayindices,
                        &CXSAccessor_reverse_arrayindices_length,
                        object_ary_idx+1, -1 );

  /* -1 == "undef" */
  if (CXSAccessor_reverse_arrayindices[object_ary_idx] > -1)
    return CXSAccessor_reverse_arrayindices[object_ary_idx];

  new_index = _new_internal_arrayindex();
  CXSAccessor_reverse_arrayindices[object_ary_idx] = new_index;
  return new_index;
}
