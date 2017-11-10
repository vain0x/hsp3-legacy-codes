#ifndef IG_COMPLEX_HPI_AS
#define IG_COMPLEX_HPI_AS

#define STR_COMPLEX_HPI_PATH "complex.hpi"

#regcmd "_hsp3hpi_init@4", STR_COMPLEX_HPI_PATH, 1
#cmd complex          0x000

#cmd complex_polar    0x100
#cmd complex_info     0x101
#cmd complex_opUnary  0x102
#cmd complex_opBinary 0x103

#define global ctype complex_re(%1)  complex_info(%1, ComplexInfo_Re)
#define global ctype complex_im(%1)  complex_info(%1, ComplexInfo_Im)
#define global ctype complex_abs(%1) complex_info(%1, ComplexInfo_Abs)
#define global ctype complex_arg(%1) complex_info(%1, ComplexInfo_Arg)

#enum global ComplexInfo_None = 0
#enum global ComplexInfo_Re = ComplexInfo_None
#enum global ComplexInfo_Im
#enum global ComplexInfo_Abs
#enum global ComplexInfo_Arg
#enum global ComplexInfo_Max

#endif
