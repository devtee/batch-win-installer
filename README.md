# Batch-Win-Installer

Batch Win Installer is a tool to 
* automatically install software on 64 bit Windows 10/11 x64 machine without prompts
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
```

# How settings for software packages are stored 

Settings for software packages are stored as two batch files in the appinfo subfolder. 

## example-sofware.bat
```
set pkgver.example=105.0.3
set ver.example=%pkgver.example%
set name.example=Example Package
set exe.example=Example Setup %pkgver.example%.exe
set url.example="https://example.example/%exe.example%"
set arg.example=-ms
set chk.example=%ProgramFiles%\example\example.exe
set regtext.example=Example
set regsearch.example=%uninstallreg64%
set regurl.example=https://example.example
set regexp.example=substring-before(substring-after(/html/body/div[2]/div[1]/div[5]div/div/p,'Example '),' for')
```
## example-uninstall.bat
```
set uninstall.example="%ProgramFiles%\example\uninstall.exe" -ms
```

# Requirements

* 64 bit version of Windows 10 or Windows 11

# Installation

To install, unzip the latest Batch-Win-Installer.zip file to a folder. The Batch-Win-Installer.zip contains the following files and folders
* Batch-Win-Installer.bat 
* settings.bat
* readme.txt
* license.txt
* wget subfolder containing 64 bit version of GNU Wget v1.21.3, wget.exe from https://eternallybored.org/misc/wget/
* xidel subfolder containing 64 bit version of Xidel v0.99 pre-release, xidel.exe from xidel-0.9.9.20220424.8389.2d2ee7befb8a.win64.zip dated 2022-04-24
  from https://sourceforge.net/projects/videlibri/files/Xidel/Xidel%20development/ (Xidel's home page is https://www.videlibri.de/xidel.html)


# Feedback 
#
# Email batchwininstaller@gmail.com 
# 
