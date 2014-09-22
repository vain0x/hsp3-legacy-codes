// var_assoc - public header

#ifndef        IG_VAR_ASSOC_HPI_AS
#define global IG_VAR_ASSOC_HPI_AS

#define HPI_VAR_ASSOC_VERSION 1.01	// last update: 2014 09/11

;#define IF_VAR_ASSOC_HPI_RELEASE

#ifndef STR_VAR_ASSOC_HPI_PATH
 #ifdef IF_VAR_ASSOC_HPI_RELEASE
  #define STR_VAR_ASSOC_HPI_PATH "var_assoc.hpi"
 #else
  #define STR_VAR_ASSOC_HPI_PATH "D:/Docs/prg/cpp/MakeHPI/var_assoc/Debug/var_assoc.hpi"
 #endif
#endif

#regcmd "_hpi_assoc@4", STR_VAR_ASSOC_HPI_PATH, 1
#cmd assoc            0x000		// assoc型変数を作成 : assoc型の型タイプ値
#cmd AssocDelete      0x001		// 破棄
#cmd AssocClear       0x002		// 消去 (AllRemove)
#cmd AssocChain       0x003		// 連結
#cmd AssocCopy        0x004		// 複写
#cmd AssocDup         0x004		// 〃 (主に関数形式(複製)で用いる)

#cmd AssocImport      0x010		// 外部変数のインポート
#cmd AssocInsert      0x011		// キーを挿入する
#cmd AssocRemove      0x012		// キーを除去する

#cmd AssocDim         0x020		// 内部変数を配列にする
#cmd AssocClone       0x021		// 内部変数にクローンする

#cmd AssocInfo        0x100		// 内部変数の情報を取得する
#cmd AssocSize        0x101		// 要素数
#cmd AssocExists      0x102		// 存在
#cmd AssocForeachNext 0x103		// foreach: 更新
#cmd AssocResult      0x104		// assoc 返却
#cmd AssocExpr        0x105		// assoc 式

#cmd AssocNull        0x200		// null オブジェクト

//######## 置換マクロ ######################################
#define global AssocInit(%1, %2 = "", %3 = 4) AssocDim %1(%2), %3
;#define global AssocNewCom(%1, %2, %3 = 0, %4 = 0) newcom _temp_com@assoc_mod, %2, %3, %4 : %1 = _temp_com@assoc_mod
;#define global AssocDelCom(%1) delcom AssocRef(%1)

#define global ctype AssocVarType(%1) AssocInfo(%1, VARINFO_FLAG)
#define global ctype AssocVarMode(%1) AssocInfo(%1, VARINFO_MODE)
#define global ctype AssocLen(%1,%2=0)AssocInfo(%1, VARINFO_LEN, %2)
;#define global ctype AssocSize(%1)    AssocInfo(%1, VARINFO_SIZE)		// AssocSize (要素数) と衝突
#define global ctype AssocPtr(%1)     AssocInfo(%1, VARINFO_PT)

#define global AssocForeach(%1, %2 = key_) %tAssocForeach repeat : if ( AssocForeachNext(%1, %2, cnt) ) {
#define global AssocForeachEnd %tAssocForeach } else { break } loop

#define global ctype AssocIsNull(%1) AssocNull(%1)

//######## 定数・マクロ ####################################
#define global AssocVtName "assoc_k"
#define global AssocIndexBak //
#define global AssocIndexFullslice , 0xFABC0000

// 定数
#ifndef VARINFO
#define VARINFO
 #enum global VARINFO_NONE = 0
 #enum global VARINFO_FLAG = VARINFO_NONE
 #enum global VARINFO_MODE
 #enum global VARINFO_LEN
 #enum global VARINFO_SIZE
 #enum global VARINFO_PT
 #enum global VARINFO_MASTER
 #enum global VARINFO_MAX
#endif

//######## モジュール ######################################
#module __assoc

// @static
	dim ref_v@__assoc
;	dimtype ref_assoc@__assoc, assoc

//------------------------------------------------
// assoc 参照 : assoc 要素を変数として参照するラッパ
// 
// @ 書き込み・参照渡し専用
// @ 読み取り禁止
//------------------------------------------------
#define global ctype AssocRef(%1) ref_v@__assoc( AssocClone(%1, ref_v@__assoc) )
;#define global ctype AssocRef(%1) ref_v@__assoc(AssocRef_core@__assoc(%1))
;#defcfunc AssocRef_core@__assoc array self
;	AssocClone ref_v, self()
;	return 0

//------------------------------------------------
// assoc 型の関数用のラッパ
// 
// @ assoc 型のみ返却できる。
// @cf: ex05_func_of_assoc
//------------------------------------------------
;#define global AssocExpr ref_assoc@__assoc
;#defcfunc AssocResult var self
;	if ( vartype(self) != assoc ) { assert : ref_assoc = AssocNull : return 0 }
;	ref_assoc = self		// 直後の AssocExpr で参照される
;	return 0				// ref_assoc の添字となる
;	
#global

#endif
