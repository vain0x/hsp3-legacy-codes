// dllmain.cpp : DLL アプリケーションのエントリ ポイントを定義します。
#include "stdafx.h"

#define EXPORT(T) extern "C" __declspec(dllexport) T WINAPI

EXPORT(toml_table_t*) tomlc99_parse(char* conf, char* errbuf, int errbuf_size) {
	return toml_parse(conf, errbuf, errbuf_size);
}

EXPORT(void) tomlc99_free(toml_table_t* tab) {
	toml_free(tab);
}

EXPORT(const char*) tomlc99_key_in(toml_table_t* tab, int keyidx) {
	return toml_key_in(tab, keyidx);
}

EXPORT(const char*) tomlc99_raw_in(toml_table_t* tab, const char* key) {
	return toml_raw_in(tab, key);
}

EXPORT(toml_array_t*) tomlc99_array_in(toml_table_t* tab, const char* key) {
	return toml_array_in(tab, key);
}

EXPORT(toml_table_t*) tomlc99_table_in(toml_table_t* tab, const char* key) {
	return toml_table_in(tab, key);
}

/* Return the array kind: 't'able, 'a'rray, 'v'alue */
EXPORT(char) tomlc99_array_kind(toml_array_t* arr) {
	return toml_array_kind(arr);
}

/* For array kind 'v'alue, return the type of values
   i:int, d:double, b:bool, s:string, t:time, D:date, T:timestamp
   0 if unknown
*/
EXPORT(char) tomlc99_array_type(toml_array_t* arr) {
	return toml_array_type(arr);
}

EXPORT(int) tomlc99_array_nelem(toml_array_t* arr) {
	return toml_array_nelem(arr);
}

EXPORT(const char*) tomlc99_array_key(toml_array_t* arr) {
	return toml_array_key(arr);
}

EXPORT(int) tomlc99_table_nkval(toml_table_t* tab) {
	return toml_table_nkval(tab);
}

EXPORT(int) tomlc99_table_narr(toml_table_t* tab) {
	return toml_table_narr(tab);
}

EXPORT(int) tomlc99_table_ntab(toml_table_t* tab) {
	return toml_table_ntab(tab);
}

EXPORT(const char*) tomlc99_table_key(toml_table_t* tab) {
	return toml_table_key(tab);
}

EXPORT(const char*) tomlc99_raw_at(toml_array_t* arr, int idx) {
	return toml_raw_at(arr, idx);
}

EXPORT(toml_array_t*) tomlc99_array_at(toml_array_t* arr, int idx) {
	return toml_array_at(arr, idx);
}

EXPORT(toml_table_t*) tomlc99_table_at(toml_array_t* arr, int idx) {
	return toml_table_at(arr, idx);
}

EXPORT(int) tomlc99_rtos(const char* s, char** ret) {
	return toml_rtos(s, ret);
}

EXPORT(int) tomlc99_rtob(const char* s, int* ret) {
	int success = toml_rtob(s, ret);
	*ret = *ret ? 1 : 0;
	return success;
}

EXPORT(int) tomlc99_rtoi(const char* s, int* ret) {
	int64_t value;
	int success = toml_rtoi(s, &value);
	*ret = (int)value;
	return success;
}

EXPORT(int) tomlc99_rtod(const char* s, double* ret) {
	return toml_rtod(s, ret);
}

EXPORT(int) tomlc99_rtots(const char* s, toml_timestamp_t* ret) {
	// FIXME: not supported
	return -1;
}

BOOL APIENTRY DllMain(HMODULE hModule,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved
)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

