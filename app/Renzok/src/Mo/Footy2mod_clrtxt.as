// Footy2 module - Clrtxt

#ifndef __FOOTY2_MODULE_CLRTXT__
#define __FOOTY2_MODULE_CLRTXT__

#include "ClrtxtOptimize.as"

#module footy2mod_clrtxt mFootyID, mClrtxt, mClrtxtLen, mLibPath

#ifndef __UserDefHeader__
 #define exdel(%1) exist(%1):if(strsize >= 0){delete(%1)}
 #define note %tNoteLoop _note_noteloop
 #define noteIndex _noteIndex_noteloop
 #define ntcnt _ntcnt_noteloop
 #define ntlen _ntlen_noteloop
 #define NoteRepeat(%1,%2=0,%3=ntcnt,%4=1,%5=0,%6=0)%tbreak%i0 %tcontinue%i0 %tNoteLoop noteIndex=%5:%3=%2:ntlen=strlen@hsp(%1):%s3%s4 %i0 *%i:getstr@hsp note,%1,noteIndex,%6:noteindex+=strsize
 #define NoteLoop %tcontinue *%o:%tNoteLoop %p3+=%p2 : if(noteIndex < ntlen){goto@hsp *%o} %o0%o0:if(0){%tbreak *%o : %tNoteLoop %p=(%p^0xFFFFFFFF)+1} %o0
 #define true  1
 #define false 0
 #define MAX_PATH 260
#endif

// コンストラクタ
#modinit int footyID
	mFootyID   = footyID
	mClrtxtLen = 0
	sdim mClrtxt, 3200
	sdim mLibPath, MAX_PATH
	return
	
// デストラクタ
#modterm local filelist
	// キャッシュを削除する
	if ( peek( mLibPath ) ) {
		sdim       filelist, MAX_PATH * 5
		dirlist    filelist, mLibPath +"*.clrtxtcache", 2	// リスト
		NoteRepeat filelist
			exdel mLibPath + note	// あれば削除
		NoteLoop
	}
	return
	
// ライブラリの位置を設定する
#modfunc F2CT_SetClrtxtLibPath str path, local len
	mLibPath = path
	len      = strlen( mLibPath )
	
	// 最後を \ で終わらないようにする
	if ( peek(mLibPath, len - 1) == '\\' || peek(mLibPath, len - 1) == '/' ) {
		poke mLibPath, len - 1, 0
	}
	return
	
// Clrtxt を追加する
#modfunc F2CT_AppendClrtxt str p2, local path, local filedata, local len
	path = p2
	if ( peek(path, 1, 1) != ':' ) {	// 相対パスの場合
		path = mLibPath +"\\"+ path		// ライブラリ・パスを付加
	}
	
	exist path
	if ( strsize < 0 ) { return true }
	
	// キャッシュがあるかどうか
	exist path +"cache"
	sdim  filedata, strsize + 1
	if ( strsize > 0 ) {			// ある場合
		
		// 読み込むだけでいい
		bload path +"cache", filedata, strsize
		len = strsize
		
	// 未キャッシュ
	} else {
		ClrtxtOptimize path, filedata		// 最適化する
		bsave path +"cache", filedata, stat	// キャッシュする
		len = stat
	}
	
	// 追加する
	mClrtxt    += filedata
	mClrtxtLen += len
	
	return false
	
// Clrtxt を取り除く
#modfunc F2CT_RemoveClrtxt str p2
	ClrtxtDelete mClrtxt, p2		// 削除したサイズか 負数(エラー) を返す
	if ( stat >= 0 ) {
		;
	} else {
		// 問題発生
		logmes "[ERROR] Clrtxt の削除に失敗しました"
		return true
	}
	return false
	
// FootyにClrtxtを反映させる
#modfunc F2CT_InputClrtxt
	ClrtxtInput mFootyID, mClrtxt, true		// 入力
	return
	
#global

#endif
