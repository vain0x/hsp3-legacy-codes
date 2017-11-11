/*--------------------------------------------------------------------
	imgctl.dll ヘッダー for HSP3 (2006/10/21)
	by Kpan
	http://lhsp.s206.xrea.com/

	imgctl.dll
	by ルーチェ (ruche)
	http://www.ruche-home.net/
--------------------------------------------------------------------*/


/*--------------------------------------------------------------------
	imgctl.dll Macro
--------------------------------------------------------------------*/
;	Error Codes
#define ICERR_NONE $000000
#define ICERR_FILE_OPEN $010001
#define ICERR_FILE_READ $010002
#define ICERR_FILE_WRITE $010003
#define ICERR_FILE_TYPE $010004
#define ICERR_FILE_NULL $010005
#define ICERR_FILE_SEEK $010006
#define ICERR_FILE_SIZE $010007
#define ICERR_PARAM_NULL $020001
#define ICERR_PARAM_SIZE $020002
#define ICERR_PARAM_TYPE $020003
#define ICERR_PARAM_RANGE $020004
#define ICERR_MEM_ALLOC $030001
#define ICERR_MEM_SIZE $030002
#define ICERR_IMG_COMPRESS $040001
#define ICERR_IMG_RLESIZE $040002
#define ICERR_IMG_BITCOUNT $040003
#define ICERR_IMG_AREA $040004
#define ICERR_IMG_RLETOP $040005
#define ICERR_DIB_RLECOMP $050001
#define ICERR_DIB_RLEEXP $050002
#define ICERR_DIB_RLEBIT $050003
#define ICERR_DIB_NULL $050004
#define ICERR_DIB_UPPER16 $050005
#define ICERR_DIB_AREAOUT $050006
#define ICERR_BMP_FILEHEAD $060001
#define ICERR_BMP_HEADSIZE $060002
#define ICERR_BMP_IMGSIZE $060003
#define ICERR_BMP_COMPRESS $060004
#define ICERR_RLE_TOPDOWN $070001
#define ICERR_RLE_DATASIZE $070002
#define ICERR_JPEG_LIBERR $080001
#define ICERR_PNG_LIBERR $090001
#define ICERR_PNG_NOALPHA $090002
#define ICERR_GIF_FILEHEAD $0B0001
#define ICERR_GIF_BLOCK $0B0002
#define ICERR_API_STRETCH $0A0001
#define ICERR_API_SETMODE $0A0002
#define ICERR_API_SECTION $0A0003
#define ICERR_API_COMDC $0A0004
#define ICERR_API_SELOBJ $0A0005
#define ICERR_API_BITBLT $0A0006

;	Image Types
#define IMG_BMP $000001
#define IMG_JPEG $000002
#define IMG_PNG	 $000003
#define IMG_GIF $000004
#define IMG_TIFF $000005
#define IMG_PIC $000006
#define IMG_MAG $000007
#define IMG_PCX $000008
#define IMG_ERROR $FFFFFF
#define IMG_UNKNOWN $000000

;	Enough Buffer Size
#define BUFSIZE_ENOUGH -1

;	DIB Compression
#define BI_RGB 0
#define BI_RLE8 1
#define BI_RLE4 2
#define BI_BITFIELDS 3

;	Turn Types
#define TURN_90 90
#define TURN_180 180
#define TURN_270 270

;	DIBto16BitEx & DIBto8Bit Types
#define TOBIT_DEFAULT $000000
#define TOBIT_ORG $100000
#define TOBIT_DIFF $000001
#define TOBIT_DIFFFS $000002
#define TOBIT_DIFFJJN $000003
#define TOBIT_DIFFX $000101
#define TOBIT_DIFFXFS $000102
#define TOBIT_DIFFXJJN $000103
#define TOBIT_DIFFDX $000201
#define TOBIT_DIFFDXFS $000202
#define TOBIT_DIFFDXJJN $000203

;	DIBto8Bit Flags
#define TO8_DIV_RGB $000000
#define TO8_DIV_LIGHT $000001
#define TO8_SEL_CENTER $000000
#define TO8_SEL_AVGRGB $000100
#define TO8_SEL_AVGPIX $000200
#define TO8_PUT_RGB $000000
#define TO8_PUT_LIGHT $010000
#define TO8_PUT_YUV $020000

;	Resize Flags
#define RESZ_SAME 0
#define RESZ_RATIO -1

;	PNGOPT Flags
#define POF_COMPLEVEL $000001
#define POF_FILTER $000002
#define POF_GAMMA $000004
#define POF_TRNSCOLOR $000008
#define POF_BACKCOLOR $000010
#define POF_TEXT $000020
#define POF_TEXTCOMP $000040
#define POF_INTERLACING $000080
#define POF_TIME $000100
#define POF_TRNSPALETTE $020000
#define POF_TRNSALPHA $040000
#define POF_BACKPALETTE $010000

;	PNGOPT Filters
#define PO_FILTER_NONE $000008
#define PO_FILTER_SUB $000010
#define PO_FILTER_UP $000020
#define PO_FILTER_AVG $000040
#define PO_FILTER_PAETH $000080
#define PO_FILTER_ALL $0000F8

;	PNGOPT Gamma
#define PO_GAMMA_NORMAL 45455
#define PO_GAMMA_WIN PO_GAMMA_NORMAL
#define PO_GAMMA_MAC 55556

;	GIFOPT Flags
#define GOF_LOGICAL $000001
#define GOF_TRNSCOLOR $000008
#define GOF_BACKCOLOR $000010
#define GOF_INTERLACING $000080
#define GOF_BACKPALETTE $010000
#define GOF_TRNSPALETTE $020000
#define GOF_LZWCLRCOUNT $080000
#define GOF_LZWNOTUSE $100000
#define GOF_BITCOUNT $200000

;	GIFANISCENE Flags
#define GSF_LOGICAL $00000001
#define GSF_TRNSCOLOR $00000008
#define GSF_BITCOUNT $00200000
#define GSF_LZWCLRCOUNT $00080000
#define GSF_LZWNOTUSE $00100000
#define GSF_DISPOSAL $00001000
#define GSF_INTERLACING $00000080
#define GSF_TRNSPALETTE $00020000
#define GSF_USERINPUT $00002000

;	GIFANISCENE Disposal Methods
#define GS_DISP_NONE 0
#define GS_DISP_LEAVE 1
#define GS_DISP_BACK 2
#define GS_DISP_PREV 3

;	GIFANIOPT Flags
#define GAF_LOGICAL $00000001
#define GAF_BACKCOLOR $00000010
#define GAF_LOOPCOUNT $00000400
#define GAF_NOTANI $00000800

;	Replace Colors
#define REP_R 0
#define REP_RED REP_R
#define REP_G 1
#define REP_GREEN REP_G
#define REP_B 2
#define REP_BLUE REP_B

;	Raster Operations
#define SRCCOPY $00CC0020
#define SRCPAINT $00EE0086
#define SRCAND $008800C6
#define SRCINVERT $00660046
#define SRCERASE $00440328
#define ROP_NOTSRCCOPY $00330008
#define ROP_NOTSRCERASE $001100A6
#define MERGECOPY $00C000CA
#define MERGEPAINT $00BB0226
#define PATCOPY $00F00021
#define PATPAINT $00FB0A09
#define PATINVERT $005A0049
#define DSTINVERT $00550009
#define BLACKNESS $00000042
#define WHITENESS $00FF0062


/*--------------------------------------------------------------------
	imgctl.dll API
--------------------------------------------------------------------*/
#uselib "imgctl"

;	Standard Functions
#func ImgctlVersion "ImgctlVersion"
#func ImgctlBeta "ImgctlBeta"
#func ImgctlError "ImgctlError"
#func ImgctlErrorClear "ImgctlErrorClear"
#func GetImageType "GetImageType" str, int
#func GetImageMType "GetImageMType" int, int ,int
#func ToDIB "ToDIB" str
#func MtoDIB "MtoDIB" int, int

;	DIB Functions
#func DeleteDIB "DeleteDIB" int
#func HeadDIB "HeadDIB" int, int
#func PaletteDIB "PaletteDIB" int, int, int
#func PixelDIB "PixelDIB" int, int, int
#func ColorDIB "ColorDIB" int
#func GetDIB "GetDIB" int, int, int, int, int
#func MapDIB "MapDIB" int, int, int, int, int
#func DataDIB "DataDIB" int
#func CreateDIB "CreateDIB" int, int
#func CopyDIB "CopyDIB" int
#func CutDIB "CutDIB" int, int, int ,int, int
#func TurnDIB "TurnDIB" int, int
#func DIBto24Bit "DIBto24Bit" int
#func DIBto16Bit "DIBto16Bit" int, int
#func DIBto16BitEx "DIBto16BitEx" int, int, int
#func DIBto8Bit "DIBto8Bit" int, int, int

;	24Bit DIB Functions
#func PasteDIB "PasteDIB" int, int, int, int, int, int, int, int, int, int
#func ResizeDIB "ResizeDIB" int, int, int
#func TurnDIBex "TurnDIBex" int, int, int

;	RLE-DIB Functions
#func IsRLE "IsRLE" int
#func DIBtoRLE "DIBtoRLE" int
#func RLEtoDIB "RLEtoDIB" int

;	Bitmap Functions
#func DIBtoBMP "DIBtoBMP" str, int
#func BMPtoDIB "BMPtoDIB" str
#func BMPMtoDIB "BMPMtoDIB" int, int

;	JPEG Functions
#func DIBtoJPG "DIBtoJPG" str, int, int, int
#func JPGtoDIB "JPGtoDIB" str
#func JPGMtoDIB "JPGMtoDIB" int, int

;	PNG Functions
#func DIBtoPNG "DIBtoPNG" str, int, int
#func DIBtoPNGex "DIBtoPNGex" str, int, int
#func PNGtoDIB "PNGtoDIB" str
#func PNGMtoDIB "PNGMtoDIB" int, int
#func PNGAtoDIB "PNGAtoDIB" str
#func PNGMAtoDIB "PNGMAtoDIB" int, int
#func InfoPNG "InfoPNG" str, int, int, int
#func InfoPNGM "InfoPNGM" int, int, int, int, int

;	GIF Functions
#func DIBtoGIF "DIBtoGIF" str, int, int
#func DIBtoGIFex "DIBtoGIFex" str, int, int
#func DIBtoGIFAni "DIBtoGIFAni" str, int, int, int
#func DIBtoGIFAniEx "DIBtoGIFAniEx" str, int, int, int
#func GIFtoDIB "GIFtoDIB" str
#func GIFMtoDIB "GIFMtoDIB" int, int
#func GIFtoDIBex "GIFtoDIBex" str, int
#func GIFMtoDIBex "GIFMtoDIBex" int, int, int

;	Filter Functions
#func GrayDIB "GrayDIB" int, int
#func ReplaceDIB "ReplaceDIB" int, int, int, int
#func RepaintDIB "RepaintDIB" int, int, int
#func TableDIB "TableDIB" int, int

;	Convert Table Functions
#func ToneDIB "ToneDIB" int, int, int, int
#func ShadeDIB "ShadeDIB" int, int, int, int
#func GammaDIB "GammaDIB" int, int, int, int
#func ContrastDIB "ContrastDIB" int, int, int, int

;	Device Context Functions
#func DIBtoDC "DIBtoDC" int, int, int, int, int, int, int, int, int
#func DIBtoDCex "DIBtoDCex" int, int, int, int, int, int, int, int, int, int, int
#func DIBtoDCex2 "DIBtoDCex2" int, int, int, int, int, int, int, int, int, int, int, int
#func DCtoDIB "DCtoDIB" int, int, int, int, int
