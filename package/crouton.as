// crouton - import header

#ifndef        IG_CROUTON_HPI_IMPORT_HEADER_AS
#define global IG_CROUTON_HPI_IMPORT_HEADER_AS

#define HPI_CROUTON_VERSION 1.00	// last update: 2014

;#define IF_CROUTON_HPI_RELEASE

#ifdef IF_CROUTON_HPI_RELEASE
 #define STR_OBSIDIAN_HPI_PATH "crouton.hpi"
#else
 #define STR_CROUTON_HPI_PATH "C:/Users/Owner/Source/Repos/crouton/Debug/crouton.hpi";"D:/Docs/prg/cpp/MakeHPI/obsidian/Debug/obsidian.hpi"
#endif

//************************************************
// include base plugins
//************************************************
#define STR_CALL_HPI_PATH       STR_CROUTON_HPI_PATH
#define STR_VAR_ASSOC_HPI_PATH  STR_CROUTON_HPI_PATH
#define STR_VAR_VECTOR_HPI_PATH STR_CROUTON_HPI_PATH
#define STR_OPEX_HPI_PATH       STR_CROUTON_HPI_PATH

;#include "./call/call.as"
;#include "call/call_modcls.as"
;#include "call/mod_operator.as"
;#include "var_assoc/var_assoc.as"
;#include "var_vector/var_vector.as"
;#include "opex/opex.as"

//************************************************
// crouton commands
//***********************************************
/*
#regcmd "_hsp3typeinfo_crouton@4", STR_CROUTON_HPI_PATH
#cmd apply          0x000		// apply( f, [...] )
//#cmd call_arguments 0x200

#cmd VectorMap      0x120
#cmd VectorFoldL    0x121
#cmd VectorFoldR    0x122
#cmd VectorUnfoldL  0x123
#cmd VectorUnfoldR  0x124
#cmd VectorFilter   0x125
//*/

//************************************************
// crouton macros
//************************************************

#endif
