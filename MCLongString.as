#ifndef        IG_MODULE_CLASS_LONG_STRING_AS
#define global IG_MODULE_CLASS_LONG_STRING_AS

#include "StrBuilder.hsp"

#define global LongStr_new        StrBuilder_new
#define global LongStr_delete     StrBuilder_delete
#define global LongStr_get        StrBuilder_str
#define global LongStr_set        StrBuilder_set
#define global LongStr_add        StrBuilder_append
#define global LongStr_addv       StrBuilder_append_v
#define global LongStr_cat        StrBuilder_append
#define global LongStr_push_back  StrBuilder_append
#define global LongStr_addchar    StrBuilder_append_char
#define global LongStr_erase_back StrBuilder_erase_back
#define global LongStr_reserve    StrBuilder_ensure_capacity
#define global LongStr_expand     StrBuilder_expand_capacity
#define global LongStr_tobuf      StrBuilder_copy_to
#define global LongStr_length     StrBuilder_length
#define global LongStr_bufSize    StrBuilder_capacity
#define global LongStr_dataPtr    StrBuilder_data_ptr
#define global LongStr_clear      StrBuilder_clear
#define global LongStr_chain      StrBuilder_chain
#define global LongStr_copy       StrBuilder_copy

#define global LongStr_lengthLastAddition StrBuilder_strsize

#endif
