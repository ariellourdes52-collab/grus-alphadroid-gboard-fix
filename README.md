# grus-alphadroid-gboard-fix

KernelSU + meta-overlayfs workaround for the broken preinstalled Gboard on **Xiaomi Mi 9 SE (grus)** running **AlphaDroid 4.7**.

**Author:** Ariel Torres | Instagram: **@draccesoriosrd**

## Problem

AlphaDroid 4.7 ships this Gboard preload:

```text
package: com.android.inputmethod.latin
versionName=15.9.1.799068799-preload-arm64-v8a
versionCode=175370066
codePath=/product/app/LatinIMEGooglePrebuilt
primaryCpuAbi=arm64-v8a
```

On the tested device, the package remains enabled and visible to Package Manager, but after reboot the keyboard may fail to open/show.

Installing a newer Gboard normally in `/data/app` can work before reboot, but on the test device the ROM returned to the preload after reboot.

## Tested fix

The working replacement tested on real hardware is:

```text
Gboard 18.1.4.962075747-release-armeabi-v7a
versionCode=175963085
minSdk=26
targetSdk=37
```

The fix replaces the preload systemlessly through **KernelSU + meta-overlayfs** at:

```text
/system/product/app/LatinIMEGooglePrebuilt
```

The original `/product` partition is not modified.

After reboot, the validated device reports:

```text
codePath=/product/app/LatinIMEGooglePrebuilt
primaryCpuAbi=armeabi-v7a
versionCode=175963085 minSdk=26 targetSdk=37
versionName=18.1.4.962075747-release-armeabi-v7a
flags=[ SYSTEM HAS_CODE ALLOW_CLEAR_USER_DATA ALLOW_BACKUP RESTORE_ANY_VERSION ]
```

The default IME remains:

```text
com.android.inputmethod.latin/.LatinIME
```

and the module contains the copied APK at:

```text
/data/adb/modules/gboard_factory/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk
```

The standalone installer was successfully tested after reboot on a real Xiaomi Mi 9 SE.

## Requirements

- Xiaomi Mi 9 SE (`grus`)
- AlphaDroid 4.7
- KernelSU / KernelSU-Next
- meta-overlayfs installed and working
- A compatible **armeabi-v7a** Gboard APK supplied by the user

## Quick install — no PC builder required

The public installer ZIP does **not** contain Gboard. Gboard is proprietary Google software and is not redistributed by this project.

1. Download a compatible **armeabi-v7a** Gboard APK from a source you trust.
2. Rename the APK exactly to:

```text
gboard.apk
```

3. Put it in the phone's internal storage:

```text
/Download/gboard.apk
```

which normally maps to:

```text
/sdcard/Download/gboard.apk
```

4. Download the installer ZIP:

```text
releases/Grus-AlphaDroid-Gboard-Fix-v1.0-KernelSU.zip
```

5. Open **KernelSU → Modules → Install from storage** and select that ZIP.
6. The installer checks that the device is `grus`, finds `gboard.apk`, verifies that it is a valid APK/ZIP and that it contains `armeabi-v7a` native libraries, then copies it into the systemless overlay.
7. Reboot.
8. Open a text field and confirm Gboard appears normally.

The exact APK build validated on hardware is:

```text
18.1.4.962075747-release-armeabi-v7a
```

## Verify after reboot

From a PC with ADB:

```powershell
.\adb.exe shell "dumpsys package com.android.inputmethod.latin | grep -E 'codePath|versionName|versionCode|primaryCpuAbi|flags='"
```

Expected key values:

```text
codePath=/product/app/LatinIMEGooglePrebuilt
primaryCpuAbi=armeabi-v7a
versionCode=175963085
versionName=18.1.4.962075747-release-armeabi-v7a
flags=[ SYSTEM ... ]
```

Check the selected IME:

```powershell
.\adb.exe shell "settings get secure default_input_method"
```

Expected:

```text
com.android.inputmethod.latin/.LatinIME
```

Check the APK copied into the active module:

```powershell
.\adb.exe shell "su -c 'ls -lh /data/adb/modules/gboard_factory/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk'"
```

A successful installation should show the Gboard APK there. The validated 18.1.4 build is about **66 MB**.

## Updating an existing installation

The module id is still:

```text
gboard_factory
```

If an older version of this fix is already working, install the new ZIP directly from KernelSU. There is normally no need to uninstall the old module first; KernelSU prepares the replacement and applies it after reboot.

Make sure `/sdcard/Download/gboard.apk` exists before installing the standalone ZIP.

## Optional PC builder

The PowerShell builder is still included. It creates a private ZIP with your locally supplied APK already embedded:

```powershell
.\build.ps1 -ApkPath "C:\path\to\gboard.apk"
```

Output:

```text
out\Grus-AlphaDroid-Gboard-Fix-v1.0-KernelSU.zip
```

Do not redistribute a locally built ZIP that contains Gboard.

## Emergency rollback

Disable the module:

```sh
su -c 'touch /data/adb/modules/gboard_factory/disable'
reboot
```

This exposes the untouched AlphaDroid preload again.

Re-enable it with:

```sh
su -c 'rm -f /data/adb/modules/gboard_factory/disable'
reboot
```

## Notes

- Module id: `gboard_factory`
- The fix is **systemless** and does not permanently modify `/product`.
- A full OTA can replace the ROM's original files. The overlay can continue working if KernelSU and meta-overlayfs still work after the OTA.
- If a future AlphaDroid build includes a newer working Gboard, disable/remove this module before deciding whether it is still needed.
- The public standalone installer is device-locked to `grus` for safety.
- The repository intentionally does not include or redistribute the Gboard APK.

## Disclaimer

Use at your own risk. Root modules can cause boot or input-method problems when used on unsupported devices, ROMs or APK variants. Keep another input method available as a backup while testing.
