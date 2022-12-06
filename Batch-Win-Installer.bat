setlocal enabledelayedexpansion ENABLEEXTENSIONS
@echo off
cls
rem Batch-Win-Installer - install/update Windows programs from a list and check program websites for latest versions
rem Copyright (C) 2022 Dev Anand Teelucksingh batchwininstaller@gmail.com
rem Used by the Trinidad and Tobago Computer Society - learn more at https://ttcs.tt/ 
rem
rem This program is free software: you can redistribute it and/or modify it under the terms of the  
rem GNU General Public License as published by the Free Software Foundation, 
rem either version 3 of the License, or rem (at your option) any later version.
rem
rem This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
rem
rem See license.txt for the GNU General Public License. If missing, see <https://www.gnu.org/licenses/

rem Initialise variables
set tpath=%~dp0
set uninstallreg64=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
set uninstallreg32=HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
set appinfopath=%tpath%appinfo
set filespath=%tpath%files
set wgetexe=%tpath%wget/wget.exe
set xidelexe=%tpath%xidel/xidel.exe

rem confirm appinfo and filespath subfolders exist and create if not 
if not exist "%appinfopath%\" mkdir "%appinfopath%\"
if not exist "%filespath%\" mkdir "%filespath%\"

rem check presence of wget and xidel.exe in the folder 
if not exist "%wgetexe%" (
   echo wget.exe in this subfolder is missing. wget for windows can be downloaded at https://eternallybored.org/misc/wget/
   echo Exiting...
   goto end
)
if not exist "%xidelexe%" (
   echo xidel.exe in this xidel subfolder is missing. Xidel can be downloaded at https://www.videlibri.de/xidel.html  
   echo Exiting...
   goto end
)

if not exist "%tpath%settings.bat" (
   echo settings.bat is missing. Exiting ..
   goto end
)    

call "%tpath%!settings.bat"

:licensetext

echo.
echo Batch-Win-Installer %bwiver% - install/update Windows programs from a list 
echo                             and check program websites for latest versions
echo.
echo Copyright (C) 2022 Dev Anand Teelucksingh 
echo Used by the Trinidad and Tobago Computer Society - learn more at https://ttcs.tt/ 
echo Project page : https://github.com/devtee/batch-win-installer
echo Email comments to batchwininstaller@gmail.com
echo -------------------------------------------------------------------------------------
echo This program is free software: you can redistribute it and/or modify
echo it under the terms of the GNU General Public License as published by
echo the Free Software Foundation, either version 3 of the License, or
echo (at your option) any later version.
echo.
echo This program is distributed in the hope that it will be useful,
echo but WITHOUT ANY WARRANTY; without even the implied warranty of
echo MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
echo GNU General Public License for more details.
echo.
echo See license.txt for the GNU General Public License. 
echo If missing, see https://www.gnu.org/licenses/
echo -------------------------------------------------------------------------------------
echo.

if [%1]==[/?] goto helptext
for %%v in (help /help -help) do (
     if [%%v]==[%1] goto helptext
)

set arg=
if [%1]==[-onlineupdate] set arg=onlineupdate
if [%1]==[-checkonline] set arg=checkonline
if [%1]==[-offlineupdate] set arg=offlineupdate

goto admintest

:helptext
echo.
echo Batch-Win-Installer %bwiver% [-help] [-onlineupdate] [-offlineupdate]] [-checkonline]
echo.
echo %introtitle1%
echo %introtitle2%
echo Description: Install/update Windows programs from a list and check program websites for latest versions
echo.
echo Parameter List:
echo -help                          Displays this help message
echo -onlineupdate                  Does online update of configuration files and checks if software installed on machine and update if necessary
echo -offlineupdate                 Skips any online update of configuration files and checks if software installed on machine and update if necessary
echo -checkonline                   Check online for latest versions from software's websites ONLY
echo.
goto end


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

if "%arg%"=="offlineupdate" (
  set online=N
  goto tempsoftwarelist
)

choice /N /C:YNO /M "Press N or O to run Batch Win Installer offline or Y to test if online..." /T 6 /D Y
   IF ERRORLEVEL 3 ( 
      set online=N
	  goto tempsoftwarelist
   )	  
   IF ERRORLEVEL 2 (
      set online=N
	  goto tempsoftwarelist
   )	
   IF ERRORLEVEL 1 echo Testing if Batch Win Installer can access the Internet


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
   if exist "%temp%!\%%a" del "%temp%!\%%a"
)

set "software-config-missing-list="
set "software-config-present-list="


for %%v in (%softwarelist%) do (
  if exist "%appinfopath%\%%v-install.txt" (
     set software-config-present-list=%%v !software-config-present-list!
  )	 
  
  if not exist "%appinfopath%\%%v-install.txt" (
     	 if "%online%"=="Y" (
		   echo Configuration file for %%v missing. Downloading %%v
		   "%wgetexe%" -q --progress=bar -O "%appinfopath%\%%v-install.txt" "%onlineupdateurl%%%v-install.txt"  
           "%wgetexe%" -q --progress=bar -O "%appinfopath%\%%v-uninstall.txt" "%onlineupdateurl%%%v-uninstall.txt"
		   findstr /offline /b /c:"set followup." "%appinfopath%!\%%v-install.txt">nul
		   IF !ERRORLEVEL! EQU 0 (
		     "%wgetexe%" -q --progress=bar -O "%appinfopath%\%%v.reg" "%onlineupdateurl%%%v.reg"
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

if "%online%"=="N" goto checkinstallers

if not "!software-config-present-list!"=="" (
    for %%v in (%software-config-present-list%) do (
      findstr /offline /b /c:"set onlineupdate." "%appinfopath%!\%%v-install.txt">>"%temp%!temp-online-list.bat"
	  echo.>>"%temp%!temp-online-list.bat"
	  findstr /offline /b /c:"set followup." "%appinfopath%!\%%v-install.txt">>"%temp%!temp-online-list.bat"
	)  
   call "%temp%!temp-online-list.bat"
   echo Downloading configuration updates 
   for %%v in (%software-config-present-list%) do (
    if "!onlineupdate.%%v!"=="Y" (
	   "%wgetexe%" -q -O "%appinfopath%\%%v-install.txt" "%onlineupdateurl%%%v-install.txt"
 	   "%wgetexe%" -q -O "%appinfopath%\%%v-uninstall.txt" "%onlineupdateurl%%%v-uninstall.txt"
       if not "!followup.%%v!"=="" "%wgetexe%" -q -O "%appinfopath%\%%v.reg" "%onlineupdateurl%%%v.reg"
    )
   )
)

:checkinstallers

for %%v in (%softwarelist%) do (
  type "%appinfopath%!\%%v-install.txt">>"%temp%!temp-software-list.bat"
  echo.>>"%temp%!temp-software-list.bat"
  type "%appinfopath%!\%%v-uninstall.txt">>"%temp%!temp-uninstall-list.bat"
) 

call "%temp%!temp-software-list.bat"

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
    if not exist "%filespath%\!exe.%%v!" "%wgetexe%" -q --progress=bar --show-progress -O "%filespath%\!exe.%%v!" "!url.%%v!"
	echo.
	for /F %%A in ("%filespath%\!exe.%%v!") do (
	   if %%~zA==0 (
	      echo Error downloading file %%A
		  echo Check the configuration file - perhaps a newer version of the software was released and/or the download location has changed.
          echo This will now exit
          goto end		  
       )	   
	)  
  )
)

:mainmenu  

if "%arg%"=="onlineupdate" goto checkupdate
if "%arg%"=="offlineupdate" goto checkupdate
if "%arg%"=="checkonline" (
  if "%online%"=="Y" goto checkonline
  if "%online%"=="N" (
     echo -checkonline argument invalid as not online
	 goto end
  )	 
)
 
:displaymainmenu

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

if exist "%temp%temp.txt" del "%temp%temp.txt"

if "%online%"=="N" (
  echo No Online access...exiting
  goto end
) 

for %%v in (%softwarelist%) do (
  "%xidelexe%" --silent "!regurl.%%v!" -e "!regexp.%%v!">"%temp%temp.txt"
  set /p latestver.%%v=<"%temp%temp.txt"
  if !latestver.%%v!==!pkgver.%%v! (
    echo No Update Needed  - Latest version of !name.%%v! online is !latestver.%%v!
  )	ELSE (
    echo [42mNEW Version Found[0m - Latest version of !name.%%v! online is !latestver.%%v!
  )
) 

if "%arg%"=="checkonline" goto end

echo.
echo Returning to main menu
timeout /t 4
goto displaymainmenu

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
      echo [42mUPDATE NEEDED[0m - Need to update !name.%%v! from !installedver! to !ver.%%v!
	  set updatelist=%%v !updatelist!
      if !regsearch.%%v! == %uninstallreg64% (
	    for /F "tokens=7 delims=\" %%d in ("!installreg!") do set "installguid=%%d"
	  ) else (
	    for /F "tokens=8 delims=\" %%d in ("!installreg!") do set "installguid=%%d"
	  )
	  set installreg.%%v=!installguid!
    )
  ) ELSE (
      echo [42mNOT INSTALLED[0m  - !name.%%v! is not installed.
	  set toinstall-list=%%v !toinstall-list!
  )	  
)
echo.
timeout /t 3
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
   echo.
   echo List of software to be Updated
   echo ----------------------------------
   for %%b in (!updatelist!) do (echo !name.%%b!)
   )

set doupdate=N
if "%arg%"=="onlineupdate" set doupdate=Y
if "%arg%"=="offlineupdate" set doupdate=Y
if "%doupdate%"=="Y" (
   choice /N /C:YXN /M "Press X or N to quit auto install and update of software or Y to continue..." /T 10 /D y
   IF ERRORLEVEL 3 goto end
   IF ERRORLEVEL 2 goto end
   IF ERRORLEVEL 1 goto installmissingsoftware
)   

echo.
echo  [101;93m NOTE : Please Close ALL Software Before Updating[0m
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
   echo Nothing to Install.
) else (
  for %%v in (!toinstall-list!) do (
    echo Installing !name.%%v!
    "%filespath%\!exe.%%v!" !arg.%%v!
	if not "!followup.%%v!"=="" (!followup.%%v!)
  )
)

timeout /t 5

:updatesoftware

if "!updatelist!" == "" (
   echo Nothing to Update.
) else (
   call "%temp%!temp-uninstall-list.bat"
  
   for %%k in (!updatelist!) do ( 
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

for %%v in (temp-software-list.bat temp-uninstall-list.bat temp.txt temp-online.bat temp-online-list.bat nvidiatemp.txt) do if exist "%temp%!%%v" del "%temp%!%%v"
endlocal
timeout /t 5