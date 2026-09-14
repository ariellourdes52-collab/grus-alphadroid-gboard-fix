# Changelog

## v1.0 — 2026-09-14

Initial public release.

- Documents the AlphaDroid 4.7 Gboard preload failure on Xiaomi Mi 9 SE (`grus`).
- Adds a KernelSU/meta-overlayfs module using module id `gboard_factory`.
- Adds a public standalone installer ZIP that does **not** redistribute Gboard.
- Standalone flow reads a user-supplied `/sdcard/Download/gboard.apk` during KernelSU installation.
- Installer refuses non-`grus` devices and verifies the APK/ZIP plus `armeabi-v7a` native libraries.
- Keeps the optional PowerShell builder for creating a private ZIP with a locally supplied APK embedded.
- Uses `/system/product/app/LatinIMEGooglePrebuilt` as the systemless replacement target.
- Includes rollback instructions that restore the untouched ROM preload.

### Tested replacement

```text
Gboard 18.1.4.962075747-release-armeabi-v7a
versionCode=175963085
```

### Tested environment

```text
Device: Xiaomi Mi 9 SE (grus)
ROM: AlphaDroid 4.7
Root: KernelSU / KernelSU-Next
Overlay: meta-overlayfs 1.3.1
```
