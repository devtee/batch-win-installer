setlocal enabledelayedexpansion ENABLEEXTENSIONS
@echo off
cls
rem Initialise variables
set tpath=%~dp0
set uninstallreg64=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
set uninstallreg32=HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
set appinfopath=%tpath%appinfo
set filespath=%tpath%files

rem confirm appinfo and filespath subfolders exist and create if not 
if not exist "%appinfopath%\" mkdir "%appinfopath%\"
if not exist "%filespath%\" mkdir "%filespath%\"

rem check presence of wget and xidel.exe in the folder 
if not exist "%tpath%wget.exe" (
   echo wget.exe missing. wget for windows can be downloaded at https://eternallybored.org/misc/wget/
   echo Exiting...
   goto end
)
if not exist "%tpath%xidel.exe" (
   echo xidel.exe missing. Xidel can be downloaded at https://www.videlibri.de/xidel.html
   echo Exiting...
   goto end
)

rem call settings.bat
call "%tpath%!settings.bat"

echo.
echo %introtitle1%
echo %introtitle2%
echo -------------------------------------------------------------------------------------
echo.

rem space for future command line arguements
rem for %%v in ("help" "/help" "--help") do (
rem     if %%v=="%1" goto helptext
rem )	
rem goto admintest

rem :helptext
rem echo Usage : Batch-Software-Installer

:admintest

rem Test if this batch file is running as Administrator and exit if not
NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO Administrator PRIVILEGES Detected.
    goto checkifonline
) ELSE (
    ECHO Note You need to run this batch file as an administrator. This will now exit...
	goto end
)

rem Test if we can access the Internet and download any files needed 

:checkifonline

set IPaddress=8.8.8.8
ping -n 2 %IPaddress% | find "TTL=" > nul
IF %ERRORLEVEL% EQU 1 (
     echo No Online Access
	 set online=N
) ELSE (
   echo Internet Access Detected. 
   echo.
   set online=Y
)
set IPaddress=


:tempsoftwarelist

for %%a in (temp-software-list.bat temp-uninstall-list.bat temp-online-list.bat) do (
   if exist "%tpath%!\%%a" del "%tpath%!\%%a"
)

rem If online and onlineupdate.progam variable is set to Y then download latest version 

set "software-config-missing-list="
set "software-config-present-list="


for %%v in (%softwarelist%) do (
  if exist "%appinfopath%\%%v-install.txt" (
     set software-config-present-list=%%v !software-config-present-list!
  )	 
  
  if not exist "%appinfopath%\%%v-install.txt" (
     	 if "%online%"=="Y" (
		   echo Configuration file for %%v missing. Downloading %%v
		   "%tpath%wget" -q --progress=bar -O "%appinfopath%\%%v-install.txt" "%onlineupdateurl%%%v-install.txt"  
           "%tpath%wget" -q --progress=bar -O "%appinfopath%\%%v-uninstall.txt" "%onlineupdateurl%%%v-uninstall.txt"
		   findstr /b /c:"set followup." "%appinfopath%!\%%v-install.txt"
		   IF !ERRORLEVEL! EQU 0 (
		     "%tpath%wget" -q --progress=bar -O "%appinfopath%\%%v.reg" "%onlineupdateurl%%%v.reg"
		   )	 
           set software-config-missing-list=%%v !software-config-missing-list!
		 )
		 
		 if "%online%"=="N" (
		   echo Configuration file for %%v missing. 
		   echo Download or copy configuration files to the appinfo subfolder or enable online acccess and re-run this batch file.
		   echo This will now exit....
		   goto end
		 )  
  )
)


if not "!software-config-present-list!"=="" (
    for %%v in (%software-config-present-list%) do (
      findstr /b /c:"set onlineupdate." "%appinfopath%!\%%v-install.txt">>"%tpath%!temp-online-list.bat"
	  echo.>>"%tpath%!temp-online-list.bat"
	  findstr /b /c:"set followup." "%appinfopath%!\%%v-install.txt">>"%tpath%!temp-online-list.bat"
	)  
call "%tpath%!temp-online-list.bat"

echo Downloading configuration updates 
for %%v in (%software-config-present-list%) do (
  if "!onlineupdate.%%v!"=="Y" (
	 "%tpath%wget" -q --progress=bar -O "%appinfopath%\%%v-install.txt" "%onlineupdateurl%%%v-install.txt"
 	 "%tpath%wget" -q --progress=bar -O "%appinfopath%\%%v-uninstall.txt" "%onlineupdateurl%%%v-uninstall.txt"
     if not "!followup.%%v!"=="" "%tpath%wget" -q --progress=bar --show-progress -O "%appinfopath%\%%v.reg" "%onlineupdateurl%%%v.reg"
  )
)

) 



for %%v in (%softwarelist%) do (
  type "%appinfopath%!\%%v-install.txt">>"%tpath%!temp-software-list.bat"
  echo.>>"%tpath%!temp-software-list.bat"
  type "%appinfopath%!\%%v-uninstall.txt">>"%tpath%!temp-uninstall-list.bat"
) 

call "%tpath%!temp-software-list.bat"

set "missinglist="
echo.
echo Checking software installers in %orgname% folder 
echo --------------------------------------------------
echo.
for %%v in (%softwarelist%) do (
  if exist "%filespath%\!exe.%%v!" (
    echo Installer for !name.%%v! found - !exe.%%v!
  ) ELSE (
	echo [101;93m MISSING [0m - Installer for !name.%%v! - !exe.%%v! not found 
    set missinglist=%%v !missinglist!
  )	
)

if "%missinglist%"=="" (
   echo.
   echo All installers found.
   echo.
   goto mainmenu
)   

rem if missing software download if online

if "%online%"=="N" (
  echo.
  echo Download or copy installers to the %orgname% folder or enable online acccess and re-run this batch file.
  echo This will now exit....
  goto end
)

if "%online%"=="Y" (
  echo.
  echo.
  echo Downloading missing installers since online...
  echo.
  for %%v in (!missinglist!) do (
    echo Downloading !name.%%v!...
    if not exist "%filespath%\!exe.%%v!" "%tpath%wget" -q --progress=bar --show-progress -O "%filespath%\!exe.%%v!" "!url.%%v!"
	echo.
  )
)  


:mainmenu

echo.
echo %introtitle1%
echo %introtitle2%
echo -------------------------------------------------------------------------------------
echo.
echo  1. Install all Software ONLY (use for first time install on new machine)
echo. 2. Check if software installed on machine and update if necessary (use to refresh software on machine)

if "%online%"=="Y" (
echo  3. Check online for latest versions from software's websites ONLY
echo.
echo  4. Exit Menu
echo.
CHOICE /N /C:1234 /M "Select option (1 to 4)"

IF ERRORLEVEL 4 goto end
IF ERRORLEVEL 3 goto checkonline

) ELSE (
echo.
echo  3. Exit Menu
echo.
CHOICE /N /C:123 /M "Select option (1 to 3)"

IF ERRORLEVEL 3 goto end

)

IF ERRORLEVEL 2 goto checkupdate
IF ERRORLEVEL 1 goto installsoftware

goto end 

:checkonline

if exist "%tpath%temp.txt" del "%tpath%temp.txt"

if "%online%"=="N" (
  echo No Online access...exiting
  goto end
) 

for %%v in (%softwarelist%) do (
  "%tpath%xidel.exe" --silent "!regurl.%%v!" -e "!regexp.%%v!">"%tpath%temp.txt"
  set /p latestver.%%v=<"%tpath%temp.txt"
  if !latestver.%%v! == !pkgver.%%v! (
    echo No Update Needed  - Latest version of !name.%%v! online is !latestver.%%v!
  )	ELSE (
    echo [42mNEW Version Found[0m - Latest version of !name.%%v! online is !latestver.%%v!
  )
) 

echo.
echo Returning to main menu
pause
goto mainmenu


:installsoftware

for %%v in (%softwarelist%) do (
  "%filespath%\!exe.%%v!" !arg.%%v!
  if not "!followup.%%v!"=="" (!followup.%%v!)
)

goto end

:checkupdate

set "updatelist="
set "toinstall-list="
set "software-reverse-list="

for %%a in (%softwarelist%) do (
   set software-reverse-list=%%a !software-reverse-list!
)

for %%v in (%software-reverse-list%) do (
  if exist "!chk.%%v!" (
   for /F "delims=" %%a in ('reg query "!regsearch.%%v!" /d /f "!regtext.%%v!" /s ^| FINDSTR /c:"CurrentVersion\\Uninstall\\"') do set "installreg=%%a"
   for /F "tokens=3 delims= " %%h in ('reg query "!installreg!" /f "DisplayVersion" ^| FINDSTR /c:"DisplayVersion"') do set "installedver=%%h"
   
   if "!installedver!" == "!ver.%%v!" (
      echo Latest version !installedver! of !name.%%v! is installed.
   ) ELSE (
      echo UPDATE NEEDED - Need to update !name.%%v! from !installedver! to !ver.%%v!
	  set updatelist=%%v !updatelist!
      if !regsearch.%%v! == %uninstallreg64% (
	    for /F "tokens=7 delims=\" %%d in ("!installreg!") do set "installguid=%%d"
	  ) else (
	    for /F "tokens=8 delims=\" %%d in ("!installreg!") do set "installguid=%%d"
	  )
	  set installreg.%%v=!installguid!
    )
  ) ELSE (
      echo NOT INSTALLED - !name.%%v! is not installed.
	  set toinstall-list=%%v !toinstall-list!
  )	  
)
echo. 

if "!toinstall-list!" == "" (
   echo No software to be installed
   ) ELSE (
   echo.
   echo List of software to be installed 
   echo ---------------------------------------
   for %%b in (!toinstall-list!) do (echo !name.%%b!)
   echo.
   )

if "!updatelist!" == "" (
   echo No software needs to be updated
   if "!toinstall-list!" == "" goto end
   ) ELSE ( 
   rem echo update list is !updatelist!
   echo.
   echo List of software to be Updated
   echo ----------------------------------
   for %%b in (!updatelist!) do (echo !name.%%b!)
   )

echo.
echo  NOTE : Please close all software before updating!!
echo. 
echo  1. Install Missing Software AND update Installed Software
echo  2. Update Installed Software ONLY
echo  3. Exit
CHOICE /N /C:123 /M "Select option (1 to 3)"
IF ERRORLEVEL 3 goto end
IF ERRORLEVEL 2 goto updatesoftware
IF ERRORLEVEL 1 goto installmissingsoftware

goto end

:installmissingsoftware

if "!toinstall-list!" == "" (
   echo Nothing to Install
) else (
  echo installist is !toinstall-list!   
  for %%v in (!toinstall-list!) do (
    echo installing "%%v" - !name.%%v! 
    "%filespath%\!exe.%%v!" !arg.%%v!
	if not "!followup.%%v!"=="" (!followup.%%v!) 
  )
)
pause

:updatesoftware

if "!updatelist!" == "" (
   echo Nothing to Update 
) else (
  echo updatelist is !updatelist!   
  call "%tpath%!temp-uninstall-list.bat"
  
  for %%k in (!updatelist!) do ( 
    rem echo Removing !name.%%k! - !installreg.%%k! - using !uninstall.%%k!
	echo Removing !name.%%k! - !installreg.%%k!
    !uninstall.%%k!
   echo !name.%%k! uninstalled.
   echo.
  )
  for %%k in (!updatelist!) do ( 
   echo Installing Latest !name.%%k! 
    "%filespath%\!exe.%%k!" !arg.%%k!
	if not "!followup.%%k!"=="" (!followup.%%k!)
  )
)

:end

for %%v in (temp-software-list.bat temp-uninstall-list.bat temp.txt) do if exist "%tpath%!%%v" del "%tpath%!%%v"
rem del "%tpath%!temp-software-list.bat"
rem del "%tpath%!temp-uninstall-list.bat"
endlocal
pause