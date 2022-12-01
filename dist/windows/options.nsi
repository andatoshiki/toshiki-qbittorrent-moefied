Unicode true
ManifestDPIAware true
;Compress the header too
!packhdr "$%TEMP%\exehead.tmp" 'upx.exe -9 --best --ultra-brute "$%TEMP%\exehead.tmp"'

;Setting the compression
SetCompressor /SOLID LZMA
SetCompressorDictSize 64
XPStyle on

;Uncomment when packaging 64bit qbittorrent
;!define APP64BIT

;Uncomment when packaging qbittorrent with Qt6
;!define APPQT6

!include "MUI.nsh"
!include "UAC.nsh"
!include "FileFunc.nsh"
!include "WinVer.nsh"
!ifdef APP64BIT
!include "x64.nsh"
!endif

;For the file association
!define SHCNE_ASSOCCHANGED 0x8000000
!define SHCNF_IDLIST 0

;For special folder detection
!define CSIDL_APPDATA '0x1A' ;Application Data path
!define CSIDL_LOCALAPPDATA '0x1C' ;Local Application Data path

; Program specific
!define PROG_VERSION "1.0.0.1"

!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION PageFinishRun
!define MUI_FINISHPAGE_RUN_TEXT $(launch_qbt)

!ifdef APP64BIT
  ; The name of the installer
  Name "qbittorrent @安田俊樹 ${PROG_VERSION} x64"

  ; The file to write
  OutFile "toshiki-qbittorrent-moefied-${PROG_VERSION}-x64-setup.exe"
!else ifdef APPQT6
  ; The name of the installer
  Name "Toshiki's qBittorrent Moefied ${PROG_VERSION} x64"

  ; The file to write
  OutFile "toshiki-qbittorrent-moefied-${PROG_VERSION}-Qt6-setup.exe"
!else
  ; The name of the installer
  Name "toshiki-qbittorrent-moefied ${PROG_VERSION}"

  ; The file to write
  OutFile "toshiki-qbittorrent-moefied-${PROG_VERSION}-setup.exe"
!endif

;Installer Version Information
VIAddVersionKey "ProductName" "Toshiki's qBittorrent Moefied"
VIAddVersionKey "CompanyName" "Toshiki Dev"
VIAddVersionKey "LegalCopyright" "Copyright ©2022-present Toshiki's qBittorrent Moefied"
VIAddVersionKey "FileDescription" "Toshiki's qBittorrent Moefied - Moefied cute bitorrent client for universal platforms!"
VIAddVersionKey "FileVersion" "${PROG_VERSION}"

VIProductVersion "${PROG_VERSION}.0"

; The default installation directory. It changes depending if we install in the 64bit dir or not.
; A caveat of this is if a user has installed a 32bit version and then runs the 64bit installer
; (which in turn launches the 32bit uninstaller first) the value will still point to the 32bit location.
; The user has to manually uninstall the old version and THEN run the 64bit installer
!ifdef APP64BIT
  InstallDir $PROGRAMFILES64\qBittorrent
!else ifdef APPQT6
  InstallDir $PROGRAMFILES64\qBittorrent
!else
  InstallDir $PROGRAMFILES32\qBittorrent
!endif

; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
; InstallDirRegKey HKLM "Software\qbittorrent" InstallLocation
InstallDirRegKey "HKLM" "Software\qbittorrent" "InstallLocation"

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------
;General Settings
!define MUI_ABORTWARNING
!define MUI_HEADERIMAGE
!define MUI_COMPONENTSPAGE_NODESC
;!define MUI_ICON "qbittorrent.ico"
!define MUI_LICENSEPAGE_CHECKBOX
!define MUI_LANGDLL_ALLLANGUAGES

;--------------------------------
;Remember the unistaller/installer language
!define MUI_LANGDLL_REGISTRY_ROOT "HKLM"
!define MUI_LANGDLL_REGISTRY_KEY "Software\qbittorrent"
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

;--------------------------------
;Installer Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt"
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE check_instance
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

;--------------------------------
;Uninstaller Pages
!insertmacro MUI_UNPAGE_CONFIRM
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE un.check_instance
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_RESERVEFILE_LANGDLL
ReserveFile "${NSISDIR}\Plugins\x86-unicode\FindProcDLL.dll"
ReserveFile "${NSISDIR}\Plugins\x86-unicode\UAC.dll"

!macro Init thing
uac_tryagain:
!insertmacro UAC_RunElevated
${Switch} $0
${Case} 0
	${IfThen} $1 = 1 ${|} Quit ${|} ;we are the outer process, the inner process has done its work, we are done
	${IfThen} $3 <> 0 ${|} ${Break} ${|} ;we are admin, let the show go on
	${If} $1 = 3 ;RunAs completed successfully, but with a non-admin user
		MessageBox mb_YesNo|mb_IconExclamation|mb_TopMost|mb_SetForeground "This ${thing} requires admin privileges, try again" /SD IDNO IDYES uac_tryagain IDNO 0
	${EndIf}
	;fall-through and die
${Case} 1223
	MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "This ${thing} requires admin privileges, aborting!"
	Quit
${Case} 1062
	MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Logon service not running, aborting!"
	Quit
${Default}
	MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Unable to elevate , error $0"
	Quit
${EndSwitch}

SetShellVarContext all
!macroend