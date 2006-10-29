;
; This is an NSIS installer script for DesktopSaver
;

!include "MUI.nsh"

!define VERSION 2.0.2

Name "DesktopSaver ${VERSION}"
OutFile "DesktopSaver-${VERSION}-installer.exe"
InstallDir $PROGRAMFILES\DesktopSaver
BrandingText " "

!define MUI_ABORTWARNING

!insertmacro MUI_PAGE_LICENSE "..\license.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
  
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM SOFTWARE\DesktopSaver "Install_Dir"

ComponentText "This will install DesktopSaver to your computer."
DirText "Choose a directory to install in to:"

!include WinMessages.nsh
 
Function CloseProgram 
  Exch $1
  Push $0
  loop:
    FindWindow $0 $1
    IntCmp $0 0 done
      #SendMessage $0 ${WM_DESTROY} 0 0
      SendMessage $0 ${WM_CLOSE} 0 0
    Sleep 100 
    Goto loop 
  done: 
  Pop $0 
  Pop $1
FunctionEnd

Function un.CloseProgram 
  Exch $1
  Push $0
  loop:
    FindWindow $0 $1
    IntCmp $0 0 done
      #SendMessage $0 ${WM_DESTROY} 0 0
      SendMessage $0 ${WM_CLOSE} 0 0
    Sleep 100 
    Goto loop 
  done: 
  Pop $0 
  Pop $1
FunctionEnd

Function .onMouseOverSection
  FindWindow $R0 "#32770" "" $HWNDPARENT
  GetDlgItem $R0 $R0 1043 ; description item (must be added to the UI)

  StrCmp $0 0 "" +2
    SendMessage $R0 ${WM_SETTEXT} 0 "STR:Installs the DesktopSaver application files."

  StrCmp $0 1 "" +2
    SendMessage $R0 ${WM_SETTEXT} 0 "STR:Adds a DesktopSaver Start Menu group to the 'All Programs' section of your Start Menu."

  StrCmp $0 2 "" +2
    SendMessage $R0 ${WM_SETTEXT} 0 "STR:Starts DesktopSaver immediately after install is complete."

  StrCmp $0 3 "" +2
    SendMessage $R0 ${WM_SETTEXT} 0 "STR:Causes DesktopSaver to run each time Windows starts."
FunctionEnd


Section "!DesktopSaver"
SectionIn RO

  ; stop the application if it's running (this only works on WinXP)
  DetailPrint "Attempting to stop any old versions of DesktopSaver before installing..."
  Push "desktop_saver"
  Call CloseProgram  
  Sleep 1000

  SetOutPath $INSTDIR

  File "desktop_saver.exe"
  File "..\readme.txt"
  File "..\license.txt"

  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\DesktopSaver "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DesktopSaver" "DisplayName" "DesktopSaver (remove only)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DesktopSaver" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteUninstaller "uninstall.exe"

SectionEnd


Section "Start Menu Shortcuts"
  CreateDirectory "$SMPROGRAMS\DesktopSaver"
  CreateShortCut "$SMPROGRAMS\DesktopSaver\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\DesktopSaver\DesktopSaver ${VERSION}.lnk" "$INSTDIR\desktop_saver.exe" "" "$INSTDIR\desktop_saver.exe" 0
  CreateShortCut "$SMPROGRAMS\DesktopSaver\DesktopSaver Readme.lnk" "$INSTDIR\readme.txt"
  CreateShortCut "$SMPROGRAMS\DesktopSaver\DesktopSaver License.lnk" "$INSTDIR\license.txt"
SectionEnd

Section "Run After Install"
  Exec '"$INSTDIR\desktop_saver.exe"'
SectionEnd

Section /o "Always Run at Startup"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "DesktopSaver" '"$INSTDIR\desktop_saver.exe"'
SectionEnd


UninstallText "This will uninstall DesktopSaver. Hit next to continue."
Section "Uninstall"

  ; stop the application if it's running (this only works on WinXP)
  DetailPrint "Attempting to stop DesktopSaver before uninstalling..."
  Push "desktop_saver"
  Call un.CloseProgram  
  Sleep 1000

  ; remove registry keys
  ;
  ; NOTE: this intentionally leaves the "Install_Dir"
  ; entry in HKLM\SOFTWARE\DesktopSaver in the event of
  ; subsequent reinstalls/upgrades
  ;
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DesktopSaver"
  DeleteRegKey HKCU SOFTWARE\DesktopSaver

  ; remove the "run at startup" entry
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "DesktopSaver"

  ; delete program files
  Delete $INSTDIR\readme.txt
  Delete $INSTDIR\license.txt
  Delete $INSTDIR\uninstall.exe
  Delete $INSTDIR\desktop_saver.exe

  ; delete left over icon history file
  Delete "$APPDATA\DesktopSaver\*.*"
  RmDir "$APPDATA\DesktopSaver"

  ; remove Start Menu shortcuts
  Delete "$SMPROGRAMS\DesktopSaver\*.*"
  RMDir "$SMPROGRAMS\DesktopSaver"

  RMDir /r "$INSTDIR"

SectionEnd

