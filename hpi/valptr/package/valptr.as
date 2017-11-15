// valptr plug-in import header

#ifndef IG_HPI_VALPTR_IMPORT_HEADER_AS
#define IG_HPI_VALPTR_IMPORT_HEADER_AS

#if 1
 #define STR_VALPTR_HPI_PATH "valptr.hpi"
#else
 #define STR_VALPTR_HPI_PATH "../Debug/valptr.hpi"
#endif

#regcmd "_hsp3hpi_init@4", STR_VALPTR_HPI_PATH
#cmd valtype		0x100		// 値の型を取得する (vartype 的な)
#cmd new_valptr		0x110		// 値列から valptr を取得する
#cmd valptr_get		0x112		// valptr から値を得る

#endif
