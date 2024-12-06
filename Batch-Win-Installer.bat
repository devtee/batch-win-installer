setlocal enabledelayedexpansion ENABLEEXTENSIONS
@echo off
mode con: cols=135 lines=40
cls
rem Initialise variables
set tpath=%~dp0
set bwiver=0.9.0
set uninstallreg64=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
set uninstallreg32=HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
set appinfopath=%tpath%appinfo
set filespath=%tpath%files
set wgetexe=%tpath%wget/wget.exe
set xidelexe=%tpath%xidel/xidel.exe

rem confirm appinfo and filespath subfolders exist and create if not 
if not exist "%appinfopath%\" mkdir "%appinfopath%\"
if not exist "%filespath%\" mkdir "%filespath%\"

rem check presence of wget and xidel.exe in the subfolder and settings.bat in the same folder 
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

rem call settings.bat to set variables like softwarelist
call "%tpath%!settings.bat"

rem show license
call :showlicense

rem check if help or /? used to showhelp

if [%1]==[/?] set displayhelp=Y
for %%v in (help /help -help) do (
  if [%%v]==[%1] set displayhelp=Y
)

if "%displayhelp%"=="Y" (
  call :displayhelp
  goto end
)

set arg=
set cmdarg=
if [%1]==[-onlineupdate] set arg=onlineupdate
if [%1]==[-checkonline] set arg=checkonline
if [%1]==[-offlineupdate] set arg=offlineupdate
if [%1]==[-showprograms] set arg=showprograms
if [%1]==[-showpackages] set arg=showprograms

if [%1]==[install] set cmdarg=installpkg
if [%1]==[upgrade] set cmdarg=upgradepkg
if [%1]==[uninstall] set cmdarg=uninstallpkg
if [%1]==[checkonline] set cmdarg=checkonlinepkg

if DEFINED cmdarg (
  if "%~2" == "" (
     echo [101;93m ERROR [0m - No package^(s^) specified. This will now exit....
	 goto end
  )
  rem For install upgrade uninstall command, need to set softwarelist to what was specified in the command line
  for /F "tokens=1*" %%a in ("%*") do set softwarelist=%%b
)

:admintest
rem Test if this batch file is running as Administrator if not, invoke Powershell command to rerun this batch file
rem with admin privileges 
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting Administrator Privileges
	rem Need to test if arguments were presented ; if not then have to invoke Powershell command without ArgumentList to rerun batch file
	if "%~1" == "" (
	   powershell -Command "Start-Process -FilePath '\"%~f0\"' -Verb RunAs"
   	) else (
	   powershell -Command "Start-Process -FilePath '\"%~f0\"' -ArgumentList '%*' -Verb RunAs"
	)
	   
	goto :eof
)
echo Administrator Privileges Detected.

rem Test if we can access the Internet and download any files needed 

set Internet=N

if "%arg%"=="offlineupdate" (
  goto checksoftwarelist
)

choice /N /C:YNO /M "Press N or O to run Batch Win Installer offline or Y to test if online (default is Y in 6 seconds)..." /T 6 /D Y
   IF ERRORLEVEL 3 goto checksoftwarelist
   IF ERRORLEVEL 2 goto checksoftwarelist
   IF ERRORLEVEL 1 echo Testing if Batch Win Installer can access the Internet

ping -n 2 8.8.8.8 | find "TTL=" > nul

if %ERRORLEVEL% NEQ 1 (
 echo Internet Access Detected. 
 set Internet=Y
)

if %ERRORLEVEL% EQU 1 (
 echo Internet Access NOT Detected. 
)

:checksoftwarelist

if "%arg%"=="showprograms" (
  if "%Internet%"=="N" (
   echo Internet access required to see packages online
   echo This will now exit.....
   goto end
  )  
  call :showprograms
  goto end 
)

for %%a in (temp-software-list.bat temp-uninstall-list.bat temp-online-list.bat) do (
   if exist "%temp%!\%%a" del "%temp%!\%%a"
)
set "software-config-missing-list="
set "software-config-present-list="

rem for each item in softwarelist, check if install file exists and add it to software-config-present. If zero length, give error and exit
rem if install file does NOT exist and if online, download install file, uninstall file and if followup exist, the reg file and set it to software-config-missing. if offline, error message and exit

for %%v in (%softwarelist%) do (
if exist "%appinfopath%\%%v-install.txt" (
  call :checkifzerolength "%appinfopath%\%%v-install.txt" with errormsg "Please check the configuration file and re-edit and/or delete to download again"
  if !ERRORLEVEL! NEQ 0 goto end
)
set software-config-present-list=%%v !software-config-present-list!
   
if not exist "%appinfopath%\%%v-install.txt" (
 if "%Internet%"=="Y" (
  call :download "%appinfopath%\%%v-install.txt" from "%onlineupdateurl%%%v-install.txt" with errormsg "downloading configuration file - Perhaps it was misspelt"
  if !ERRORLEVEL! NEQ 0 goto end
  call :download  "%appinfopath%\%%v-uninstall.txt" from "%onlineupdateurl%%%v-uninstall.txt" with errormsg "downloading configuration file - Perhaps it was misspelt"
  if !ERRORLEVEL! NEQ 0 goto end
  findstr /offline /b /c:"set followup." "%appinfopath%!\%%v-install.txt">nul
  if !ERRORLEVEL! EQU 0 (
   call :download "%appinfopath%\%%v.reg" from "%onlineupdateurl%%%v.reg" with errormsg "downloading reg file - Perhaps it was misspelt"
   if !ERRORLEVEL! NEQ 0 goto end
  )
  findstr /offline /b /c:"set getlatestver." "%appinfopath%!\%%v-install.txt">nul
  if !ERRORLEVEL! EQU 0 (
   call :download "%appinfopath%\%%v-findlatestversion.txt" from "%onlineupdateurl%%%v-findlatestversion.txt" with errormsg "downloading findlatestver file - Perhaps it was misspelt"
   if !ERRORLEVEL! NEQ 0 goto end
  )
  set software-config-missing-list=%%v !software-config-missing-list!
 )
 if "%Internet%"=="N" (
  echo Configuration file for %%v missing. 
  echo Download or copy configuration files to the appinfo subfolder or enable online acccess and re-run this batch file.
  echo This will now exit....
  goto end
 )  
)

)

:downloadmissingconfigs 
rem  
rem if offline goto checkinstallers and skip this section
rem if software-config-present not empty, 
rem    search install txt for "set onlineupdate" "set followup" and "set findlatestver" and put those lines in temp-online-list.bat. then call temp-online.bat 
rem    for each software-config-present-list, 
rem       if onlineupdate is set to Y, 
rem         download install txt , uninstall txt and display name of configuration being updated 
rem         check if zero length files and exit if so 
rem         download reg if followup variable defined
rem         download findlatestver txt 
rem             
if "%Internet%"=="N" goto checkinstallers

if not "!software-config-present-list!"=="" (
    for %%v in (%software-config-present-list%) do (
      findstr /offline /b /c:"set onlineupdate." "%appinfopath%!\%%v-install.txt">>"%temp%!temp-online-list.bat"
	  echo.>>"%temp%!temp-online-list.bat"
	  findstr /offline /b /c:"set followup." "%appinfopath%!\%%v-install.txt">>"%temp%!temp-online-list.bat"
	  findstr /offline /b /c:"set getlatestver." "%appinfopath%!\%%v-install.txt">>"%temp%!temp-online-list.bat"
	  
	)  
   call "%temp%!temp-online-list.bat"

   choice /N /C:YNO /M "Press N or O to skip downloading Configuration Updates or Y to Download Configuration Updates (default is Y in 4 seconds)..." /T 4 /D Y
   IF ERRORLEVEL 3 goto skipconfigupdates
   IF ERRORLEVEL 2 goto skipconfigupdates
   IF ERRORLEVEL 1 echo.

   <nul set /p screen="Downloading configuration updates .. "

   for %%v in (%software-config-present-list%) do (
    if "!onlineupdate.%%v!"=="Y" (
	   <nul set /p screen="%%v .. "
	   call :download "%appinfopath%\%%v-install.txt" from "%onlineupdateurl%%%v-install.txt" with errormsg "downloading configuration file. Check the download location."
	   if !ERRORLEVEL! NEQ 0 goto end
       call :download  "%appinfopath%\%%v-uninstall.txt" from "%onlineupdateurl%%%v-uninstall.txt" with errormsg "downloading configuration file - Check the download location"
   	   if !ERRORLEVEL! NEQ 0 goto end
	   if not "!followup.%%v!"=="" call :download "%appinfopath%\%%v.reg" from "%onlineupdateurl%%%v.reg" with errormsg "downloading reg file - Perhaps it was misspelt"
   	   if !ERRORLEVEL! NEQ 0 goto end
	   if not "!getlatestver.%%v!"=="" call :download "%appinfopath%\%%v-findlatestversion.txt" from "%onlineupdateurl%%%v-findlatestversion.txt" with errormsg "downloading findlatestver file - Perhaps it was misspelt"
	   if !ERRORLEVEL! NEQ 0 goto end
    )
   )
)

:skipconfigupdates

echo.
echo.
IF NOT DEFINED cmdarg (
echo.
echo [96mIf you wish to edit the list of software that Batch-Win-Installer will check, 
echo edit the softwarelist variable in settings.bat[0m
echo.
) 

:checkinstallers

rem if arg is checkonline then skip
rem for each item in softwarelist
rem    copy contents of install.txt for item to temp-software-list.bat 
rem    copy contents of uninstall.txt for item to temp-uninstall-list.bat
rem  call temp-software-list.bat which sets the variables for each software item
rem if arg is checkonline then skip
rem   for each item in softwarelist 
rem     if installer exists in files subfolder, 
rem        test if zero length and if so, echo warning and exit
rem        if not zero length, echo text that installer is found
rem     else if installer doesn't exist
rem        echo text that installer is missing and add software name to missinglist
rem  After checking all items in softwarelist,
rem     if missinglist is empty (meaning all installers were found), goto main menu
rem     otherwise (missinglist is not empty meaning some installers are missing)
rem         if offline, echo error message and exit
rem         if online, for each item in missinglist 

for %%v in (%softwarelist%) do (
  type "%appinfopath%!\%%v-install.txt">>"%temp%!temp-software-list.bat"
  echo.>>"%temp%!temp-software-list.bat"
  type "%appinfopath%!\%%v-uninstall.txt">>"%temp%!temp-uninstall-list.bat"
) 

call "%temp%!temp-software-list.bat"

if "%arg%"=="checkonline" (
  if "%Internet%"=="Y" goto checkonline
  if "%Internet%"=="N" (
     echo -checkonline argument invalid as not online
	 goto end
  )	 
)
if "%cmdarg%"=="checkonlinepkg" goto checkonline

set "missinglist="
echo.
echo Checking software installers in %orgname% folder 
echo --------------------------------------------------
echo.
for %%v in (%softwarelist%) do (
if exist "%filespath%\!exe.%%v!" (
 call :checkifzerolength "%filespath%\!exe.%%v!" with errormsg "Please check the configuration file for !name.%%v! and delete the zero length file"
 if !ERRORLEVEL! NEQ 0 goto end
 echo Installer for !name.%%v! found - !exe.%%v!
) ELSE (
 echo [101;93m MISSING [0m - Installer for !name.%%v! - !exe.%%v! not found 
 set missinglist=%%v !missinglist!
)	
)

echo.
echo.
if "%missinglist%"=="" goto mainmenu

rem if missing software installers, download if online

if "%Internet%"=="N" (
  echo Download or copy installers to the %orgname% folder or enable online acccess and re-run this batch file.
  echo This will now exit....
  goto end
)

if "%Internet%"=="Y" (
  echo Downloading missing installers since online...
  echo.
  for %%v in (!missinglist!) do (
    echo Downloading !name.%%v!...
    call :download "%filespath%\!exe.%%v!" from "!url.%%v!" with errormsg "Check the configuration file - perhaps a newer version of the software was released and/or the download location has changed."
	if !ERRORLEVEL! NEQ 0 goto end
  )
)

:mainmenu  

rem test cmd line arguements and goto different menu options bypassing displaying main menu

if "%arg%"=="onlineupdate" goto checkupdatelist
if "%arg%"=="offlineupdate" goto checkupdatelist


if "%cmdarg%"=="installpkg" goto installpkg
if "%cmdarg%"=="upgradepkg" goto upgradepkg
if "%cmdarg%"=="uninstallpkg" goto uninstallpkg
 
:displaymainmenu

echo.
echo %introtitle1%
echo %introtitle2%
echo -------------------------------------------------------------------------------------
echo.
echo  1. Install all Software ONLY (use for first time install on new machine)
echo. 2. Check if software installed on machine and update if necessary (use to refresh software on machine)

if "%Internet%"=="Y" (
 echo  3. Check online for latest versions from software's websites ONLY
 echo  4. List available software programs online 
 echo.
 echo  5. Exit Menu
 echo.
 choice /N /C:12345 /M "Select option (1 to 5)"

 if ERRORLEVEL 5 goto end
 if ERRORLEVEL 4 goto showprogramslist 
 if ERRORLEVEL 3 goto checkonline
) else (
 echo.
 echo  3. Exit Menu
 echo.
 choice /N /C:123 /M "Select option (1 to 3)"

 if ERRORLEVEL 3 goto end
)

if ERRORLEVEL 2 goto checkupdatelist
if ERRORLEVEL 1 goto installsoftwarelist

goto end 

:installpkg
:upgradepkg
rem check if program is installed and find out which version
rem if not installed, then install program
rem if installed 
rem   if installer version equal to the installed version
rem      echo that its already installed and exit
rem   else uninstall program and install program

for %%v in (%softwarelist%) do (
 call :is-software-installed %%v installedver.%%v installreg.%%v 
 
 if !ERRORLEVEL! NEQ 0 (
  rem program not installed
  call :silent-install %%v
 ) else (
 rem program is installed 
  if "!installedver.%%v!" == "!ver.%%v!" (
  echo Latest version !installedver.%%v! of !name.%%v! is already installed.
  echo.
 ) else (
  call %temp%!temp-uninstall-list.bat
  call :uninstall %%v
  call :silent-install %%v
 ) 
)  
)
goto end


:uninstallpkg
rem check if program is installed and find out which version
rem if not installed, then echo error msg and exit 
rem if installed, uninstall program

for %%v in (%softwarelist%) do (
 call :is-software-installed %%v installedver.%%v installreg.%%v

 if !ERRORLEVEL! NEQ 0 (
  echo !name.%%v! was not installed.
 ) else (
  call "%temp%!temp-uninstall-list.bat"
  call :uninstall %%v 
 )  
) 
goto end

:checkonline
rem  if offline, echo error and exit
rem  for each item in softwarelist
rem     run xidel with parameters from software item and redirect output to temp.txt
rem     set the contents of temp.txt to latestver.%%v
rem     if latestver = pkgver then no update needed 
rem     else echo new version found
rem  if arg is checkonline or cmdarg is checkonlinepkg then end, otherwise return to display main menu

if exist "%temp%temp.txt" del "%temp%temp.txt"

if "%Internet%"=="N" (
  echo No Online access...exiting
  goto end
) 

for %%v in (%softwarelist%) do (
rem if getlatestver is Y then execute the findlatestversion txt ; else run xidel to get version from regurl using regexp
  if "!getlatestver.%%v!"=="Y" (
      type "!regurl.%%v!">"%temp%!%%v-findlatestversion.bat"
	  call "%temp%!%%v-findlatestversion.bat"
	  set /p latestver.%%v=<"!regexp.%%v!"
  ) ELSE (
     "%xidelexe%" -H "Accept-Language: en-US" --silent "!regurl.%%v!" -e "!regexp.%%v!">"%temp%temp.txt" 2> nul && set /p latestver.%%v=<"%temp%temp.txt" || set latestver.%%v="ERROR"
  )   

  if !latestver.%%v!=="ERROR" (
     echo [101;93mERROR[0m - Unable to check !name.%%v! online 
  ) else (                   
   if !latestver.%%v!==!pkgver.%%v! (
     echo No Update Needed  - Latest version of !name.%%v! online is !latestver.%%v!
   )	ELSE (
     echo [42mNEW Version Found[0m - Latest version of !name.%%v! online is !latestver.%%v!
   )
  )  
) 

if "%arg%"=="checkonline" goto end
if "%cmdarg%"=="checkonlinepkg" goto end

echo.
echo Returning to main menu
goto displaymainmenu


:showprogramslist

call :showprograms
echo.
echo Returning to main menu
goto displaymainmenu


:installsoftwarelist
rem for each item in softwarelist
rem   echo text saying installing name and version 
rem   run installer with silent arguments for silent install
rem   if followup variable set, run followup cmd which is the registry edit to set the displayversion 

for %%v in (%softwarelist%) do (
  echo Installing !name.%%v! !pkgver.%%v!
  "%filespath%\!exe.%%v!" !arg.%%v!
  if not "!followup.%%v!"=="" (!followup.%%v!)
)

goto end

:checkupdatelist
rem    for each item in software-reverse-list
rem        if file check shows that app is installed
rem            use reg query to find under regsearch (set to either uninstallreg64 or uninstallreg32) for regtext and 
rem             use findstr to set installreg to the registry key of the installed software
rem            use reg query to find DisplayVersion under the installreg key and set installedver to the value of DisplayVersion
rem            if installedver is equal to ver in the configuration file 
rem               echo text that latest version installed 
rem            else (installedver is not the same)
rem               echo text that update is needed
rem               add item to updatelist
rem               set installedver.%%v to installedver
rem        else (file check shows app is not installed)
rem            echo text not installed 
rem            add item to toinstall-list  
rem        
set "updatelist="
set "toinstall-list="
echo off

for %%v in (%softwarelist%) do (

call :is-software-installed %%v installedver.%%v installreg.%%v
if !ERRORLEVEL! NEQ 0 (
 echo [42mNOT INSTALLED[0m  - !name.%%v! is not installed.
 set toinstall-list=!toinstall-list!%%v 
) else (	  
 if "!installedver.%%v!" == "!ver.%%v!" (
  echo Latest version !installedver.%%v! of !name.%%v! is installed.
 ) else (
  echo [104mUPDATE NEEDED[0m - Need to update !name.%%v! from !installedver.%%v! to !ver.%%v!
  set updatelist=%%v !updatelist!
  )
)
)

if "!toinstall-list!" == "" (
 echo.
 echo No software needs to be installed
) else (
 echo.
 echo List of software to be installed 
 echo ---------------------------------------
 for %%b in (!toinstall-list!) do (echo !name.%%b!)
 echo.
)

if "!updatelist!" == "" (
 echo No software needs to be updated
 if "!toinstall-list!" == "" goto end
) else ( 
  echo.
  echo List of software to be Updated
  echo ----------------------------------
  for %%b in (!updatelist!) do (echo !name.%%b!)
)
  
set doupdate=N
if "%arg%"=="onlineupdate" set doupdate=Y
if "%arg%"=="offlineupdate" set doupdate=Y

if "%doupdate%"=="Y" (
   choice /N /C:YXN /M "Press X or N to quit auto install and update of software or Press Y to immediately continue...(default: auto install in 6 seconds)" /T 6 /D y
   IF ERRORLEVEL 3 goto end
   IF ERRORLEVEL 2 goto end
   IF ERRORLEVEL 1 goto installmissingsoftwarelist
)   

echo.
echo [101;93m NOTE : Please Close ALL Software Before Updating[0m
echo.

if "!updatelist!" == "" (
echo  1. Install Missing Software 
echo  2. Exit
echo.
CHOICE /N /C:12 /M "Select option (1 to 2)"
IF ERRORLEVEL 2 goto end
IF ERRORLEVEL 1 goto installmissingsoftwarelist

) else (

echo  1. Install Missing Software AND Update Installed Software
echo  2. Update Installed Software ONLY
echo.
echo  3. Exit
echo.
CHOICE /N /C:123 /M "Select option (1 to 3)"
IF ERRORLEVEL 3 goto end
IF ERRORLEVEL 2 goto updatesoftwarelist
IF ERRORLEVEL 1 goto installmissingsoftwarelist
)

echo.
echo Returning to main menu
goto displaymainmenu


:installmissingsoftwarelist

if "!toinstall-list!" == "" (
   echo Nothing to Install.
) else (
  for %%v in (!toinstall-list!) do (
    echo Installing !name.%%v!
    "%filespath%\!exe.%%v!" !arg.%%v!
	if not "!followup.%%v!"=="" (!followup.%%v!)
  )
)

:updatesoftwarelist

if "!updatelist!" == "" goto end

call "%temp%!temp-uninstall-list.bat"
for %%k in (!updatelist!) do ( 
 echo Removing !name.%%k! - !installedver.%%k!
 !uninstall.%%k!
 echo !name.%%k! uninstalled.
 echo.
)

for %%k in (!updatelist!) do ( 
 echo Installing !name.%%k! !pkgver.%%k!
 "%filespath%\!exe.%%k!" !arg.%%k!
 if not "!followup.%%k!"=="" (!followup.%%k!)
)

goto end 

:end

for %%v in (temp-software-list.bat temp-uninstall-list.bat temp.txt temp-online.bat temp-online-list.bat nvidiatemp.txt) do if exist "%temp%!%%v" del "%temp%!%%v"
endlocal
timeout /t 4
cd %tpath%
goto :eof

rem  subroutines 


:is-software-installed 
rem is-software-installed [program] [installedver] [installreg]
rem return 0 if found and with installedver set and return 1 if not installed or return 2 if the file exists but the registry search didn't find the version

if exist "!chk.%1!" (
 for /F "delims=" %%a in ('reg query "!regsearch.%1!" /d /f "!regtext.%1!" /s ^| FINDSTR /c:"CurrentVersion\\Uninstall\\"') do set "installreg=%%a"
 for /F "tokens=3 delims= " %%h in ('reg query "!installreg!" /f "DisplayVersion" ^| FINDSTR /c:"DisplayVersion"') do set "installedver=%%h"
  
 if !installedver!=="" (
   rem for some reason, the version wasn't found in the registry
   exit /b 2
 ) else (
   if !regsearch.%1! == %uninstallreg64% (
    for /F "tokens=7 delims=\" %%d in ("!installreg!") do set "installguid=%%d"
   ) else (
    for /F "tokens=8 delims=\" %%d in ("!installreg!") do set "installguid=%%d"
   )
   set "%~2=!installedver!"
   set "%~3=!installguid!"
   exit /b 0
 )
) ELSE (
 rem installed file not found
 exit /b 1
)

:silent-install 
rem silent-install [program]
 echo Installing !name.%1! !pkgver.%1!
 "%filespath%\!exe.%1!" !arg.%1!
 if !ERRORLEVEL! NEQ 0 (
   echo Attempted to install %1 but got an error message. Please check installer and command line arguements.
   exit /b 1
 ) ELSE (
   if not "!followup.%1!"=="" (!followup.%1!)
   echo !name.%1! !pkgver.%1! installed.
   exit /b 0
 )


:uninstall
rem uninstall [program]
echo.
echo Removing !name.%1! - !installedver.%1!
!uninstall.%1!

echo !name.%1! uninstalled.
exit /b 0

:download 
rem download [file] from [url] with errormsg "[errormsg]"
rem download [file] from [url] using wget and check if a zero length file, exit
"%wgetexe%" -q --progress=bar -O %1 %3
if !ERRORLEVEL! NEQ 0 (
 echo [101;93m ERROR [0m - %6
 echo This will now exit
 del /q %1
 exit /b 1
)
call :checkifzerolength %1 with errormsg " "
if !ERRORLEVEL! NEQ 0 exit /b 2

exit /b 0

:checkifzerolength 
rem checkifzerolength [filename] with errormsg "[errormsg]"
for /F %%A in (%1) do (
if %%~zA==0 (
 echo [101;93m ERROR [0m file %%A is a zero-length file 
 echo %4
 echo This will now exit
 exit /b 2
)
)
exit /b 0

:showprograms
rem download json file from github and redirect all node with name to a file - do a directory listing of appinfo folder on github
rem then for loop to only show the nodes ending with "-install.txt" which is the list of programs 
"%xidelexe%" "%appinfourl%" -e '$json/name' > "%temp%\filelist.txt"
echo.
echo [96mList of programs online[0m
echo --------------------------------------------------------
for /f "tokens=* delims=" %%a in ('type "%temp%\filelist.txt"') do (
    set "line=%%a"
	
	if "!line:~-12!"=="-install.txt" (
      rem echo !line:~0,-12!
	  <nul set /p screen="!line:~0,-12!   "
    )
	
)
echo.
exit /b 0

)

:showlicense
echo.
echo Batch-Win-Installer %bwiver% - Install/update Windows programs from a list and 
echo                             check program websites for latest versions
echo.
echo Copyright (C) 2023 Dev Anand Teelucksingh 
echo Used by the Trinidad and Tobago Computer Society - learn more at https://ttcs.tt/ 
echo Project page : https://github.com/devtee/batch-win-installer
echo Email comments to batchwininstaller@gmail.com
echo -------------------------------------------------------------------------------------
echo This program is free software: you can redistribute it and/or modify it under the 
echo terms of the GNU General Public License as published by the Free Software Foundation,
echo either version 3 of the License, or (at your option) any later version.
echo.
echo This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
echo without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
echo See the GNU General Public License for more details.
echo.
echo See license.txt for the GNU General Public License. If missing, see https://www.gnu.org/licenses/
echo -------------------------------------------------------------------------------------
echo.
exit /b

:displayhelp
echo.
echo Batch-Win-Installer %bwiver% [-help] [-onlineupdate] [-offlineupdate] [-checkonline] [-showprograms ^| -showpackages ]
echo.
echo Description: Install/update Windows programs from a list and check program websites for latest versions
echo.
echo Parameter List:
echo  -help              Displays this help message
echo  -onlineupdate      Does online update of configuration files and checks if software installed on machine and update if necessary
echo  -offlineupdate     Skips any online update of configuration files and checks if software installed on machine and update if necessary
echo  -checkonline       Check online for latest versions from software's websites ONLY
echo  -showprograms ^| -showpackages      Show list of programs available online
echo.
echo  install pkgname ^[pkgname2 ...^]   - install pkgname ^(multiple packages can be specified^)
echo  upgrade pkgname ^[pkgname2 ...^]  - upgrade  pkgname ^(multiple packages can be specified^)
echo  uninstall pkgname ^[pkgname2 ...^]  - uninstall pkgname ^(multiple packages can be specified^)
echo  checkonline pkgname ^[pkgname2 ...^] - check website to see if what the latest version for pkgname ^(multiple packages can be specified^)
echo.
exit /b

