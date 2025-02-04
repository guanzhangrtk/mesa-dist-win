@echo off
@cd /d "%~dp0"
@set "ERRORLEVEL="
@CMD /C EXIT 0
@"%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >nul 2>&1
@if NOT "%ERRORLEVEL%"=="0" (
@IF "%*"=="" powershell -Command Start-Process """%0""" -Verb runAs 2>nul
@IF NOT "%*"=="" powershell -Command Start-Process """%0""" """%*""" -Verb runAs 2>nul
@GOTO exit
)
:--------------------------------------
@IF "%*"=="" TITLE Mesa3D system-wide deployment utility
@IF "%*"=="" echo -------------------------------------
@IF "%*"=="" echo Mesa3D system-wide deployment utility
@IF "%*"=="" echo -------------------------------------
@IF "%*"=="" echo This deployment utility targets systems without working GPUs and any use case
@IF "%*"=="" echo where hardware accelerated OpenGL is not available. This mainly covers
@IF "%*"=="" echo virtual machines in cloud environments and RDP connections. It can be
@IF "%*"=="" echo used to replace Microsoft Windows inbox OpenGL 1.1 software render
@IF "%*"=="" echo driver with Mesa3D OpenGL drivers.
@IF "%*"=="" echo.
@IF "%*"=="" pause
@set mesaloc=%~dp0
@IF "%mesaloc:~-1%"=="\" set mesaloc=%mesaloc:~0,-1%

:deploy
@IF "%*"=="" cls
@set mesainstalled=1
@IF NOT EXIST "%windir%\System32\mesadrv.dll" IF NOT EXIST "%windir%\System32\graw.dll" IF NOT EXIST "%windir%\System32\osmesa.dll" set mesainstalled=0

@echo -------------------------------------
@echo Mesa3D system-wide deployment utility
@echo -------------------------------------
@echo Please make a deployment choice:
@echo 1. Core desktop OpenGL drivers
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x64\swr*.dll" echo 2. Core desktop OpenGL drivers + Intel swr
@echo 3. Mesa3D off-screen render driver gallium version (osmesa gallium)
@IF NOT EXIST "%mesaloc%\x86\osmesa.dll" IF NOT EXIST "%mesaloc%\x64\osmesa.dll" echo 4. Mesa3D off-screen render driver classic version (osmesa swrast)
@echo 5. Mesa3D graw test framework
@IF %mesainstalled%==1 echo 6. Update system-wide deployment
@IF %mesainstalled%==1 echo 7. Remove system-wide deployments (uninstall)
@IF "%1"=="" IF %mesainstalled%==1 echo 8. Exit
@IF "%1"=="" IF %mesainstalled%==0 echo 6. Exit
@IF "%1"=="" set /p deploychoice=Enter choice:
@IF NOT "%1"=="" echo Enter choice:%1
@IF NOT "%1"=="" set deploychoice=%1
@if "%deploychoice%"=="1" GOTO desktopgl
@if "%deploychoice%"=="2" GOTO desktopgl
@if "%deploychoice%"=="3" GOTO osmesa
@if "%deploychoice%"=="4" GOTO osmesa
@if "%deploychoice%"=="5" GOTO graw
@if "%deploychoice%"=="6" IF %mesainstalled%==1 GOTO update
@if "%deploychoice%"=="7" IF %mesainstalled%==1 GOTO uninstall
@IF "%1"=="" if "%deploychoice%"=="8" IF %mesainstalled%==1 GOTO bye
@IF "%1"=="" if "%deploychoice%"=="6" IF %mesainstalled%==0 GOTO bye
@echo Invaild entry
@IF "%1"=="" pause
@IF "%1"=="" GOTO deploy
@IF NOT "%1"=="" GOTO exit

:desktopgl
@if "%deploychoice%"=="2" if /I NOT %PROCESSOR_ARCHITECTURE%==AMD64 echo Invalid choice. swr driver is only supported on X64/AMD64 systems.
@if "%deploychoice%"=="2" if /I NOT %PROCESSOR_ARCHITECTURE%==AMD64 IF "%1"=="" pause
@if "%deploychoice%"=="2" if /I NOT %PROCESSOR_ARCHITECTURE%==AMD64 IF "%1"=="" GOTO deploy
@if "%deploychoice%"=="2" if /I NOT %PROCESSOR_ARCHITECTURE%==AMD64 IF NOT "%1"=="" GOTO exit
@if "%deploychoice%"=="2" if /I %PROCESSOR_ARCHITECTURE%==AMD64 IF NOT EXIST "%mesaloc%\x64\swr*.dll" echo Invalid choice. swr driver is not included in this Mesa3D release package.
@if "%deploychoice%"=="2" if /I %PROCESSOR_ARCHITECTURE%==AMD64 IF NOT EXIST "%mesaloc%\x64\swr*.dll" IF "%1"=="" pause
@if "%deploychoice%"=="2" if /I %PROCESSOR_ARCHITECTURE%==AMD64 IF NOT EXIST "%mesaloc%\x64\swr*.dll" IF "%1"=="" GOTO deploy
@if "%deploychoice%"=="2" if /I %PROCESSOR_ARCHITECTURE%==AMD64 IF NOT EXIST "%mesaloc%\x64\swr*.dll" IF NOT "%1"=="" GOTO exit
@IF /I %PROCESSOR_ARCHITECTURE%==X86 copy "%mesaloc%\x86\opengl32.dll" "%windir%\System32\mesadrv.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 copy "%mesaloc%\x86\opengl32.dll" "%windir%\SysWOW64\mesadrv.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 copy "%mesaloc%\x64\opengl32.dll" "%windir%\System32\mesadrv.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%mesaloc%\x86\libglapi.dll" copy "%mesaloc%\x86\libglapi.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x86\libglapi.dll" copy "%mesaloc%\x86\libglapi.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x64\libglapi.dll" copy "%mesaloc%\x64\libglapi.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%mesaloc%\x86\dxil.dll" copy "%mesaloc%\x86\dxil.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x86\dxil.dll" copy "%mesaloc%\x86\dxil.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x64\dxil.dll" copy "%mesaloc%\x64\dxil.dll" "%windir%\System32"
@if "%deploychoice%"=="2" IF /I %PROCESSOR_ARCHITECTURE%==AMD64 copy "%mesaloc%\x64\swr*.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /v "DLL" /t REG_SZ /d "mesadrv.dll" /f
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /v "DriverVersion" /t REG_DWORD /d "1" /f
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /v "Flags" /t REG_DWORD /d "1" /f
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /v "Version" /t REG_DWORD /d "2" /f
@REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /v "DLL" /t REG_SZ /d "mesadrv.dll" /f
@REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /v "DriverVersion" /t REG_DWORD /d "1" /f
@REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /v "Flags" /t REG_DWORD /d "1" /f
@REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /v "Version" /t REG_DWORD /d "2" /f
@echo.
@echo Desktop OpenGL drivers deploy complete.
@IF "%1"=="" pause
@IF "%1"=="" GOTO deploy
@IF NOT "%1"=="" GOTO exit

:osmesa
@if "%deploychoice%"=="3" IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%mesaloc%\x86\osmesa.dll" copy "%mesaloc%\x86\osmesa.dll" "%windir%\System32"
@if "%deploychoice%"=="3" IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x86\osmesa.dll" copy "%mesaloc%\x86\osmesa.dll" "%windir%\SysWOW64"
@if "%deploychoice%"=="3" IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x64\osmesa.dll" copy "%mesaloc%\x64\osmesa.dll" "%windir%\System32"
@if "%deploychoice%"=="3" IF EXIST %mesaloc%\x86\osmesa.dll IF EXIST %mesaloc%\x64\osmesa.dll GOTO doneosmesa
@if "%deploychoice%"=="4" IF EXIST %mesaloc%\x86\osmesa.dll IF EXIST %mesaloc%\x64\osmesa.dll echo osmesa swrast is not available on its own.
@if "%deploychoice%"=="4" IF EXIST %mesaloc%\x86\osmesa.dll IF EXIST %mesaloc%\x64\osmesa.dll IF "%1"=="" pause
@if "%deploychoice%"=="4" IF EXIST %mesaloc%\x86\osmesa.dll IF EXIST %mesaloc%\x64\osmesa.dll IF "%1"=="" GOTO deploy
@if "%deploychoice%"=="4" IF EXIST %mesaloc%\x86\osmesa.dll IF EXIST %mesaloc%\x64\osmesa.dll IF NOT "%1"=="" GOTO exit
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%mesaloc%\x86\libglapi.dll" copy "%mesaloc%\x86\libglapi.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x86\libglapi.dll" copy "%mesaloc%\x86\libglapi.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x64\libglapi.dll" copy "%mesaloc%\x64\libglapi.dll" "%windir%\System32"
@if "%deploychoice%"=="3" set osmesatype=gallium
@if "%deploychoice%"=="4" set osmesatype=swrast
@IF /I %PROCESSOR_ARCHITECTURE%==X86 copy "%mesaloc%\x86\osmesa-%osmesatype%\osmesa.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 copy "%mesaloc%\x86\osmesa-%osmesatype%\osmesa.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 copy "%mesaloc%\x64\osmesa-%osmesatype%\osmesa.dll" "%windir%\System32"

:doneosmesa
@echo.
@echo Off-screen render driver deploy complete.
@IF "%1"=="" pause
@IF "%1"=="" GOTO deploy
@IF NOT "%1"=="" GOTO exit

:graw
@IF /I %PROCESSOR_ARCHITECTURE%==X86 copy "%mesaloc%\x86\graw.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 copy "%mesaloc%\x86\graw.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 copy "%mesaloc%\x64\graw.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%mesaloc%\x86\graw_null.dll" copy "%mesaloc%\x86\graw_null.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x86\graw_null.dll" copy "%mesaloc%\x86\graw_null.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x64\graw_null.dll" copy "%mesaloc%\x64\graw_null.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%mesaloc%\x86\libglapi.dll" copy "%mesaloc%\x86\libglapi.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x86\libglapi.dll" copy "%mesaloc%\x86\libglapi.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%mesaloc%\x64\libglapi.dll" copy "%mesaloc%\x64\libglapi.dll" "%windir%\System32"
@echo.
@echo graw framework deploy complete.
@IF "%1"=="" pause
@IF "%1"=="" GOTO deploy
@IF NOT "%1"=="" GOTO exit

:update
@IF %mesainstalled%==0 echo.
@IF %mesainstalled%==0 echo Error: No Mesa3D drivers installed.
@IF %mesainstalled%==0 IF "%1"=="" pause
@IF %mesainstalled%==0 IF "%1"=="" GOTO deploy
@IF %mesainstalled%==0 IF NOT "%1"=="" GOTO exit

@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%windir%\System32\mesadrv.dll" copy "%mesaloc%\x86\opengl32.dll" "%windir%\System32\mesadrv.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\mesadrv.dll" copy "%mesaloc%\x86\opengl32.dll" "%windir%\SysWOW64\mesadrv.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\System32\mesadrv.dll" copy "%mesaloc%\x64\opengl32.dll" "%windir%\System32\mesadrv.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%windir%\System32\libglapi.dll" IF EXIST "%mesaloc%\x86\libglapi.dll" copy "%mesaloc%\x86\libglapi.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\libglapi.dll" IF EXIST "%mesaloc%\x86\libglapi.dll" copy "%mesaloc%\x86\libglapi.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\System32\libglapi.dll" IF EXIST "%mesaloc%\x64\libglapi.dll" copy "%mesaloc%\x64\libglapi.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%windir%\System32\dxil.dll" IF EXIST "%mesaloc%\x86\dxil.dll" copy "%mesaloc%\x86\dxil.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\dxil.dll" IF EXIST "%mesaloc%\x86\dxil.dll" copy "%mesaloc%\x86\dxil.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\System32\dxil.dll" IF EXIST "%mesaloc%\x64\dxil.dll" copy "%mesaloc%\x64\dxil.dll" "%windir%\System32"
@IF EXIST "%windir%\System32\swrAVX.dll" copy "%mesaloc%\x64\swrAVX.dll" "%windir%\System32"
@IF EXIST "%windir%\System32\swrAVX2.dll" copy "%mesaloc%\x64\swrAVX2.dll" "%windir%\System32"
@IF EXIST "%windir%\System32\swrSKX.dll" copy "%mesaloc%\x64\swrSKX.dll" "%windir%\System32"
@IF EXIST "%windir%\System32\swrKNL.dll" copy "%mesaloc%\x64\swrKNL.dll" "%windir%\System32"

@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%windir%\System32\graw.dll" copy "%mesaloc%\x86\graw.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\graw.dll" copy "%mesaloc%\x86\graw.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\System32\graw.dll" copy "%mesaloc%\x64\graw.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%windir%\System32\graw.dll" IF EXIST "%mesaloc%\x86\graw_null.dll" copy "%mesaloc%\x86\graw_null.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\graw.dll" IF EXIST "%mesaloc%\x86\graw_null.dll" copy "%mesaloc%\x86\graw_null.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\System32\graw.dll" IF EXIST "%mesaloc%\x64\graw_null.dll" copy "%mesaloc%\x64\graw_null.dll" "%windir%\System32"

@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%windir%\System32\osmesa.dll" IF EXIST "%mesaloc%\x86\osmesa.dll" copy "%mesaloc%\x86\osmesa.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\System32\osmesa.dll" IF EXIST "%mesaloc%\x86\osmesa.dll" copy "%mesaloc%\x86\osmesa.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\System32\osmesa.dll" IF EXIST "%mesaloc%\x64\osmesa.dll" copy "%mesaloc%\x64\osmesa.dll" "%windir%\System32"
@IF EXIST "%windir%\System32\osmesa.dll" IF EXIST "%mesaloc%\x86\osmesa.dll" IF EXIST "%mesaloc%\x64\osmesa.dll" GOTO doneupdate
@set BYTES=10000000
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%windir%\System32\osmesa.dll" for %%f in ("%windir%\System32\osmesa.dll") do @set BYTES=%%~zf
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%windir%\System32\osmesa.dll" IF %BYTES% GTR 10000000 copy "%mesaloc%\x86\osmesa-gallium\osmesa.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==X86 IF EXIST "%windir%\System32\osmesa.dll" IF %BYTES% LSS 10000000 copy "%mesaloc%\x86\osmesa-swrast\osmesa.dll" "%windir%\System32"
@set BYTES=10000000
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\osmesa.dll" for %%f in ("%windir%\SysWOW64\osmesa.dll") do @set BYTES=%%~zf
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\osmesa.dll" IF %BYTES% GTR 10000000 copy "%mesaloc%\x86\osmesa-gallium\osmesa.dll" "%windir%\SysWOW64"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\osmesa.dll" IF %BYTES% LSS 10000000 copy "%mesaloc%\x86\osmesa-swrast\osmesa.dll" "%windir%\SysWOW64"
@set BYTES=10000000
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\System32\osmesa.dll" for %%f in ("%windir%\System32\osmesa.dll") do @set BYTES=%%~zf
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\System32\osmesa.dll" IF %BYTES% GTR 10000000 copy "%mesaloc%\x64\osmesa-gallium\osmesa.dll" "%windir%\System32"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\System32\osmesa.dll" IF %BYTES% LSS 10000000 copy "%mesaloc%\x64\osmesa-swrast\osmesa.dll" "%windir%\System32"

:doneupdate
@echo.
@echo Update complete.
@IF "%1"=="" pause
@IF "%1"=="" GOTO deploy
@IF NOT "%1"=="" GOTO exit

:uninstall
@REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\OpenGLDrivers\MSOGL" /f
@IF EXIST "%windir%\System32\mesadrv.dll" del "%windir%\System32\mesadrv.dll"
@IF EXIST "%windir%\System32\libglapi.dll" del "%windir%\System32\libglapi.dll"
@IF EXIST "%windir%\System32\dxil.dll" del "%windir%\System32\dxil.dll"
@IF EXIST "%windir%\System32\graw.dll" del "%windir%\System32\graw.dll"
@IF EXIST "%windir%\System32\graw_null.dll" del "%windir%\System32\graw_null.dll"
@IF EXIST "%windir%\System32\osmesa.dll" del "%windir%\System32\osmesa.dll"
@IF EXIST "%windir%\System32\swrAVX.dll" del "%windir%\System32\swrAVX.dll"
@IF EXIST "%windir%\System32\swrAVX2.dll" del "%windir%\System32\swrAVX2.dll"
@IF EXIST "%windir%\System32\swrSKX.dll" del "%windir%\System32\swrSKX.dll"
@IF EXIST "%windir%\System32\swrKNL.dll" del "%windir%\System32\swrKNL.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\mesadrv.dll" del "%windir%\SysWOW64\mesadrv.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\libglapi.dll" del "%windir%\SysWOW64\libglapi.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\dxil.dll" del "%windir%\SysWOW64\dxil.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\osmesa.dll" del "%windir%\SysWOW64\osmesa.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\graw.dll" del "%windir%\SysWOW64\graw.dll"
@IF /I %PROCESSOR_ARCHITECTURE%==AMD64 IF EXIST "%windir%\SysWOW64\graw_null.dll" del "%windir%\SysWOW64\graw_null.dll"
@echo.
@echo Uninstall complete.
@IF "%1"=="" pause
@IF "%1"=="" GOTO deploy
@IF NOT "%1"=="" GOTO exit

:bye
@echo Good Bye!
@IF "%1"=="" pause

:exit
