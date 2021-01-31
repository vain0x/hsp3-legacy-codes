// char - VarProc "char"

#include "dllmain.h"
#include "vp_char.h"
#include "subcmd.h"

// 変数の宣言
short  HSPVAR_FLAG_CHAR;
static HspVarProc *g_pHvpChar;

// 関数の宣言
extern int   GetVarSize_Char(const PVal *pval);
extern void *HspVarChar_Cnv      (const void *buffer, int flag);
extern void *HspVarChar_CnvCustom(const void *buffer, int flag);
extern PDAT *HspVarChar_GetPtr    (PVal *pval);
extern int   HspVarChar_GetVarSize(PVal *pval);
extern void *HspVarChar_ArrayObjectRead(PVal *pval, int *mptype);
extern void  HspVarChar_ArrayObject (PVal *pval);
extern void  HspVarChar_ObjectWrite (PVal *pval, void *data, int vflag);
extern void  HspVarChar_ObjectMethod(PVal *pval);
extern void  HspVarChar_Alloc(PVal *pval, const PVal *pval2);
extern void  HspVarChar_Free (PVal *pval);
extern int   HspVarChar_GetSize (const PDAT *pdat);
extern int   HspVarChar_GetUsing(const PDAT *pdat);
extern void *HspVarChar_GetBlockSize(PVal *pval, PDAT *pdat, int *size);
extern void  HspVarChar_AllocBlock  (PVal *pval, PDAT *pdat, int  size);
extern void  HspVarChar_Set(PVal *pval, PDAT *pdat, const void *in);
extern void  HspVarChar_AddI (PDAT *pdat, const void *val);
extern void  HspVarChar_SubI (PDAT *pdat, const void *val);
extern void  HspVarChar_MulI (PDAT *pdat, const void *val);
extern void  HspVarChar_DivI (PDAT *pdat, const void *val);
extern void  HspVarChar_ModI (PDAT *pdat, const void *val);
extern void  HspVarChar_AndI (PDAT *pdat, const void *val);
extern void  HspVarChar_OrI  (PDAT *pdat, const void *val);
extern void  HspVarChar_XorI (PDAT *pdat, const void *val);
extern void  HspVarChar_EqI  (PDAT *pdat, const void *val);
extern void  HspVarChar_NeI  (PDAT *pdat, const void *val);
extern void  HspVarChar_GtI  (PDAT *pdat, const void *val);
extern void  HspVarChar_LtI  (PDAT *pdat, const void *val);
extern void  HspVarChar_GtEqI(PDAT *pdat, const void *val);
extern void  HspVarChar_LtEqI(PDAT *pdat, const void *val);
extern void  HspVarChar_RrI  (PDAT *pdat, const void *val);
extern void  HspVarChar_LrI  (PDAT *pdat, const void *val);

// PVal::ptが必要とするbytesを取得する (PVal::sizeの値)
static int GetVarSize_Char(const PVal *pval)
{
	int size;
	size = pval->len[1];
	if ( pval->len[2] ) size *= pval->len[2];
	if ( pval->len[3] ) size *= pval->len[3];
	if ( pval->len[4] ) size *= pval->len[4];
	size *= sizeof(char);
	return size;
}

// Convert another->char
static void *HspVarChar_Cnv(const void *buffer, int flag)
{
	static char stt_conv;
	
	switch ( flag ) {
	case HSPVAR_FLAG_STR:
		stt_conv = ((char *)buffer)[0];		// 先頭の文字コード
		break;
		
	case HSPVAR_FLAG_DOUBLE:
		stt_conv = (char)(*(double *)buffer);
		break;
		
	case HSPVAR_FLAG_INT:
		stt_conv = (char)(*(int *)buffer & 0xFF);	// 縮小する
		break;
		
	default:
		if ( flag == HSPVAR_FLAG_CHAR ) {
			stt_conv = *(char *)buffer;
			break;
		} else {
			puterror( HSPVAR_ERROR_TYPEMISS );
		}
	}
	return &stt_conv;
}

// Convert char->another
static void *HspVarChar_CnvCustom(const void *buffer, int flag)
{
	switch ( flag ) {
		case HSPVAR_FLAG_STR:
		{
			static char stt_str[3];
			stt_str[0] = ((char *)buffer)[0];
			return stt_str;
		}
		case HSPVAR_FLAG_DOUBLE:
		{
			static double stt_double;
			stt_double = (double)(*(char *)buffer);
			return &stt_double;
		}
		case HSPVAR_FLAG_INT:
		{
			static int stt_int;
			stt_int = (int)(*(char *)buffer);
			return &stt_int;
		}
		default:
			if ( flag == HSPVAR_FLAG_CHAR ) {
				static char stt_char;
				stt_char = *(char *)buffer;
				return &stt_char;
				
			} else {
				puterror( HSPVAR_ERROR_TYPEMISS );
			}
	}
	return (void *)buffer;
}

// Core
static PDAT *HspVarChar_GetPtr(PVal *pval)
{
	return (PDAT *)(&pval->pt[pval->offset]);
}

// PValの変数メモリを確保する
static void HspVarChar_Alloc(PVal *pval, const PVal *pval2)
{
	// pval はすでに解放済み。(または未確保)
	// pval2 がNULLの場合は、普通に確保する。
	// pval2 が指定されている場合は、pval2の内容を継承する

	int size;
	char *pt;
	char *fv;
	
	if (pval->len[1] < 1) pval->len[1] = 1;	// 配列を最低1は確保する
	size       = GetVarSize_Char(pval) + 1;	// '\0' 分のサイズを確保しておく
	pval->flag = HSPVAR_FLAG_CHAR;
	pval->mode = HSPVAR_MODE_MALLOC;
	pt         = hspmalloc(size);
	
	// 0クリア
	memset( pt, 0, size );
	
	// 継承する
	if ( pval2 != NULL ) {
		memcpy(pt, pval2->pt, pval2->size);	// 持っていたデータをコピー
		hspfree(pval2->pt);					// 元のバッファを解放
	}
	pval->pt   = pt;
	pval->size = size;
	return;
}

// PValの変数メモリを解放する
static void HspVarChar_Free(PVal *pval)
{
	if ( pval->mode == HSPVAR_MODE_MALLOC ) {
		hspfree(pval->pt);
	}
	pval->pt   = NULL;
	pval->mode = HSPVAR_MODE_NONE;
	return;
}

// Size
static int HspVarChar_GetSize(const PDAT *pval)
{
	return sizeof(char);
}

// 使用状況(varuse)
static int HspVarChar_GetUsing( const PDAT *pdat )
{
	return TRUE;
}

// ブロックサイズを取得
static void *HspVarChar_GetBlockSize(PVal *pval, PDAT *pdat, int *size)
{
	*size = pval->size - ( (char *)pdat - (char *)pval->pt );
	return (pdat);
}

// 可変長のため
static void HspVarChar_AllocBlock(PVal *pval, PDAT *pdat, int size)
{
	return;
}

// =
static void HspVarChar_Set(PVal *pval, PDAT *pdat, const void *in)
{
	*((char *)pdat)       = *((char *)in);
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// +
static void HspVarChar_AddI(PDAT *pdat, const void *val)
{
	*((char *)pdat)      += *((char *)val);
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// -
static void HspVarChar_SubI(PDAT *pdat, const void *val)
{
	*((char *)pdat)      -= *((char *)val);
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// *
static void HspVarChar_MulI(PDAT *pdat, const void *val)
{
	*((char *)pdat)      *= *((char *)val);
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// /
static void HspVarChar_DivI(PDAT *pdat, const void *val)
{
	char c = *((char *)val);
	if ( c == 0 ) puterror(HSPVAR_ERROR_DIVZERO); // 0除算エラー
	*((char *)pdat)      /= c;
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// \ mod
static void HspVarChar_ModI(PDAT *pdat, const void *val)
{
	char c = *((char *)val);
	if (c == 0) puterror(HSPVAR_ERROR_DIVZERO);
	*((char *)pdat)      %= c;
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// & and
static void HspVarChar_AndI(PDAT *pdat, const void *val)
{
	*((char *)pdat)      &= *((char *)val);
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// | or
static void HspVarChar_OrI(PDAT *pdat, const void *val)
{
	*((char *)pdat)      |= *((char *)val);
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// ^ xor
static void HspVarChar_XorI(PDAT *pdat, const void *val)
{
	*((char *)pdat)      ^= *((char *)val);
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// ==
static void HspVarChar_EqI(PDAT *pdat, const void *val)
{
	*((char *)pdat)       = ( *((char *)pdat) == *((char *)val) );
	g_pHvpChar->aftertype = HSPVAR_FLAG_INT;
}

// !=
static void HspVarChar_NeI(PDAT *pdat, const void *val)
{
	*((char *)pdat)       = ( *((char *)pdat) != *((char *)val) );
	g_pHvpChar->aftertype = HSPVAR_FLAG_INT;
}

// >
static void HspVarChar_GtI( PDAT *pdat, const void *val)
{
	*((char *)pdat)       = ( *((char *)pdat) > *((char *)val) );
	g_pHvpChar->aftertype = HSPVAR_FLAG_INT;
}

// <
static void HspVarChar_LtI(PDAT *pdat, const void *val)
{
	*((char *)pdat)       = ( *((char *)pdat) < *((char *)val) );
	g_pHvpChar->aftertype = HSPVAR_FLAG_INT;
}

// >=
static void HspVarChar_GtEqI(PDAT *pdat, const void *val)
{
	*((char *)pdat)       = ( *((char *)pdat) >= *((char *)val) );
	g_pHvpChar->aftertype = HSPVAR_FLAG_INT;
}

// <=
static void HspVarChar_LtEqI(PDAT *pdat, const void *val)
{
	*((char *)pdat)       = ( *((char *)pdat) <= *((char *)val) );
	g_pHvpChar->aftertype = HSPVAR_FLAG_INT;
}

// >>
static void HspVarChar_RrI(PDAT *pdat, const void *val)
{
	*((char *)pdat)     >>= *((char *)val);
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// <<
static void HspVarChar_LrI(PDAT *pdat, const void *val)
{
	*((char *)pdat)     <<= *((char *)val);
	g_pHvpChar->aftertype = HSPVAR_FLAG_CHAR;
}

// HspVarProc初期化関数
void HspVarChar_Init(HspVarProc *p)
{
	HSPVAR_FLAG_CHAR = p->flag;
	g_pHvpChar       = p;
	
	p->Cnv          = HspVarChar_Cnv;
	p->CnvCustom    = HspVarChar_CnvCustom;
	p->GetPtr       = HspVarChar_GetPtr;
	
//	p->ArrayObjectRead = ;
//	p->ArrayObject  = ;
//	p->ObjectWrite  = ;
//	p->ObjectMethod = ;
	
	p->Alloc        = HspVarChar_Alloc;
	p->Free         = HspVarChar_Free;
	
	p->GetSize      = HspVarChar_GetSize;
	p->GetUsing     = HspVarChar_GetUsing;
	
	p->GetBlockSize = HspVarChar_GetBlockSize;
	p->AllocBlock   = HspVarChar_AllocBlock;
	
	p->Set          = HspVarChar_Set;
	
	p->AddI         = HspVarChar_AddI;
	p->SubI         = HspVarChar_SubI;
	p->MulI         = HspVarChar_MulI;
	p->DivI         = HspVarChar_DivI;
	p->ModI         = HspVarChar_ModI;
	
	p->AndI         = HspVarChar_AndI;
	p->OrI          = HspVarChar_OrI;
	p->XorI         = HspVarChar_XorI;
	
	p->EqI          = HspVarChar_EqI;
	p->NeI          = HspVarChar_NeI;
	p->GtI          = HspVarChar_GtI;
	p->LtI          = HspVarChar_LtI;
	p->GtEqI        = HspVarChar_GtEqI;
	p->LtEqI        = HspVarChar_LtEqI;
	
	p->RrI          = HspVarChar_RrI;
	p->LrI          = HspVarChar_LrI;
	
	p->vartype_name	= "char";	// 型名
	p->version      = 0x001;	// VarType RuntimeVersion(0x100 = 1.0)
	p->support      = HSPVAR_SUPPORT_STORAGE	// サポート状況フラグ(HSPVAR_SUPPORT_*)
	                | HSPVAR_SUPPORT_FLEXARRAY
					| HSPVAR_SUPPORT_VARUSE;
	p->basesize     = sizeof(char);	// 1つのデータのbytes / 可変長の時は-1
}
