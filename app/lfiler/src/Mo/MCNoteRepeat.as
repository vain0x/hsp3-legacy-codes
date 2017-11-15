// ノート形式ループクラス( マクロの内部で使用 )

#ifndef IG_MODULECLASS_NOTE_REPEAT_AS
#define IG_MODULECLASS_NOTE_REPEAT_AS

#module MCNoteRepeat mStrvar, mStrlen, mIndex, mCount, mStep, mChar, mLoopStr

//------------------------------------------------
// コンストラクタ
//------------------------------------------------
#define global NoteRepeat_new(%1,%2,%3,%4,%5,%6) newmod %1, MCNoteRepeat@, %2, %3, %4, %5, %6
#modinit var p1, int defcnt, int step, int offset, int chr
	dup mStrvar, p1
	mIndex  = offset
	mStrlen = strlen(p1)
	mCount  = defcnt - step		// 即座に + されるので - しておく
	mStep   = step
	mChar   = chr
	sdim mLoopStr, mStrlen + 1
	return
	
//------------------------------------------------
// 次のループへの更新
//------------------------------------------------
#modcfunc NoteRepeat_next
	if ( mIndex >= mStrlen ) { return 0 }	// false
	getstr mLoopStr, mStrvar, mIndex, mChar
	mIndex += strsize
	mCount += mStep
	return ( strsize != 0 )
	
//------------------------------------------------
// 文字列を取得
//------------------------------------------------
#modcfunc NoteRepeat_loopStr_impl
	dup _nrNote, mLoopStr
	return 0
	
//------------------------------------------------
// カウンタを取得
//------------------------------------------------
#modcfunc NoteRepeat_loopCnt
	return mCount
	
#global

	sdim _nrNote@MCNoteRepeat

//------------------------------------------------
// マクロ群
//------------------------------------------------
#define global nrNote %tNoteRepeat _nrNote@MCNoteRepeat(NoteRepeat_loopStr_impl(%p))
#define global nrCnt  %tNoteRepeat NoteRepeat_loopCnt(%p)
#define global NoteRepeat(%1,%2=0,%3=1,%4=0,%5=0) %tbreak %i0 %tcontinue %i0 %tNoteRepeat %i0 %i0 %i0 dim %p : NoteRepeat_new %p,%1,%2,%3,%4,%5 : *%p2 : if ( NoteRepeat_next(%p) == 0 ) { goto *%p1 }
#define global NoteLoop %tcontinue *%o : %tNoteRepeat goto *%p2 : %tbreak *%o : %tNoteRepeat delmod %o : *%o %o0

#endif
