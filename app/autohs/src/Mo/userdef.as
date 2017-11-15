#ifndef ig_userdef_as
#define ig_userdef_as

#define global true 1
#define global false 0
#define global null 0
#define global max_path 260

#define global ctype loword(%1) ((%1) & 0xFFFF)
#define global ctype hiword(%1) (loword((%1) >> 16))
#define global ctype makelong(%1, %2) (loword(%1) | (loword(%2) << 16))

#define global ctype lolobyte(%1) ((%1) & 0xFF)
#define global ctype makeword(%1, %2) (lolobyte(%1) | lolobyte(%2) << 8)
#define global ctype makelong2(%1, %2, %3, %4) makelong(makeword(%1, %2), makeword(%3, %4))

#endif
