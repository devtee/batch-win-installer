# Batch-Win-Installer

From a defined list of software, Batch Win Installer can:
* automatically install software on 64 bit Windows 10/11 x64 machine silently without prompts
* check what software is installed and offer to install and/or upgrade software
* if online, scan program's websites directly to determine the latest version of the software available

Batch Win Installer is a batch file which must be run as an administrator and uses two command line utilities 

* Windows binary of GNU Wget (https://eternallybored.org/misc/wget/) used to retrieve files using http(s) 
* Windows binary of Xidel (https://github.com/benibela/xidel) a commandline tool to download and extract data from HTML pages 

The advantages of Batch Win Installer :

* can be run from a USB portable drive
* settings for software packages are stored as two separate text files allowing you to add software packages to install
* the settings for software packages can be retrieved online on startup of Batch Win Installer 
* on startup, Batch Win Installer will confirm the installers for the software is accessible and if online, will download missing installers

Several command line switches are available 
```
-help              Displays help text
-onlineupdate      Does online update of configuration files and checks if software installed on machine and update if necessary
-offlineupdate     Skips any online update of configuration files and checks if software installed on machine and update if necessary
-checkonline       Check online for latest versions from software's websites ONLY
-showprograms | -showpackages    Show list of programs available online

install pkgname [pkgname2 ...]     - install pkgname (multiple packages can be specified)
upgrade pkgname [pkgname2 ...]     - upgrade  pkgname (multiple packages can be specified)
uninstall pkgname [pkgname2 ...]   - uninstall pkgname (multiple packages can be specified)
checkonline pkgname [pkgname2 ...] - check website to see if what the latest version for pkgname (multiple packages can be specified)
```

# Requirements

* 64 bit version of Windows 10 or Windows 11 with administrator access 
* online access when run for the first time to download configuration files and software installers

# Screenshots
![batchwininstaller-help](https://github.com/devtee/batch-win-installer/assets/41971042/4ea8aec0-e64b-42ad-b250-e9e0e5c87e8c)

![first-run-menu](https://github.com/devtee/batch-win-installer/assets/41971042/be06adb1-3351-418f-bfdc-16efd9826e48)

![download-missing-installers](https://github.com/devtee/batch-win-installer/assets/41971042/6c669799-bbb7-472e-95af-466e4a86b279)

![checking-latest-versions](https://github.com/devtee/batch-win-installer/assets/41971042/80e5aac5-03fa-49d4-9b17-2ea0c103c32f)

![check-what-software-installed](https://github.com/devtee/batch-win-installer/assets/41971042/7a440956-57d4-4d7e-80f0-db6a57dc8762)

![install-upgrade-software](https://github.com/devtee/batch-win-installer/assets/41971042/65745e1d-5c67-4d15-be03-0e1d65ee784b)


# Installation

To install, unzip the latest Batch-Win-Installer.zip file to a folder. The Batch-Win-Installer.zip contains the following files and folders
* Batch-Win-Installer.bat 
* settings.bat
* readme.txt
* license.txt
* wget subfolder containing 64 bit version of GNU Wget v1.21.3, wget.exe from https://eternallybored.org/misc/wget/
* xidel subfolder containing 64 bit version of Xidel v0.99 pre-release, xidel.exe from xidel-0.9.9.20220424.8389.2d2ee7befb8a.win64.zip dated 2022-04-24
  from https://sourceforge.net/projects/videlibri/files/Xidel/Xidel%20development/ (Xidel's home page is https://www.videlibri.de/xidel.html)

Next, edit settings.bat which contains the following lines to set certain environment variables

```
set onlineupdateurl=https://raw.githubusercontent.com/devtee/batch-win-installer/main/appinfo/
set appinfourl=https://api.github.com/repos/devtee/batch-win-installer/contents/appinfo
set introtitle1=Batch-Win-Installer %bwiver% by Dev Anand Teelucksingh - batchwininstaller@gmail.com -
set introtitle2=for Trinidad and Tobago Computer Society (https://ttcs.tt/) 
set orgname=TTCS

set softwarelist=firefox libreoffice libreofficehelp pdfsam notepadplusplus vlc joplin bleachbit 7zip sumatrapdf tuxpaint tuxpaintstamps puzzlecollection
```

The critical one to edit is **softwarelist** which is the list of software programs that Batch Win Installer will :
* download the software configuration files and software installers
* install / upgrade software using the software installers 
* check the software's websites for the latest version

Save any changes and run Batch-Win-Installer as an administrator. This is needed for Batch Win Installer to install and remove software.

# How settings for software packages are stored 

Settings for software packages are stored as two batch files in the appinfo subfolder. 

* name of program-install.txt
* name of program-uninstall.txt

### example-install.txt

Here's a typical example-install.txt for the software program "example"

```
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
```
Here's a short explaination of each of these variables :
* pkgver.example - this is the version of the software that would be listed on the software's website
* ver.example - this is the version number of the software when its installed on a Windows machine. 
                Typically in the Windows Registry, the software typically puts the version in the DisplayVersion subkey.
                However, some installers DON'T create the DisplayVersion subkey so for those programs, 
                a .reg file with the DisplayVersion subkey with the proper version will have to be provided
                and the followup.example will import such a reg file after installation
                
* exe.example - this is the name of the installer file when downloaded
* url.example - this is the direct download URL of the software ; Batch Win Installer will download the installer (via wget) 
                and put it in the files subfolder 
* arg.example - the command line switches passed to the installer to install silently.
* chk.example - the location of a file which proves that the software is installed.
* regtext.example - the unique text that will allow Batch Win Installer to find the registry entry for the installed program
* regsearch.example - Windows creates an uninstall entry in the Windows Registry in either two locations :
                      HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall - for 64 bit programs installed in 64 bit Windows environment
                      HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall - for 32 bit programs installed in a 64 bit Windows environment
So regsearch.example is set to either %uninstallreg64% or %uninstallreg32% so that Batch Win Installer "knows" where to search for the program's uninstall entry in the Windows registry                         

* followup.example - this will be the cmd to run Windows 10 reg command to import example.reg. If Batch Win Installer is downloading the configuration files (example-install.txt and example-uninstall.txt) and it sees followup.example defined, it will download example.reg

* regurl.example - this is the url where Batch Win Installer will query using xidel.exe to find the latest version of the software
* regexp.example - this is the xpath expression that Batch Win Installer (using xidel.exe) will extract from the url specified in regurl.example 
                   to find the latest version of the software 

### example-uninstall.bat

Here's a typical example-uninstall.txt for the software program "example"
```
set uninstall.example=msiexec /qn /uninstall %installreg.example%
```
* uninstall.example - this is the uninstall command used to uninstall the software if a newer version is to be installed. 
%installreg.example% is the software's subkey found in the Windows Registry under either %uninstallreg64% or %uninstallreg32%, 
which is usually the software's product code GUID which varies with each version of the software. 



# Feedback

* Email : batchwininstaller@gmail.com
* You can find me Mastodon at https://techhub.social/@devtee
* Visit the Trinidad and Tobago Computer Society's (TTCS) https://ttcs.tt/ and join the TTCS announce mailing list!

