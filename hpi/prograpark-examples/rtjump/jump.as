// jump - import header

#ifndef IG_JUMP_HPI_AS
#define IG_JUMP_HPI_AS

#regcmd "_hsp3typeinit_jump@4", "jump.hpi"
#cmd jump 0x000

#if 1

	lb = *a
	jump *a		// ラベル
	jump lb		// ラベル型変数
	stop
	
*a
	mes "ジャンプ成功！  (*a)"
	return
	
#endif

#endif
