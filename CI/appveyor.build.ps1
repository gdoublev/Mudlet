cd "$Env:APPVEYOR_BUILD_FOLDER"

. CI\appveyor.functions.ps1
SetQtBaseDir "C:\src\verbose_output.log"
SetMingwBaseDir "C:\src\verbose_output.log"
SetLuarocksPath "C:\src\verbose_output.log"

. CI\appveyor.set-build-info.ps1
. CI\appveyor.validate_deployment.ps1

cd "$Env:APPVEYOR_BUILD_FOLDER\src"

$Env:PATH="C:\Program Files (x86)\CMake\bin;C:\Program Files\7-Zip;C:\Program Files\ccache;$Env:QT_BASE_DIR\bin;$Env:MINGW_BASE_DIR\bin;" + (($Env:PATH.Split(';') | Where-Object { $_ -ne 'C:\Program Files\Git\usr\bin' }) -join ';')
# enable for a debug build (1/2)
# qmake CONFIG+=release CONFIG+=force_debug_info mudlet.pro
qmake CONFIG+=release mudlet.pro
if("$LastExitCode" -ne "0"){
  exit 1
}

mingw32-make -j $(Get-WmiObject win32_processor | Select -ExpandProperty "NumberOfLogicalProcessors")
if("$LastExitCode" -ne "0"){
  exit 1
}

cd "$Env:APPVEYOR_BUILD_FOLDER"

.\CI\appveyor.after_success.ps1
if("$LastExitCode" -ne "0"){
  exit 1
}
