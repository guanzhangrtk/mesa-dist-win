@setlocal
@rem Create distribution.
@if NOT EXIST %devroot%\mesa\build\%abi% GOTO exit
@set /p dist=Create or update Mesa3D distribution package (y/n):
@echo.
@if /I NOT "%dist%"=="y" GOTO exit
@cd %devroot%\%projectname%

@rem Detect if both osmesa classic and gallium are present
@set dualosmesa=0
@IF EXIST %devroot%\mesa\build\%abi%\src\mesa\drivers\osmesa\osmesa.dll IF EXIST %devroot%\mesa\build\%abi%\src\gallium\targets\osmesa\osmesa.dll set dualosmesa=1

@rem Use legacy dist until osmesa classic is removed
@set legacydist=1
@IF %legacydist% EQU 1 GOTO legacydist

@IF %dualosmesa% EQU 0 %mesonloc% install -C $(/usr/bin/cygpath -m ${devroot})/mesa/build/${abi}"
@IF %dualosmesa% EQU 0 GOTO distributed

@if NOT EXIST dist MD dist
@if EXIST dist\%abi% RD /S /Q dist\%abi%
@md dist\%abi%
@MD dist\%abi%\bin
@MD dist\%abi%\lib
@MD dist\%abi%\lib\pkgconfig
@MD dist\%abi%\include
@MD dist\%abi%\bin\osmesa-gallium
@MD dist\%abi%\bin\osmesa-swrast
@MD dist\%abi%\share
@MD dist\%abi%\share\drirc.d
@GOTO mesondist

:legacydist
@if NOT EXIST bin MD bin
@if NOT EXIST lib MD lib
@if NOT EXIST include MD include
@cd bin
@if EXIST %abi% RD /S /Q %abi%
@MD %abi%
@cd %abi%
@IF %dualosmesa% EQU 1 MD osmesa-gallium
@IF %dualosmesa% EQU 1 MD osmesa-swrast
@cd ..\..\lib
@if EXIST %abi% RD /S /Q %abi%
@MD %abi%
@cd ..\include
@if EXIST %abi% RD /S /Q %abi%
@MD %abi%

:mesondist
@IF %dualosmesa% EQU 1 forfiles /p %devroot%\mesa\build\%abi%\src /s /m *.dll /c "cmd /c IF NOT @file==0x22osmesa.dll0x22 copy @path %devroot%\%projectname%\bin\%abi%"
@IF %dualosmesa% EQU 1 copy %devroot%\mesa\build\%abi%\src\mesa\drivers\osmesa\osmesa.dll %devroot%\%projectname%\bin\%abi%\osmesa-swrast\osmesa.dll
@IF %dualosmesa% EQU 1 copy %devroot%\mesa\build\%abi%\src\gallium\targets\osmesa\osmesa.dll %devroot%\%projectname%\bin\%abi%\osmesa-gallium\osmesa.dll
@IF %dualosmesa% EQU 0 forfiles /p %devroot%\mesa\build\%abi%\src /s /m *.dll /c "cmd /c copy @path %devroot%\%projectname%\bin\%abi%"
@IF EXIST %devroot%\%projectname%\bin\%abi%\openglon12.dll IF /I %PROCESSOR_ARCHITECTURE%==AMD64 copy "%ProgramFiles% (x86)\Windows Kits\10\Redist\D3D\%abi%\dxil.dll" %devroot%\%projectname%\bin\%abi%
@IF EXIST %devroot%\%projectname%\bin\%abi%\openglon12.dll IF /I NOT %PROCESSOR_ARCHITECTURE%==AMD64 copy "%ProgramFiles%\Windows Kits\10\Redist\D3D\%abi%\dxil.dll" %devroot%\%projectname%\bin\%abi%
@forfiles /p %devroot%\mesa\build\%abi%\src /s /m *.exe /c "cmd /c copy @path %devroot%\%projectname%\bin\%abi%"
@forfiles /p %devroot%\mesa\build\%abi%\src /s /m *.json /c "cmd /c copy @path %devroot%\%projectname%\bin\%abi%"

@rem Patch Vulkan drivers JSONs
@IF EXIST %devroot%\%projectname%\bin\%abi%\lvp_icd.*.json call %devroot%\%projectname%\buildscript\modules\lavapipejson.cmd

@rem Copy build development artifacts
@xcopy %devroot%\mesa\build\%abi%\*.lib %devroot%\%projectname%\lib\%abi% /E /I /G
@xcopy %devroot%\mesa\build\%abi%\*.a %devroot%\%projectname%\lib\%abi% /E /I /G
@xcopy %devroot%\mesa\build\%abi%\*.h %devroot%\%projectname%\include\%abi% /E /I /G
@echo.

:distributed
@call %devroot%\%projectname%\buildscript\modules\addversioninfo.cmd
@rem IF EXIST %devroot%\%projectname%\lib\%abi%\src\gallium\targets\libgl-gdi\opengl32.dll.a IF EXIST %msysloc%\%MSYSTEM%\bin\strip.exe IF EXIST %msysloc%\%MSYSTEM%\bin\objcopy.exe echo.
@rem IF EXIST %devroot%\%projectname%\lib\%abi%\src\gallium\targets\libgl-gdi\opengl32.dll.a IF EXIST %msysloc%\%MSYSTEM%\bin\strip.exe call %devroot%\%projectname%\buildscript\modules\collectdebugsymbols.cmd

:exit
@endlocal
@pause
@exit