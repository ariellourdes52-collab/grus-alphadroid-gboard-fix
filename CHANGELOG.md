# Changelog

## v1.0 — 2026-09-14

Initial public release.

- Documents the AlphaDroid 4.7 Gboard preload failure on Xiaomi Mi 9 SE (`grus`).
- Adds a KernelSU/meta-overlayfs module template using module id `gboard_factory`.
- Adds a PowerShell builder that injects a user-supplied Gboard APK.
- Uses `/system/product/app/LatinIMEGooglePrebuilt` as the systemless replacement target.
- Validates ZIP paths to avoid Windows backslash packaging issues.
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
