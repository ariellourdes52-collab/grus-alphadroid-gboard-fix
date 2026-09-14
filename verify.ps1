param(
    [string]$Adb = ".\adb.exe"
)

$ErrorActionPreference = "Stop"

Write-Host "Checking connected Android device..."
& $Adb get-state

Write-Host ""
Write-Host "Gboard package state:"
& $Adb shell "dumpsys package com.android.inputmethod.latin | grep -E 'codePath|versionName|versionCode|primaryCpuAbi|flags='"

Write-Host ""
Write-Host "Default input method:"
& $Adb shell "settings get secure default_input_method"

Write-Host ""
Write-Host "Active KernelSU modules:"
& $Adb shell "su -c 'ls -1 /data/adb/modules 2>/dev/null'"

Write-Host ""
Write-Host "Expected working replacement:"
Write-Host "  codePath=/product/app/LatinIMEGooglePrebuilt"
Write-Host "  versionName=18.1.4.962075747-release-armeabi-v7a (tested build)"
Write-Host "  primaryCpuAbi=armeabi-v7a"
Write-Host "  flags include SYSTEM"
Write-Host "  default_input_method=com.android.inputmethod.latin/.LatinIME"
