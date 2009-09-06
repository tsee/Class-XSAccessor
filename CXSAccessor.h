typedef struct {
  U32 hash;
  SV* key;
} autoxs_hashkey;

/* prototype section */

I32 get_hashkey_index(const char* key, const I32 len);
I32 _new_hashkey();
void _resize_array(I32** array, unsigned int* len, unsigned int newlen);
void _resize_array_init(I32** array, unsigned int* len, unsigned int newlen, I32 init);
I32 _new_internal_arrayindex();
I32 get_internal_array_index(I32 object_ary_idx);

/* initialization section */

unsigned int CXSAccessor_no_hashkeys = 0;
unsigned int CXSAccessor_free_hashkey_no = 0;
autoxs_hashkey* CXSAccessor_hashkeys = NULL;
HV* CXSAccessor_reverse_hashkeys = NULL;

unsigned int CXSAccessor_no_arrayindices = 0;
unsigned int CXSAccessor_free_arrayindices_no = 0;
I32* CXSAccessor_arrayindices = NULL;

unsigned int CXSAccessor_reverse_arrayindices_length = 0;
I32* CXSAccessor_reverse_arrayindices = NULL;


/* implementation section */

I32 get_hashkey_index(const char* key, const I32 len) {
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
    unsigned int extend = 1 + CXSAccessor_no_hashkeys * 2;
    /*printf("extending hashkey storage by %u\n", extend);*/
    unsigned int oldsize = CXSAccessor_no_hashkeys * sizeof(autoxs_hashkey);
    /*printf("previous data size %u\n", oldsize);*/
    autoxs_hashkey* tmphashkeys =
      (autoxs_hashkey*) malloc( oldsize + extend * sizeof(autoxs_hashkey) );
    memcpy(tmphashkeys, CXSAccessor_hashkeys, oldsize);
    free(CXSAccessor_hashkeys);
    CXSAccessor_hashkeys = tmphashkeys;
    CXSAccessor_no_hashkeys += extend;
  }
  return CXSAccessor_free_hashkey_no++;
}


void _resize_array(I32** array, unsigned int* len, unsigned int newlen) {
  unsigned int oldsize = *len * sizeof(I32);
  I32* tmparraymap = (I32*) malloc( newlen * sizeof(I32) );
  memcpy(tmparraymap, *array, oldsize);
  free(*array);
  *array = tmparraymap;
  *len = newlen;
}

void _resize_array_init(I32** array, unsigned int* len, unsigned int newlen, I32 init) {
  unsigned int i;
  unsigned int oldsize = *len * sizeof(I32);
  I32* tmparraymap = (I32*) malloc( newlen * sizeof(I32) );
  memcpy(tmparraymap, *array, oldsize);
  free(*array);
  *array = tmparraymap;
  for (i = *len; i < newlen; ++i)
    (*array)[i] = init;
  *len = newlen;
}


/* this is private, call get_array_index instead */
I32 _new_internal_arrayindex() {
  if (CXSAccessor_no_arrayindices == CXSAccessor_free_arrayindices_no) {
    unsigned int extend = 2 + CXSAccessor_no_arrayindices * 2;
    /*printf("extending array index storage by %u\n", extend);*/
    /*printf("previous data size %u\n", oldsize);*/
    _resize_array(&CXSAccessor_arrayindices, &CXSAccessor_no_arrayindices, extend);
  }
  return CXSAccessor_free_arrayindices_no++;
}

I32 get_internal_array_index(I32 object_ary_idx) {
  I32 new_index;

  if (CXSAccessor_reverse_arrayindices_length <= (unsigned int)object_ary_idx)
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
