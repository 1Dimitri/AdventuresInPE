if "%WinPERoot%"=="" goto :usage
if "%1"=="" goto :usage
set ChosenArch=%1
set PEDir=C:\PE%ChosenArch%Build
set PEKitSrc=%WinPERoot%
set PEKitArch=%PEKitSrc%\%ChosenArch%
set PEKitPkg=%PEKitArch%\WinPE_OCs

set BootWim=%PEdir%\media\sources\boot.wim
set MountDir=%PEDir%\mount
set PEFSWindowsDir=%MountDir%\windows
set PEFSSystem32=%PEFSWindowsDir%\system32
set PEFSStartnet=%PEFSSystem32%\startnet.cmd

set
pause

REM Copy
call copype.cmd %ChosenArch% %PEDir%

REM Mount
Dism /Mount-Image /ImageFile:"%bootwim%" /index:1 /MountDir:"%mountdir%"

REM Add powercfg full to startup
REM https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-mount-and-customize#highperformance
echo powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >> %PEFSStartNet%


REM Add Powershell Support
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\WinPE-WMI.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\en-us\WinPE-WMI_en-us.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\WinPE-NetFX.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\en-us\WinPE-NetFX_en-us.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\WinPE-Scripting.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\en-us\WinPE-Scripting_en-us.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\WinPE-PowerShell.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\en-us\WinPE-PowerShell_en-us.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\WinPE-StorageWMI.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\en-us\WinPE-StorageWMI_en-us.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\WinPE-DismCmdlets.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\en-us\WinPE-DismCmdlets_en-us.cab"

REM Secure Boot
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\WinPE-SecureBootCmdlets.cab"
REM There is no language specific here
REM Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\en-us\WinPE-SecureBootCmdlets_en-us.cab"

REM Enhanced Storage
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\WinPE-EnhancedStorage.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\en-us\WinPE-EnhancedStorage_en-us.cab"

REM Dot3Svc (802.1X Authentication), not started by default
REM https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-network-drivers-initializing-and-adding-drivers

Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\WinPE-Dot3Svc.cab"
Dism /Add-Package /Image:"%MountDir%" /PackagePath:"%PEKitPkg%\en-us\WinPE-Dot3Svc_en-us.cab"

REM Unmount Image
Dism /Unmount-Image /MountDir:"%MountDir%" /commit

REM Generate ISO
call MakeWinPEMedia /ISO %PEDir% %PEDir%\WinPE10.iso

goto :eof
:usage
echo %~nx0  { arm ^| arm64 ^| x86 ^| amd64 }
echo.
echo Please indicate the architecture.
echo Please use this cmd from a "Deployment Wizard shell"
