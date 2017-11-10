#ifndef IG_VARPROC_COMPLEX_H
#define IG_VARPROC_COMPLEX_H

#include "hsp3plugin_custom.h"
#include "stComplex.h"

typedef basic_complex<double> complex_t;

inline complex_t complex_polar( double r, double arg )
{
	return basic_complex_polar<double>( r, arg );
}

extern void HspVarComplex_Init( HspVarProc* p );

extern short HSPVAR_FLAG_COMPLEX;

#endif
