// opex - public header

#ifndef        IG_OPEX_HPI_AS
#define global IG_OPEX_HPI_AS

#define HPI_OPEX_VERSION 1.2	// last update: 2011 09/12 (Mon)

;#define IF_OPEX_HPI_RELEASE

#ifndef STR_OPEX_HPI_PATH
 #ifdef IF_OPEX_HPI_RELEASE
  #define STR_OPEX_HPI_PATH "opex.hpi"
 #else
  #define STR_OPEX_HPI_PATH "D:/Docs/prg/cpp/MakeHPI/opex/Debug/opex.hpi"
 #endif
#endif

#regcmd "_hsp3typeinfo_opex@4", STR_OPEX_HPI_PATH
#cmd assign      0x000		// 代入
#cmd swap        0x001		// 交換
#cmd clone       0x002		// 弱参照
#cmd cast_to_    0x003		// キャスト
#cmd memberOf    0x004		// メンバ変数の参照
#cmd memberClone 0x005		// メンバ変数のクローン(弱参照)

#cmd short_and   0x100		// 短絡 and
#cmd short_or    0x101		// 短絡 or
#cmd eq_and      0x102		// 比較 and
#cmd eq_or       0x103		// 比較 or
#cmd which       0x104		// 条件演算
#cmd what        0x105		// 分岐演算
#cmd exprs       0x106		// リスト式
#cmd vtname      0x110		// 変数型の名前

#cmd _kw_constptr   0x200	// (kw) 定数ポインタ

#define globala ctype cast_to(%1, %2) cast_to_(%2, %1)
#define global ctype value_cast(%1) cast_to_.(vartype("%1")).

#define global constptr _kw_constptr ||

#endif
