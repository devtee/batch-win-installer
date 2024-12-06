Batch-Win-Installer v0.9.0 by Dev Anand Teelucksingh 
Batch-Win-Installer Copyright (C) 2023 Dev Anand Teelucksingh 
Project page : https://github.com/devtee/batch-win-installer
Email comments to batchwininstaller@gmail.com

This program comes with ABSOLUTELY NO WARRANTY; This is free software, and you are welcome to redistribute it under certain conditions;

Batch-Win-Installer - install/update Windows programs and check program websites for latest versions
Copyright (C) 2022 Dev Anand Teelucksingh batchwininstaller@gmail.com

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/

-----------------------------------------------------------------------------
Software Requirements 
-----------------------------------------------------------------------------

- Tested on 64-bit Windows 10 and Windows 11
- Batch Win Installer requires Administrator Rights to be able to install/update programs

-----------------------------------------------------------------------------
Introduction 
-----------------------------------------------------------------------------

From a list of software, Batch Win Installer can:
* automatically install software on 64 bit Windows 10/11 x64 machine silently without prompts
* check what software is installed and offer to install and/or upgrade software
* if online, scan program's websites directly to determine the latest version 
  of the software available


Batch Win Installer is a batch file which must be run as an administrator and uses two command line utilities 

* Windows binary of GNU Wget (https://eternallybored.org/misc/wget/) used to retrieve files using http(s) 
* Windows binary of Xidel (https://github.com/benibela/xidel) a commandline tool to download and extract data from HTML pages 

The advantages of Batch Win Installer :

* can be run from a USB portable drive
* settings for software packages are stored as two separate text files allowing you to add software packages to install
* the settings for software packages can be retrieved online on startup of Batch Win Installer 
* on startup, Batch Win Installer will confirm the installers for the software is accessible and if online, will download missing installers
* can specify packages to install/upgrade or check online as a command line arguement 

Several command line switches are available to automate Batch-Win-Installer 

-help                          Displays help text
-onlineupdate                  Does online update of configuration files and checks if software installed on machine and update if necessary
-offlineupdate                 Skips any online update of configuration files and checks if software installed on machine and update if necessary
-checkonline                   Check online for latest versions from software's websites ONLY

install pkgname [pkgname2 ...]   - install pkgname (multiple packages can be specified)
upgrade pkgname [pkgname2 ...]   - upgrade pkgname (multiple packages can be specified)
checkonline pkgname ^[pkgname ...^] - check website to see if what the latest version for pkgname (multiple packages can be specified)


Requirements
------------

* 64 bit version of Windows 10 or Windows 11 with administrator access
* online access when run for the first time to download configuration files and software installers. 


Installation
------------

To install, 
* download the latest Batch-Win-Installer ZIP file from https://github.com/devtee/batch-win-installer/releases to a folder. 
* extract all of the contents of Batch-Win-Installer.zip

Batch-Win Installer ZIP file contains the following files and folders

- Batch-Win-Installer.bat
- settings.bat
- readme.txt (this file!)
- license.txt
- wget subfolder containing 64 bit version of GNU Wget v1.21.4, wget.exe from https://eternallybored.org/misc/wget/
- xidel subfolder containing 64 bit version of Xidel v0.99 pre-release, xidel.exe from xidel-0.9.9.20230616.8842.e14a96920e01.win64.zip dated 2023-06-16 from https://sourceforge.net/projects/videlibri/files/Xidel/Xidel%20development/ (Xidel's home page is https://www.videlibri.de/xidel.html)

Next, edit settings.bat which contains the following lines to set certain environment variables

The critical one to edit is the softwarelist variable which is the list of software programs that Batch Win Installer will :
* download the software configuration files and software installers
* install / upgrade software using the software installers
* check the software's websites for the latest version

Save any changes and run Batch-Win-Installer as an administrator. This is needed for Batch Win Installer to install and remove software.


How settings for software packages are stored
----------------------------------------------

Settings for software packages are stored as two batch files in the appinfo subfolder.

    name of program-install.txt
    name of program-uninstall.txt

If a batch file is needed to find the latest version of software, another batch file in the appinfo subfolder is included
    name of program-findlatestversion.txt 


Here's a typical example-install.txt for the software program "example"

example-install.txt

set pkgver.example=105.0.3
set ver.example=%pkgver.example%
set name.example=Example Package
set exe.example=Example Setup %pkgver.example%.exe
set url.example="https://example.example/download/%exe.example%"
set arg.example=-ms
set chk.example=%ProgramFiles%\example\example.exe
set regtext.example=Example
set regsearch.example=%uninstallreg64%
set followup.example=reg import "%appinfopath%!\example.reg"
set regurl.example=https://example.example
set regexp.example=substring-before(substring-after(/html/body/div[2]/div[1]/div[5]div/div/p,'Example '),' for')


Here's a short explaination of each of these variables :
* pkgver.example - this is the version of the software that would be listed on the software's website
* ver.example - this is the version number of the software when its installed on a Windows machine. Typically in the Windows Registry, the software typically puts the version in the DisplayVersion subkey. 
  However, some installers DON'T create the DisplayVersion subkey so for those programs, a .reg file with the DisplayVersion subkey with 
  the proper version will have to be provided and the followup.example will import such a reg file after installation.
* exe.example - this is the name of the installer file when downloaded
* url.example - this is the direct download URL of the software ; Batch Win Installer will download the installer (via wget) and put it in the files subfolder
* arg.example - the command line switches passed to the installer to install silently.
* chk.example - the location of a file which proves that the software is installed.
* regtext.example - the unique text that will allow Batch Win Installer to find the registry entry for the installed program.
* regsearch.example - Windows creates an uninstall entry in the Windows Registry in either two locations : 
   HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall - for 64 bit programs installed in 64 bit Windows environment 
   HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall - for 32 bit programs installed in a 64 bit Windows environment 
   So regsearch.example is set to either %uninstallreg64% or %uninstallreg32% so that Batch Win Installer "knows" where to 
   search for the program's uninstall entry in the Windows registry.
* followup.example - this will be the cmd to run Windows 10 reg command to import example.reg. If Batch Win Installer is 
  downloading the configuration files (example-install.txt and example-uninstall.txt) and it sees followup.example defined, it will download example.reg
* getlatestversion.example  - this is set to "Y" when xidel will not be used and example-findlatestversion.txt would be used to return the latest version. 
* regurl.example - this is the url where Batch Win Installer will query using xidel.exe to find the latest version of the software. 
                   If getlatestversion.example is set to Y, this is set to the name of the batch file that would be called to get the latest version
* regexp.example - this is the xpath expression that Batch Win Installer (using xidel.exe) will extract from the url specified in regurl.example 
                   to find the latest version of the software. 
				   If getlatestversion.example is set to Y, this is set to the name of the text file generated from the batch file from regurl variable that contains the latest version of the software


example-uninstall.bat

Here's a typical example-uninstall.txt for the software program "example"

set uninstall.example=msiexec /qn /uninstall %installreg.example%

* uninstall.example - this is the uninstall command used to uninstall the software if a newer version is to be installed. 
  %installreg.example% is the software's subkey found in the Windows Registry under either %uninstallreg64% or %uninstallreg32%, which is usually 
  the software's product code GUID which varies with each version of the software.


example-findlatestversion.bat

If there is a need to use this method to query a website instaad of xidel using regurl.example and regexp.example, set getlatestversion.example to Y. 
Here's a typical example-findlatestversion.txt for the software progam "example".

@echo off
curl -i -s "<example url>" | findstr /b location >"%temp%\temp.txt"
for /f "tokens=4 delims=/" %%a in (%temp%\temp.txt) do @echo %%a>"%temp%\temp.txt"


Feedback
--------

* Email : batchwininstaller@gmail.com
* You can find me Mastodon at https://techhub.social/@devtee 
* Visit the Trinidad and Tobago Computer Society's (TTCS) https://ttcs.tt/ ; join the TTCS announce mailing list!

Last updated : December 5 2024