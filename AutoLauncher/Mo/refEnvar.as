#ifndef IG_MODULE_REFERENCE_ENVIRONMENTAL_VARIABLE_AS
#define IG_MODULE_REFERENCE_ENVIRONMENTAL_VARIABLE_AS

#module mod_refEnvar

#uselib "kernel32.dll"
#func   GetEnvironmentVariable@mod_refEnvar   "GetEnvironmentVariableA"   sptr,int,int
#func   SetEnvironmentVariable@mod_refEnvar   "SetEnvironmentVariableA"   sptr,sptr
#func   ExpandEnvironmentStrings@mod_refEnvar "ExpandEnvironmentStringsA" sptr,sptr,int
#cfunc  GetLastError "GetLastError"

#define true  1
#define false 0
#define null  0

//------------------------------------------------
// 環境変数の文字列を得る
// 
// @prm envarName: 変数名
//------------------------------------------------
#defcfunc GetEnvar str envarName,  local lenString
	
	GetEnvironmentVariable envarName, null, 0 : lenString = stat
	if ( lenString == 0 ) { // 環境変数が存在しない
		return "%" + envarName + "%"
	}
	
	AllocResultBuf lenString + 3
	
	GetEnvironmentVariable envarName, varptr(stt_buf), lenString + 1
	return stt_buf
	
//------------------------------------------------
// 環境変数の文字列を変更する
// 
// 存在しない変数名を指定すると、 その変数が新たに作成されます。
// @prm envarName : 変数名
// @prm newString : 代入する文字列
// @result stat   : 成功すると真
//------------------------------------------------
#deffunc SetEnvar str envarName, str newString
	SetEnvironmentVariable envarName, newString
	return stat
	
//------------------------------------------------
// 環境変数を削除する
//------------------------------------------------
#deffunc DestroyEnvar str envarName
	SetEnvironmentVariable envarName, null
	return
	
//------------------------------------------------
// 文字列中に含まれる環境変数を展開する
// 
// 環境変数は %envar-name% の形式で表される。
// '%' は %% で表す。
//------------------------------------------------
#defcfunc ExpandEnvar str _sInput,  local sInput, local lenString
	sInput = _sInput
	
	ExpandEnvironmentStrings varptr(sInput), null, 0 : lenString = stat
	
*LRetry
	AllocResultBuf lenString + 3
	
	ExpandEnvironmentStrings varptr(sInput), varptr(stt_buf), lenString + 1
	
	if ( stat == 0 && GetLastError() == 234 ) { // ERROR_MORE_DATA
		lenString *= 2
		goto *LRetry
	}
	
	return stt_buf
	
//------------------------------------------------
// stt_sResult を確保・拡張する
//------------------------------------------------
#deffunc AllocResultBuf@mod_refEnvar int size
	
	if ( stt_bufsize <= size ) {
		stt_bufsize = size + 1
		
		if ( vartype(stt_buf) != vartype("str") ) {
			sdim stt_buf, stt_bufsize + 1
			
		} else {
			memexpand stt_buf, stt_bufsize + 1
		}
	}
	return
	
#global

	AllocResultBuf@mod_refEnvar 256

#endif
