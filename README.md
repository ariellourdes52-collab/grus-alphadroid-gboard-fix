# grus-alphadroid-gboard-fix

KernelSU + meta-overlayfs workaround for the broken preinstalled Gboard on **Xiaomi Mi 9 SE (grus)** running **AlphaDroid 4.7**.

## Problem

On AlphaDroid 4.7, the preloaded Gboard is installed as:

```text
package: com.android.inputmethod.latin
versionName=15.9.1.799068799-preload-arm64-v8a
versionCode=175370066
codePath=/product/app/LatinIMEGooglePrebuilt
primaryCpuAbi=arm64-v8a
```

The package remains enabled and visible to Package Manager, but after reboot the keyboard may fail to open/show.

Installing a newer Gboard as a normal `/data/app` update can work before reboot, but AlphaDroid may fall back to the broken preload after reboot.

## Tested workaround

This project builds a **systemless KernelSU module** that replaces:

```text
/system/product/app/LatinIMEGooglePrebuilt
```

through **meta-overlayfs**, leaving the original `/product` partition untouched.

Tested working replacement:

```text
Gboard 18.1.4.962075747-release-armeabi-v7a
versionCode=175963085
minSdk=26
targetSdk=37
```

After installation and reboot, Package Manager reports:

```text
codePath=/product/app/LatinIMEGooglePrebuilt
primaryCpuAbi=armeabi-v7a
versionName=18.1.4.962075747-release-armeabi-v7a
flags=[ SYSTEM ... ]
```

and Gboard continues working after reboot.

## Requirements

- Xiaomi Mi 9 SE (`grus`)
- AlphaDroid 4.7
- KernelSU / KernelSU-Next
- meta-overlayfs installed and working
- A compatible Gboard APK supplied by the user
- Windows PowerShell 5.1+ or PowerShell 7+

## Why the APK is not included

Gboard is proprietary software from Google. This repository does **not** redistribute the Gboard APK.

Download a compatible APK from a source you trust, then use the included builder.

The build tested on real hardware was:

```text
18.1.4.962075747-release-armeabi-v7a
```

The Mi 9 SE supports `armeabi-v7a` apps even though its SoC is 64-bit.

## Build the module

1. Clone or download this repository.
2. Put your Gboard APK somewhere on your PC.
3. Open PowerShell in the repository directory.
4. Run:

```powershell
.\build.ps1 -ApkPath "C:\path\to\gboard.apk"
```

The script creates:

```text
out\Grus-AlphaDroid-Gboard-Fix-v1.0-KernelSU.zip
```

## Install

1. Make sure **meta-overlayfs** is already installed and active.
2. Open KernelSU.
3. Go to **Modules**.
4. Choose **Install from storage**.
5. Select the generated ZIP.
6. Reboot.

## Verify

From a PC with ADB:

```powershell
.\adb.exe shell "dumpsys package com.android.inputmethod.latin | grep -E 'codePath|versionName|versionCode|primaryCpuAbi|flags='"
```

Expected values should show the replacement Gboard as the system version.

Also verify the selected IME:

```powershell
.\adb.exe shell "settings get secure default_input_method"
```

Expected:

```text
com.android.inputmethod.latin/.LatinIME
```

## Emergency rollback

If the keyboard fails or the device has trouble after installation, disable the module from ADB/root shell:

```sh
su -c 'touch /data/adb/modules/gboard_factory/disable'
reboot
```

This exposes the original AlphaDroid preload again.

To re-enable the fix:

```sh
su -c 'rm -f /data/adb/modules/gboard_factory/disable'
reboot
```

## Notes

- This module is **systemless**. It does not permanently modify `/product`.
- A full OTA may replace the ROM's original Gboard, but the module can continue overlaying it as long as KernelSU and meta-overlayfs still work after the update.
- If a future AlphaDroid build includes a newer, working Gboard, remove or disable this module before deciding whether it is still needed.
- This workaround was developed and tested on real Xiaomi Mi 9 SE hardware.

## Disclaimer

Use at your own risk. Root modules can cause boot or input-method problems if used on unsupported ROMs/devices. Keep another input method available as a backup when testing.
