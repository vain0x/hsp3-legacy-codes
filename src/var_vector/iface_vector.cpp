// vector

#include "vt_vector.h"
#include "cmd_vector.h"
#include "sub_vector.h"

#include "mod_varutil.h"
#include "reffuncResult.h"

using namespace hpimod;

static int hpi_termfunc( int option );

static int   ProcSttmCmd( int cmd );
static int   ProcFuncCmd( int cmd, PDAT** ppResult );
static int ProcSysvarCmd( int cmd, PDAT** ppResult );

//------------------------------------------------
// HPI登録関数
//------------------------------------------------
EXPORT void WINAPI hpi_vector( HSP3TYPEINFO* info )
{
	hsp3sdk_init( info );			// SDKの初期化(最初に行なって下さい)

	info->cmdfunc  = hpimod::cmdfunc<ProcSttmCmd>;
	info->reffunc  = hpimod::reffunc<ProcFuncCmd, ProcSysvarCmd>;
	info->termfunc = hpi_termfunc;

	// 新規型を追加
	registvar(-1, HspVarVector_Init);
	return;
}

//------------------------------------------------
// 終了時
//------------------------------------------------
static int hpi_termfunc( int option )
{
	VectorCmdTerminate();
	return 0;
}

//------------------------------------------------
// 命令
//------------------------------------------------
static int ProcSttmCmd( int cmd )
{
	switch ( cmd ) {
		case 0x000: code_dimtypeEx( g_vtVector ); break;
		case 0x001: VectorDelete(); break;
		case 0x002: VectorChain(false);  break;
		case 0x003: VectorChain(true);   break;

		case 0x010: VectorDimtype();   break;
		case 0x011: VectorClone(); break;

		case VectorCmdId::Insert:
		case VectorCmdId::InsertOne:
		case VectorCmdId::PushFront:
		case VectorCmdId::PushBack:
		case VectorCmdId::Remove :
		case VectorCmdId::RemoveOne:
		case VectorCmdId::PopFront:
		case VectorCmdId::PopBack:
		case VectorCmdId::Replace:
		case VectorCmdId::Swap:
		case VectorCmdId::Rotate:
		case VectorCmdId::Reverse:
		case VectorCmdId::Relocate:
			VectorContainerProc( cmd );
			break;
		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}

	return RUNMODE_RUN;
}

//------------------------------------------------
// 関数
//------------------------------------------------
static int ProcFuncCmd( int cmd, PDAT** ppResult )
{
	switch ( cmd ) {
		case 0x000: return VectorMake( ppResult );
		case 0x003: return VectorDup( ppResult );

		case 0x011:
			VectorClone();
			return SetReffuncResult( ppResult, 0 );

		case VectorCmdId::Insert:
		case VectorCmdId::InsertOne:
		case VectorCmdId::PushFront:
		case VectorCmdId::PushBack:
		case VectorCmdId::Remove :
		case VectorCmdId::RemoveOne:
		case VectorCmdId::PopFront:
		case VectorCmdId::PopBack:
		case VectorCmdId::Replace:
		case VectorCmdId::Swap:
		case VectorCmdId::Rotate:
		case VectorCmdId::Reverse:
		case VectorCmdId::Relocate:
			return VectorContainerProcFunc( ppResult, cmd );

		case 0x100:	return VectorVarinfo( ppResult );
		case 0x101:	return VectorSize( ppResult );
		case 0x102: return VectorSlice( ppResult );
		case 0x103: return VectorSliceOut( ppResult );
		case 0x104: return VectorResult( ppResult );
		case 0x105: return VectorExpr( ppResult );
		case 0x106: return VectorJoin( ppResult );
		case 0x107: return VectorAt( ppResult );
		case 0x200: return VectorIsNull( ppResult );

		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}

//------------------------------------------------
// システム変数
//------------------------------------------------
static int ProcSysvarCmd( int cmd, PDAT** ppResult )
{
	switch ( cmd ) {
		case 0x000: return SetReffuncResult( ppResult, g_vtVector );

		case 0x200:
		{
			static vector_t const VectorNull { nullptr };
			*ppResult = VtTraits::asPDAT<vtVector>(const_cast<vector_t*>(&VectorNull));
			return g_vtVector;
		}

		default:
			puterror( HSPERR_UNSUPPORTED_FUNCTION );
	}
	return 0;
}
