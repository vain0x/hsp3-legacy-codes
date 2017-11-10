#include "cmd.h"
#include "vp_complex.h"

static int       stt_tmpInt;
static double    stt_tmpDouble;
static complex_t stt_tmpComplex;

//------------------------------------------------
// dimtype
//------------------------------------------------
void dimtype( int vt )
{
	PVal* pval = code_getpval();
	int cntElems[4];
	
	for ( int i = 0; i < 4; i ++ ) {
		cntElems[i] = code_getdi( (i == 0 ? 1 : 0) );
	}
	
	exinfo->HspFunc_dim(
		pval, HSPVAR_FLAG_COMPLEX, 0, cntElems[0], cntElems[1], cntElems[2], cntElems[3]
	);
}

//------------------------------------------------
// complex 構築
//------------------------------------------------
int complex_ctor( void** ppResult, bool bPolar )
{
	if ( !bPolar ) {
		double re = code_getdi( 0 );
		double im = code_getdi( 0 );
		stt_tmpComplex = complex_t( re, im );
		
	} else {
		double r   = code_getd();
		double arg = code_getdd( 1.0 );
		stt_tmpComplex = complex_polar( r, arg );
	}
	
	*ppResult = &stt_tmpComplex;
	return HSPVAR_FLAG_COMPLEX;
}

//------------------------------------------------
// complex 取得
//------------------------------------------------
int complex_info( void** ppResult )
{
	double& result = stt_tmpDouble;
	
	complex_t*       p = code_get_complex();
	ComplexInfo idInfo = static_cast<ComplexInfo>( code_geti() );
	
	switch ( idInfo ) {
		case ComplexInfo_Re:  result = p->getRe();  break;
		case ComplexInfo_Im:  result = p->getIm();  break;
		case ComplexInfo_Abs: result = p->getAbs(); break;
		case ComplexInfo_Arg: result = p->getArg(); break;
		default:
			puterror( HSPERR_ILLEGAL_FUNCTION );
	}
	
	*ppResult = &result;
	return HSPVAR_FLAG_DOUBLE;
}

//------------------------------------------------
// complex 単項演算
//------------------------------------------------
extern int complex_opUnary( void** ppResult, int cmd )
{
	MarkCode_t mark = static_cast<MarkCode_t>(cmd);
	
	complex_t* pResult = &stt_tmpComplex;
	complex_t* p       = code_get_complex();
	
	switch ( mark ) {
		case MarkCode_Plus:  *pResult = +(*p); break;
		case MarkCode_Minus: *pResult = -(*p); break;
		case MarkCode_Inv:   *pResult = ~(*p); break;
		case MarkCode_Neg:
			stt_tmpInt = ( !(*p) ? 1 : 0 );
			*ppResult  = &stt_tmpInt;
			return HSPVAR_FLAG_INT;
		default:
			puterror( HSPERR_ILLEGAL_FUNCTION );
	}
	
	*ppResult = pResult;
	return HSPVAR_FLAG_COMPLEX;
}

//------------------------------------------------
// complex 二項演算
//------------------------------------------------
extern int complex_opBinary( void** ppResult, int cmd )
{
	MarkCode_t mark = static_cast<MarkCode_t>(cmd);
	
	complex_t& result  = stt_tmpComplex;
	complex_t* pResult = &result;
	result             = *code_get_complex();		// 左辺は複製する
	complex_t* prhs    =  code_get_complex();
	
	complex_t& lhs     = result;
	complex_t& rhs     = *prhs;
	
	switch ( mark )
	{
		case MarkCode_Add: result += rhs; break;
		case MarkCode_Sub: result -= rhs; break;
		case MarkCode_Mul: result *= rhs; break;
		case MarkCode_Div: result /= rhs; break;
		case MarkCode_Mod: result %= rhs; break;
			
		case MarkCode_LAnd:
		case MarkCode_LOr:
			stt_tmpInt = ( mark == MarkCode_LAnd
				? ( lhs.isNull() && rhs.isNull() )
				: ( lhs.isNull() && rhs.isNull() )
			);
			*ppResult = &stt_tmpInt;
			return HSPVAR_FLAG_INT;
			
		case MarkCode_Cmp:
			stt_tmpInt = ( lhs.opCmp(rhs) ? 1 : 0 );
			*ppResult  = &stt_tmpInt;
			return HSPVAR_FLAG_INT;
			
		default:
			puterror( HSPERR_ILLEGAL_FUNCTION );
	}
	
	*ppResult = pResult;
	return HSPVAR_FLAG_COMPLEX;
}

//------------------------------------------------
// complex 型タイプ値
//------------------------------------------------
int complex_vt( void** ppResult )
{
	*ppResult = &HSPVAR_FLAG_COMPLEX;
	return HSPVAR_FLAG_INT;
}

//------------------------------------------------
// complex 型の引数を取得する
//------------------------------------------------
complex_t* code_get_complex()
{
	if ( code_getprm() <= PARAM_END ) puterror( HSPERR_NO_DEFAULT );
	if ( mpval->flag != HSPVAR_FLAG_COMPLEX ) puterror( HSPERR_TYPE_MISMATCH );
	
	HspVarProc* vp = exinfo->HspFunc_getproc(HSPVAR_FLAG_COMPLEX);
	complex_t*   p = (complex_t*)( vp->GetPtr(mpval) );
	
	return p;
}
