# grus-alphadroid-gboard-fix

KernelSU + meta-overlayfs workaround for the broken preinstalled Gboard on **Xiaomi Mi 9 SE (grus)** running **AlphaDroid 4.7**.

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

Installing a newer Gboard normally in `/data/app` can work before reboot, but AlphaDroid may fall back to the broken preload after reboot.

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

After reboot, the tested device reports:

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

4. Download:

```text
releases/Grus-AlphaDroid-Gboard-Fix-v1.0-KernelSU.zip
```

5. Open **KernelSU → Modules → Install from storage** and select that ZIP.
6. The installer checks that the phone is `grus`, finds `gboard.apk`, verifies that it is an APK and that it contains `armeabi-v7a` native libraries, then copies it into the systemless overlay.
7. Reboot.

The tested APK build is:

```text
18.1.4.962075747-release-armeabi-v7a
```

## Optional PC builder

The original PowerShell builder is still included. It creates a ZIP with your locally supplied APK already embedded:

```powershell
.\build.ps1 -ApkPath "C:\path\to\gboard.apk"
```

Output:

```text
out\Grus-AlphaDroid-Gboard-Fix-v1.0-KernelSU.zip
```

Do not redistribute a locally built ZIP that contains Gboard.

## Verify

From a PC with ADB:

```powershell
.\adb.exe shell "dumpsys package com.android.inputmethod.latin | grep -E 'codePath|versionName|versionCode|primaryCpuAbi|flags='"
```

Also verify the selected IME:

```powershell
.\adb.exe shell "settings get secure default_input_method"
```

Expected:

```text
com.android.inputmethod.latin/.LatinIME
```

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

## Disclaimer

Use at your own risk. Root modules can cause boot or input-method problems when used on unsupported devices, ROMs or APK variants. Keep another input method available as a backup while testing.
