//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//   OLEドラッグ&ドロップをCのみで行うDLL用サンプル
//                             Copyright (C) Copyright 1998,2002 PATA
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

//WZマクロの場合は次行のコメントを外す
//#define	FORWZ4

#ifdef FORWZ4
#include "_wz.h"
#endif
#include <windows.h>
#include <windowsx.h>
#ifdef FORWZ4
#pragma	TXE+
extern "commctrl.dll" {
	#pragma multidef+
	#include <commctrl.h>
	#pragma multidef-
}
extern "OleDragDrop.dll" {
	#include "OleDragDrop.h"
}
extern "Ole32.dll" {
	LONG _stdcall OleInitialize(LPVOID pvReserved);
	void WINAPI OleUninitialize(void);
}
#define	_MAX_PATH	260
#define	HRESULT		DWORD
#define	WM_DROPNOTIFY	(WM_TXUSER+100)
#define	WM_DROPGETDATA	(WM_TXUSER+101)
#define	WM_DROPDRAGEND	(WM_TXUSER+102)
#else
#include <commctrl.h>
#include "OleDragDrop.h"
#define	WM_DROPNOTIFY	(WM_USER+100)
#define	WM_DROPGETDATA	(WM_USER+101)
#define	WM_DROPDRAGEND	(WM_USER+102)
#endif

#define	ARRAYSIZE(a)	(sizeof(a)/sizeof(a[0]))
#define	APCLASSNAME		"OleDnD Sample"
#define	APWNDNAME		"OleDnD Sample"

#ifndef FORWZ4
HINSTANCE _hinstance;

//-----------------------------------------------------------------------------
// 情報メッセージボックスを表示
// IN  format:printf()と同様の書式指定
//-----------------------------------------------------------------------------
void information(const char *format, ... )
{
	char str[10240];
	va_list argptr;
	va_start(argptr, format);
	wvsprintf(str, format, argptr);
	MessageBox(NULL, str, "information", MB_OK);
	va_end(argptr);
}
#endif

//-----------------------------------------------------------------------------
// OLEドロップのターゲット登録
// IN  hwnd:OLEドロップのターゲットとして登録するウィンドウ
//-----------------------------------------------------------------------------
void OleDnDInit(HWND hwnd)
{
	DragAcceptFiles(hwnd,FALSE);
	OleInitialize(NULL);
	UINT cf[] = {CF_HDROP};
	OLE_IDropTarget_RegisterDragDrop(hwnd,WM_DROPNOTIFY,cf,ARRAYSIZE(cf));
}

//-----------------------------------------------------------------------------
// OLEドロップのターゲット破棄
// IN  hwnd:OLEドロップのターゲットとして登録してあるウィンドウ
//-----------------------------------------------------------------------------
void OleDnDUninit(HWND hwnd)
{
	OLE_IDropTarget_RevokeDragDrop(hwnd);
	OleUninitialize();
	DragAcceptFiles(hwnd,TRUE);
}

//-----------------------------------------------------------------------------
// ドラッグ中カーソルがウィンドウ内に入ってきた
//-----------------------------------------------------------------------------
LRESULT OleDropTarget_OnDragEnter(HWND hwnd,LPIDROPTARGET_NOTIFY pdtn,UINT* cf)
{
//	information("OnOleDragEnter");
	return TRUE;
}

//-----------------------------------------------------------------------------
// ドラッグ中カーソルがウィンドウ内で動いた
//-----------------------------------------------------------------------------
LRESULT OleDropTarget_OnDragOver(HWND hwnd,LPIDROPTARGET_NOTIFY pdtn,UINT* cf)
{
//	information("OnOleDragOver");
	if (*cf == CF_HDROP) {	// クリップボードフォーマットが CF_HDROP
		pdtn->dwEffect = DROPEFFECT_COPY;
	} else {
		pdtn->dwEffect = DROPEFFECT_NONE;
	}
	return TRUE;
}

//-----------------------------------------------------------------------------
// ドラッグ中カーソルがウィンドウ外に出た
//-----------------------------------------------------------------------------
LRESULT OleDropTarget_OnDragLeave(HWND hwnd,LPIDROPTARGET_NOTIFY pdtn,UINT* cf)
{
//	information("OnOleDragLeave");
	return TRUE;
}

//-----------------------------------------------------------------------------
// ウィンドウ内でドロップされた
//-----------------------------------------------------------------------------
LRESULT OleDropTarget_OnDrop(HWND hwnd,LPIDROPTARGET_NOTIFY pdtn,UINT* cf)
{
//	information("OnOleDrop");
	const int bufsize = _MAX_PATH*1000*sizeof(char);
	switch (pdtn->cfFormat) {
		case CF_HDROP: {
			SetForegroundWindow(hwnd);
			char* filelist = (char*)malloc(bufsize);
			if (!filelist) break;
			char* p = filelist;
			int num = GetDropFileList((HDROP)pdtn->hMem,filelist,bufsize);
			int i = ListView_GetItemCount(hwnd);
			LVITEM lvi;
			ZeroMemory(&lvi,sizeof(LVITEM));
			lvi.mask = LVIF_TEXT;
			LVFINDINFO lvfi;
			ZeroMemory(&lvfi,sizeof(LVFINDINFO));
			lvfi.flags = LVFI_STRING;
			while (*p != '\0') {
				lvfi.psz = p;
				if (ListView_FindItem(hwnd,-1,&lvfi) < 0) {
					lvi.iItem = i++;
					lvi.pszText = p;
					ListView_InsertItem(hwnd,&lvi);
				}
				p += lstrlen(p) + 1;
			}
			free(filelist);
			break;
		}
	}
	return TRUE;
}

//-----------------------------------------------------------------------------
// OLEドロップのNOTIFY処理
//-----------------------------------------------------------------------------
void OnOleDropTargetNotify(HWND hwnd,IDROPTARGET_NOTIFY_MSG msg,LPIDROPTARGET_NOTIFY pdtn)
{
	static UINT cf = 0;
	switch(msg) {
		case IDROPTARGET_NOTIFY_DRAGENTER:
			cf = pdtn->cfFormat;
			OleDropTarget_OnDragEnter(hwnd,pdtn,&cf);
		case IDROPTARGET_NOTIFY_DRAGOVER:
			OleDropTarget_OnDragOver(hwnd,pdtn,&cf);
			break;
		case IDROPTARGET_NOTIFY_DRAGLEAVE:
			OleDropTarget_OnDragLeave(hwnd,pdtn,&cf);
			break;
		case IDROPTARGET_NOTIFY_DROP:
			OleDropTarget_OnDrop(hwnd,pdtn,&cf);
			break;
	}

}

//-----------------------------------------------------------------------------
// OLEドラッグを開始
//-----------------------------------------------------------------------------
void OnOleDragSource_Start(HWND hwnd)
{
	UINT cf = CF_HDROP;
	OLE_IDropSource_Start(hwnd,WM_DROPGETDATA,WM_DROPDRAGEND,&cf,1,
		DROPEFFECT_COPY|DROPEFFECT_MOVE|DROPEFFECT_LINK|DROPEFFECT_SCROLL);
}

//-----------------------------------------------------------------------------
// OLEドラッグが終了した
//-----------------------------------------------------------------------------
void OnOleDragSource_End(HWND hwnd,HRESULT result)
{
	switch (result) {
		case DRAGDROP_S_DROP:
//			information("ドロップされました");
			break;
		case DRAGDROP_S_CANCEL:
//			information("ドロップがキャンセルされました");
			break;
	}
}

//-----------------------------------------------------------------------------
// OLEドラッグ中のデータ要求への応答
// OUT ret:ドラッグ中のデータが格納されているHANDLE(データなし/エラーはNULL)
//-----------------------------------------------------------------------------
HANDLE OnOleDragSource_GetDate(HWND hwnd)
{
	HANDLE hMem = NULL;
	int num = ListView_GetSelectedCount(hwnd);
	char** dropfilename = (char**)malloc(num*sizeof(char*));
	if (!dropfilename) return NULL;
	int index = ListView_GetNextItem(hwnd,-1,LVNI_SELECTED);
	char sztemp[_MAX_PATH];
	int i;
	for (i=0; i<num; i++) {
		ListView_GetItemText(hwnd,index,0,sztemp,ARRAYSIZE(sztemp));
		dropfilename[i] = strdup(sztemp);
		if (!dropfilename[i]) break;
		index = ListView_GetNextItem(hwnd,index,LVNI_BELOW|LVNI_SELECTED);
	}
	num = i;
	if (num > 0) {
		hMem = CreateDropFileMem(dropfilename,num);
		for (int i=0; i<num; i++) free(dropfilename[i]);
	}
	free(dropfilename);
	return hMem;
}

#define	PROP_OLDPROC	"OldWindowProcedure"
//-----------------------------------------------------------------------------
// ListViewコントロールのウィンドウプロシージャ
//-----------------------------------------------------------------------------
LRESULT CALLBACK wndprocListView(HWND hwnd,UINT message,WPARAM wParam,LPARAM lParam)
{
	static POINT click_pos = {-1,-1};
	static char** dropfilename;
	static BOOL click_on = FALSE;
	static WPARAM keyState = 0;
	switch (message) {
		case WM_DESTROY:
			RemoveProp(hwnd,PROP_OLDPROC);
			break;
		case WM_KEYDOWN:
			if(wParam == VK_ESCAPE)
				PostMessage(GetParent(hwnd),WM_CLOSE,0,0);
			break;
		case WM_LBUTTONDOWN:
			SetCapture(hwnd);
			click_on = TRUE;
			click_pos.x = GET_X_LPARAM(lParam);
			click_pos.y = GET_Y_LPARAM(lParam);
			keyState = wParam;
			break;
		case WM_LBUTTONUP:
			click_on = FALSE;
			ReleaseCapture();
			break;
		case WM_MOUSEMOVE: {
			if (!(wParam & MK_LBUTTON) || !click_on) break;
			int dragcx = GetSystemMetrics(SM_CXDRAG);
			int dragcy = GetSystemMetrics(SM_CYDRAG);
			int dx = GET_X_LPARAM(lParam)-click_pos.x;
			int dy = GET_Y_LPARAM(lParam)-click_pos.y;
			if (dx<0) dx *= -1;
			if (dy<0) dy *= -1;
			if (dx<dragcx && dy<dragcy) break;
			if (ListView_GetSelectedCount(hwnd) < 1) break;
			OnOleDragSource_Start(hwnd);
			return 0L;
		}
		case WM_DROPGETDATA:
			*(HANDLE*)lParam = OnOleDragSource_GetDate(hwnd);
			return 0L;
		case WM_DROPDRAGEND:
			OnOleDragSource_End(hwnd,(HRESULT)wParam);
			return 0L;
		case WM_DROPNOTIFY:
			OnOleDropTargetNotify(hwnd,(IDROPTARGET_NOTIFY_MSG)wParam,(LPIDROPTARGET_NOTIFY)lParam);
			return 0L;
	}
	return CallWindowProc((WNDPROC)GetProp(hwnd,PROP_OLDPROC),hwnd,message,wParam,lParam);
}

//-----------------------------------------------------------------------------
// ListViewコントロールを作成
//-----------------------------------------------------------------------------
HWND CreateListView(HWND hwndbase)
{
	HWND hwnd = CreateWindowEx(0,
		WC_LISTVIEW, NULL,
		WS_CHILD|WS_VISIBLE|LVS_REPORT|LVS_SHOWSELALWAYS,
		0, 0, 0, 0,
		hwndbase,NULL,_hinstance,NULL
	);
	if (!hwnd) return NULL;
	SetProp(hwnd, PROP_OLDPROC, (HANDLE)GetWindowLong(hwnd,GWL_WNDPROC));
#ifdef FORWZ4
	WNDPROC wndprocListViewTXC = txpcodeRegisterCallback(wndprocListView,4);
	SetWindowLong(hwnd,GWL_WNDPROC,(LONG)wndprocListViewTXC);
#else
	SetWindowLong(hwnd,GWL_WNDPROC,(LONG)wndprocListView);
#endif
	ListView_SetExtendedListViewStyle(hwnd,LVS_EX_FULLROWSELECT /*|LVS_EX_GRIDLINES*/);
	LV_COLUMN lvcol;
	lvcol.mask = LVCF_TEXT|LVCF_WIDTH;
	lvcol.pszText = "FileName";
	lvcol.cx = 500;
	ListView_InsertColumn(hwnd, 0, &lvcol);
	return hwnd;
}

//-----------------------------------------------------------------------------
// メインWindowのウィンドウプロシージャ
//-----------------------------------------------------------------------------
LRESULT CALLBACK WndProcMainWindow(HWND hwnd,UINT msg,WPARAM wParam,LPARAM lParam)
{
	static HWND hwndListView;
	switch (msg) {
		case WM_CREATE:
#ifdef FORWZ4
			sysApAdd(hwnd);
#endif
			hwndListView = CreateListView(hwnd);
			OleDnDInit(hwndListView);
			break;
		case WM_DESTROY:
			OleDnDUninit(hwndListView);
			DestroyWindow(hwndListView);
#ifdef FORWZ4
			sysApDelete(hwnd);
#else
			PostQuitMessage(0);
#endif
			break;
		case WM_KEYDOWN:
			if(wParam == VK_ESCAPE)
				PostMessage(hwnd, WM_CLOSE, 0, 0);
			break;
		case WM_SIZE:
			MoveWindow(hwndListView,0,0,LOWORD(lParam),HIWORD(lParam),TRUE);
			break;
		default:
#ifdef FORWZ4
			return sysApDefWindowProc(hwnd,msg,wParam,lParam);
#else
			return DefWindowProc(hwnd,msg,wParam,lParam);
#endif
	}
	return 0L;
}

//-----------------------------------------------------------------------------
// メイン
//-----------------------------------------------------------------------------
#ifdef FORWZ4
HWND TxeMain(wchar* wszCmdline)
#else
int WINAPI WinMain(HINSTANCE hinstance,HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nCmdShow)
#endif
{
	WNDCLASSEX wc;
	HWND hwndMainWnd;
#ifndef FORWZ4
	MSG msg;
	_hinstance = hinstance;
#else
	static FARPROC g_wndproc;
	g_wndproc = txpcodeRegisterCallback(WndProcMainWindow,4);
#endif
	ZeroMemory(&wc,sizeof(WNDCLASSEX));
	wc.hCursor			= LoadCursor(NULL,IDI_APPLICATION);
	wc.hIcon=wc.hIconSm	= LoadIcon(NULL,IDI_APPLICATION);
	wc.lpszMenuName		= NULL;
	wc.lpszClassName	= APCLASSNAME;
	wc.hbrBackground	= (HBRUSH)GetStockObject(BLACK_BRUSH);
	wc.hInstance		= _hinstance;
	wc.style			= 0;
#ifdef FORWZ4
	wc.lpfnWndProc		= (WNDPROC)g_wndproc;
#else
	wc.lpfnWndProc		= (WNDPROC)WndProcMainWindow;
#endif
	wc.cbClsExtra		= 0;
	wc.cbWndExtra		= 0;
	wc.cbSize			= sizeof(WNDCLASSEX);
	RegisterClassEx(&wc);

	hwndMainWnd = CreateWindowEx(
		0,APCLASSNAME,APWNDNAME,
		WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
		(HWND)NULL,(HMENU)NULL,
		_hinstance,(LPSTR)NULL
	);
	ShowWindow(hwndMainWnd,SW_SHOWNORMAL);
	UpdateWindow(hwndMainWnd);
#ifdef FORWZ4
	return hwndMainWnd;
#else
	while (GetMessage(&msg, NULL, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	return 0;
#endif
}
