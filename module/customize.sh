SKIPUNZIP=0

REPLACE="
/system/product/app/LatinIMEGooglePrebuilt
"

ui_print "- AlphaDroid Gboard Fix for Xiaomi Mi 9 SE (grus)"
ui_print "- Original /product files remain untouched"

DEVICE="$(getprop ro.product.device 2>/dev/null)"
DEVICE_VENDOR="$(getprop ro.product.vendor.device 2>/dev/null)"
if [ "$DEVICE" != "grus" ] && [ "$DEVICE_VENDOR" != "grus" ]; then
  abort "! Unsupported device: ${DEVICE:-unknown}. This module is intended for Xiaomi Mi 9 SE (grus)."
fi

DEST="$MODPATH/system/product/app/LatinIMEGooglePrebuilt"
BUNDLED="$DEST/LatinIMEGooglePrebuilt.apk"
SRC=""

# Local build.ps1 packages the APK directly in the module.
if [ -f "$BUNDLED" ]; then
  SRC="$BUNDLED"
  ui_print "- Using APK bundled by the local builder"
else
  # Public standalone ZIP does not redistribute Gboard.
  # The user supplies /Download/gboard.apk before installing.
  for CANDIDATE in /sdcard/Download/gboard.apk /storage/emulated/0/Download/gboard.apk; do
    if [ -f "$CANDIDATE" ]; then
      SRC="$CANDIDATE"
      break
    fi
  done

  if [ -z "$SRC" ]; then
    abort "! gboard.apk not found. Download a compatible Gboard armeabi-v7a APK, rename it to gboard.apk, place it in Internal storage/Download, then install this module again."
  fi

  ui_print "- Found user APK: $SRC"
fi

if ! unzip -l "$SRC" 2>/dev/null | grep -q "AndroidManifest.xml"; then
  abort "! The selected Gboard file is not a valid APK/ZIP file."
fi

if ! unzip -l "$SRC" 2>/dev/null | grep -q "lib/armeabi-v7a/"; then
  abort "! This APK does not contain armeabi-v7a native libraries. Use the armeabi-v7a Gboard build tested for this fix."
fi

if [ "$SRC" != "$BUNDLED" ]; then
  rm -rf "$DEST"
  mkdir -p "$DEST" || abort "! Could not create module target directory."
  cp -f "$SRC" "$BUNDLED" || abort "! Failed to copy gboard.apk into the module."
fi

chmod 0644 "$BUNDLED"

ui_print "- Gboard prepared in the systemless overlay"
ui_print "- Target: /product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk"
ui_print "- Reboot after installation"
