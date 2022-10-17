set softwarelist=firefox loffice lofficehelp pdfsam npp vlc joplin bbit 7zip spdf tpaint tstamps puzzlecollection
set uninstallreg64=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
set uninstallreg32=HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall

set pkgver.firefox=105.0.1
set ver.firefox=%pkgver.firefox%
set name.firefox=Mozilla Firefox
set exe.firefox=Firefox Setup %pkgver.firefox%.exe
set url.firefox="https://download.mozilla.org/?product=firefox-%pkgver.firefox%-ssl&os=win64&lang=en-US"
set arg.firefox=-ms
set chk.firefox=%ProgramFiles%\Mozilla Firefox\firefox.exe
set regtext.firefox=Mozilla Firefox
set regsearch.firefox=%uninstallreg64%
set regurl.firefox=https://www.mozilla.org/en-US/firefox/releases/
set regexp.firefox=/html[@data-latest-firefox]/attribute::data-latest-firefox

set pkgver.libreoffice=7.4.1
set ver.libreoffice=7.4.1.2
set name.libreoffice=LibreOffice
set exe.libreoffice=LibreOffice_%pkgver.libreoffice%_Win_x64.msi
set url.libreoffice=https://download.documentfoundation.org/libreoffice/stable/%pkgver.libreoffice%/win/x86_64/%exe.libreoffice%
set arg.libreoffice=/qn /passive /norestart
set chk.libreoffice=%ProgramFiles%\LibreOffice\program\soffice.exe
set regtext.libreoffice=LibreOffice * (multilanguage)
set regsearch.libreoffice=%uninstallreg64%
set regurl.libreoffice=https://www.libreoffice.org/download/download/
set regexp.libreoffice=//*[@id='content1']/div/article/div[1]/div[2]/div[1]/span[1]


set pkgver.libreoffice-help=7.4.1
set ver.libreoffice-help=7.4.1.2
set name.libreoffice-help=LibreOffice Help Pack
set exe.libreoffice-help=LibreOffice_%pkgver.libreoffice-help%_Win_x64_helppack_en-US.msi
set url.libreoffice-help=https://download.documentfoundation.org/libreoffice/stable/%pkgver.libreoffice-help%/win/x86_64/%exe.libreoffice-help%
set arg.libreoffice-help=/qn /passive /norestart
set chk.libreoffice-help=%ProgramFiles%\LibreOffice\help\en-US\text\shared\need_help.html
set regtext.libreoffice-help=LibreOffice * Help Pack
set regsearch.libreoffice-help=%uninstallreg64%
set regurl.libreoffice-help=https://www.libreoffice.org/download/download/
set regexp.libreoffice-help=substring-after(substring-before(/html/body/section[1]/div/article/div[1]/div[2]/div[1]/ul/li[1]/a/@href,'/win'),'stable/


set pkgver.pdfsam=4.3.3
set ver.pdfsam=4.3.3.0
set name.pdfsam=PDF Split and Merge
set exe.pdfsam=pdfsam-%pkgver.pdfsam%.msi
set url.pdfsam=https://github.com/torakiki/pdfsam/releases/download/v%pkgver.pdfsam%/%exe.pdfsam%
set arg.pdfsam=/quiet /passive CHECK_FOR_UPDATES=false SKIPTHANKSPAGE=Yes
set chk.pdfsam=%ProgramFiles%\PDFsam Basic\pdfsam.exe
set regtext.pdfsam=PDFsam Basic
set regsearch.pdfsam=%uninstallreg64%
set regurl.pdfsam=https://pdfsam.org/downloads/
set regexp.pdfsam=/html/body/main/div/section/div[2]/div[1]/div/h6

set pkgver.npp=8.4.5
set ver.npp=%pkgver.npp%
set name.npp=Notepad++
set exe.npp=npp.%ver.npp%.Installer.x64.exe
set url.npp=https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v%pkgver.npp%/%exe.npp%
set arg.npp=/S
set chk.npp=%ProgramFiles%\Notepad++\notepad++.exe
set regtext.npp=Notepad++ (64-bit x64)
set regsearch.npp=%uninstallreg64%
set regurl.npp=https://notepad-plus-plus.org/
set regexp.npp=substring-after(/html/body/div/header/div/div[1]/p/a/strong,'Version ')

set pkgver.vlc=3.0.17.4
set ver.vlc=%pkgver.vlc%
set name.vlc=VideoLAN
set exe.vlc=vlc-%pkgver.vlc%-win64.exe
set url.vlc=https://get.videolan.org/vlc/%pkgver.vlc%/win64/%exe.vlc%
set arg.vlc=/S
set chk.vlc=%ProgramFiles%\VideoLAN\VLC\vlc.exe
set regtext.vlc=VLC media player
set regsearch.vlc=%uninstallreg64%
set regurl.vlc=https://www.videolan.org/vlc/
set regexp.vlc=normalize-space(//span[@id='downloadVersion'])


set pkgver.joplin=2.8.8
set ver.joplin=%pkgver.joplin%
set name.joplin=Joplin
set exe.joplin=Joplin-Setup-%pkgver.joplin%.exe
set url.joplin=https://github.com/laurent22/joplin/releases/download/v%pkgver.joplin%/%exe.joplin%
set arg.joplin=/ALLUSERS=1 /S
set chk.joplin=%ProgramFiles%\Joplin\Joplin.exe
set regtext.joplin=Joplin *
set regsearch.joplin=%uninstallreg64%
set regurl.joplin=https://github.com/laurent22/joplin
set regexp.joplin=substring-after(/html/body/div[4]/div/main/turbo-frame/div/div/div/div[3]/div[2]/div/div[2]/div/a/div/div[1]/span[1],'v')


set pkgver.bbit=4.4.2
set ver.bbit=4.4.2.2142
set name.bbit=BleachBit
set exe.bbit=BleachBit-%pkgver.bbit%-setup.exe
set url.bbit=https://download.bleachbit.org/%exe.bbit%
set arg.bbit=/S /allusers
set chk.bbit=%ProgramFiles(x86)%\BleachBit\bleachbit.exe
set regtext.bbit=BleachBit *
set regsearch.bbit=%uninstallreg32%
set regurl.bbit=https://www.bleachbit.org/download/windows
set regexp.bbit=substring-before(substring-after(/html/body/div[2]/div[1]/div[5]/div/div[2]/div[2]/div/div/div/div/div/div/p,'BleachBit '),' for')


set pkgver.7zip=2201
set ver.7zip=22.01.00.0
set name.7zip=7-Zip
set exe.7zip=7z%pkgver.7zip%-x64.msi
set url.7zip=https://www.7-zip.org/a/%exe.7zip%
set arg.7zip=/qn /norestart
set chk.7zip=%ProgramFiles%\7-Zip\7z.exe
set regtext.7zip=7-Zip *
set regsearch.7zip=%uninstallreg64%
set regurl.7zip=https://www.7-zip.org/download.html
set regexp.7zip=substring(/html/body/table/tbody/tr/td[2]/p[1]/b,16,5)

set pkgver.spdf=3.4.6
set ver.spdf=%pkgver.spdf%
set name.spdf=Sumatra PDF
set exe.spdf=SumatraPDF-%pkgver.spdf%-64-install.exe
set url.spdf=https://files.sumatrapdfreader.org/file/kjk-files/software/sumatrapdf/rel/%pkgver.spdf%/%exe.spdf%
set arg.spdf=-s -all-users
set chk.spdf=%ProgramFiles%\SumatraPDF\SumatraPDF.exe
set regtext.spdf=SumatraPDF
set regsearch.spdf=%uninstallreg64%
set regurl.spdf=https://github.com/sumatrapdfreader/sumatrapdf/
set regexp.spdf=substring-before(/html/body/div[4]/div/main/turbo-frame/div/div/div/div[3]/div[2]/div/div[2]/div/a/div/div[1]/span[1],' ') 

set pkgver.tpaint=0.9.28
set ver.tpaint=0.9.28
set name.tpaint=TuxPaint
set exe.tpaint=tuxpaint-%pkgver.tpaint%-windows-sdl2.0-x86_64-installer.exe
set url.tpaint=https://sourceforge.net/projects/tuxpaint/files/tuxpaint/0.9.28/%exe.tpaint%/download
set arg.tpaint=/VERYSILENT /NORESTART
set chk.tpaint=%ProgramFiles%\TuxPaint\tuxpaint.exe
set regtext.tpaint=Tux Paint 0*
set regsearch.tpaint=%uninstallreg64%
set regurl.tpaint=https://tuxpaint.org/download/windows/
set regexp.tpaint=substring-before(substring-after(/html/body/div/div[1]/main/div/table/tbody/tr/td[1]/p[2],'Version: '),'-')

set pkgver.tstamps=2022-06-04
set ver.tstamps=2022-06-04
set name.tstamps=TuxPaint Stamps
set exe.tstamps=tuxpaint-stamps-%pkgver.tstamps%-windows-installer.exe
set url.tstamps=https://sourceforge.net/projects/tuxpaint/files/tuxpaint-stamps/%pkgver.tstamps%/%exe.tstamps%/download
set arg.tstamps=/VERYSILENT /NORESTART
set chk.tstamps=%ProgramFiles%\TuxPaint\unins001.exe
set regtext.tstamps=Tux Paint Stamps *
set regsearch.tstamps=%uninstallreg64%
set followup.tstamps=reg import "%tpath%!tuxpaint-stamps.reg"
set regurl.tstamps=https://tuxpaint.org/download/windows/
set regexp.tstamps=substring-before(substring-after(/html/body/div/div[1]/main/div/table/tbody/tr/td[2]/p,'Version: '),' Size')

set pkgver.puzzlecollection=20220913.27dd36e
set ver.puzzlecollection=0.0.13248.0
set name.puzzlecollection=Simon Tatham's Portable Puzzle Collection
set exe.puzzlecollection=puzzles-%pkgver.puzzlecollection%-installer.msi
set url.puzzlecollection=https://www.chiark.greenend.org.uk/~sgtatham/puzzles/%exe.puzzlecollection%
set arg.puzzlecollection=/qn /norestart
set chk.puzzlecollection=%ProgramFiles%\Simon Tatham's Portable Puzzle Collection\solo.exe
set regtext.puzzlecollection=Simon Tatham's Portable Puzzle Collection
set regsearch.puzzlecollection=%uninstallreg64%
set regurl.puzzlecollection=https://www.chiark.greenend.org.uk/~sgtatham/puzzles/devel/
set regexp.puzzlecollection=substring-before(substring-after(/html/body/address,'version '),']')

