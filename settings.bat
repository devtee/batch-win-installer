set onlineupdateurl=https://raw.githubusercontent.com/devtee/batch-win-installer/main/appinfo/
set appinfourl=https://api.github.com/repos/devtee/batch-win-installer/contents/appinfo
set introtitle1=Batch-Win-Installer %bwiver% by Dev Anand Teelucksingh (https://github.com/devtee/batch-win-installer)
set introtitle2=for Trinidad and Tobago Computer Society (https://ttcs.tt/).
set orgname=TTCS
set softwarelist=firefox libreoffice libreofficehelp pdfsam notepadplusplus vlc joplin bleachbit 7zip sumatrapdf tuxpaint tuxpaintstamps puzzlecollection
goto end

rem the above environment variables are used to customise Batch Win Installer
rem 
rem onlineupdateurl is the URL to Batch Win Installer's GitHub project folder which contains the configuration files for the programs. 
rem appinfourl is the URL to Batch Win Installer's Github project folder that can be accessed with GitHub's API 
rem Change only if you've setup a folder for your own software configuration files
rem 
rem introtitle1 and introtitle2 are shown in the menu header . Doesn't affect the operation of batch win installer
rem
rem orgname can be used to describe the org this batch file is used for. Doesn't affect the operation of batch win installer
rem 
rem softwarelist is the list of software programs that Batch Win Installer will :
rem    download the software configuration files and software installers
rem    install / upgrade software using the software installers 
rem    check the software's websites for the latest version
rem So you SHOULD edit this to suit your software needs.
rem
rem --------------------------------------------------------------------------
rem 
rem Batch-Win-Installer - install/update Windows programs from a list and check program websites for latest versions
rem Copyright (C) 2023 Dev Anand Teelucksingh batchwininstaller@gmail.com
rem Used by the Trinidad and Tobago Computer Society - learn more at https://ttcs.tt/ 
rem
rem This program is free software: you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation, either version 3 of the License, or
rem (at your option) any later version.
rem
rem This program is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem GNU General Public License for more details.
rem
rem See license.txt for the GNU General Public License. 
rem If missing, see <https://www.gnu.org/licenses/
rem 
rem Visit Batch Win Installer Github page at https://github.com/devtee/batch-win-installer

:end
