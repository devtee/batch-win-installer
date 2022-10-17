# batch-software-installer

Batch Software Installer is a tool to help install and upgrade Windows software via a batch file and the use of two utilities 
* Windows binary of GNU Wget (https://eternallybored.org/misc/wget/) used to retrieve files using http(s) 
* Windows binary of Xidel (https://github.com/benibela/xidel) a commandline tool to download and extract data from HTML pages 

# How settings for software packages are stored 

Settings for software packages are stored as two batch files in the appinfo subfolder. 

## example-sofware.bat

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

## example-uninstall.bat

set uninstall.example="%ProgramFiles%\example\uninstall.exe" -ms




# Installation

To install put batch-software-installer.bat and settings.bat and edit settings.bat to customise.
