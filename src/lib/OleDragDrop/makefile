#DebugCopt	= -R -v -DDEBUG	# 追加 C コンパイルオプション
#DebugLopt	= -v

ccopt	= bcc32 -4 -C -H -Hc -O -O1 -ps -RT- -w -w-aus -wuse -w-par -x- $(DebugCopt)
#ccopt	= bcc32 -4 -C -H -Hc -O -O1 -RT- -w -w-aus -wuse -w-par -x- $(DebugCopt)
#-------------------------------------- コンパイラ(GUI)
CC	= $(ccopt) -tWE
#-------------------------------------- コンパイラ(DLL)
CCDLL	= $(ccopt) -tWDE
#-------------------------------------- コンパイラ(CONSOLE)
#CC	= $(ccopt) -WC
#-------------------------------------- リンカ共通指定
#linkopt	= @ilink32 -c -m -P $(DebugLopt)
linkopt	= c:\progra~1\bcc55\bin\ilink32 -C -c -m -P $(DebugLopt)
#-------------------------------------- リンカ(GUI)
linkexe	= $(linkopt) -Tpe -aa
#-------------------------------------- リンカ(CONSOLE)
linkcon	= $(linkopt) -Tpe -ap
#-------------------------------------- リンカ(DLL)
linkdll	= $(linkopt) -Tpd -aa
#-------------------------------------- インポート
implib  = @implib
#-------------------------------------- リソースコンパイラ
RC	= @Brc32
#-------------------------------------- リソースコンパイラ
AS	= tasm32

dnd.exe: dnd.obj OleDragDrop.lib
    $(CC) dnd.obj OleDragDrop.lib NOEH32.LIB
    del *.tds

OleDragDrop.lib: OleDragDrop.obj OleDragDrop.h OleDragDrop.res
    $(CCDLL) OleDragDrop.obj NOEH32.LIB -eOleDragDrop.dll
    $(RC) OleDragDrop.res OleDragDrop.dll
    $(implib) OleDragDrop.lib OleDragDrop.dll

clean:
	del *.obj & \
	del *.exe & \
	del *.log & \
	del *.tds & \
	del *.res & \
	del *.lib & \
	del *.dll > nul

.asm.obj:
      $(AS) $(AFLAGS) $&.asm

.c.exe:
      $(CC) $(CFLAGS) $&.c

.c.obj:
      $(CC) $(CFLAGS) /c $&.c

.cpp.exe:
      $(CC) $(CFLAGS) $&.cpp

.cpp.obj:
      $(CC) $(CPPFLAGS) /c $&.cpp

.rc.res:
      $(RC) $(RFLAGS) /r $&

.SUFFIXES: .exe .obj .asm .c .res .rc

