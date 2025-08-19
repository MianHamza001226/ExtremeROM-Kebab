#!/usr/bin/env bash
set -euo pipefail

APPLY_PATCH() {
    local APK="$1"
    local PATCH="$SRC_DIR/unica/patches/product_feature/$2"
    local OUT

    DECODE_APK "$APK"

    cd "$APKTOOL_DIR/$APK" || exit 1
    if ! OUT=$(patch -p1 -s -t -N --dry-run < "$PATCH" 2>&1); then
        if ! echo "$OUT" | grep -q "Skipping patch"; then
            echo "Patch failed: $PATCH"
            exit 1
        fi
    fi
    patch -p1 -s -t -N --no-backup-if-mismatch < "$PATCH" >/dev/null 2>&1 || true
    cd - >/dev/null 2>&1
}

GET_FP_SENSOR_TYPE() {
    case "$1" in
        *ultrasonic*) echo "ultrasonic" ;;
        *optical*)    echo "optical" ;;
        *side*)       echo "side" ;;
        *)            echo "Unsupported type: $1" ; exit 1 ;;
    esac
}

MODEL=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 1)
REGION=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 2)

if [ "$SOURCE_PRODUCT_FIRST_API_LEVEL" != "$TARGET_PRODUCT_FIRST_API_LEVEL" ]; then
    echo "Applying MAINLINE_API_LEVEL patches"

    DECODE_APK "system/framework/services.jar"

    FTP="
    system/framework/services.jar/smali/com/android/server/SystemServer.smali
    system/framework/services.jar/smali/com/android/server/enterprise/hdm/HdmVendorController.smali
    system/framework/services.jar/smali/com/android/server/enterprise/hdm/HdmSakManager.smali
    system/framework/services.jar/smali/com/android/server/knox/dar/ddar/ta/TAProxy.smali
    system/framework/services.jar/smali_classes2/com/android/server/power/PowerManagerUtil.smali
    system/framework/services.jar/smali_classes2/com/android/server/sepunion/EngmodeService\$EngmodeTimeThread.smali
    "
    for f in $FTP; do
        sed -i \
            "s/\"MAINLINE_API_LEVEL: $SOURCE_PRODUCT_FIRST_API_LEVEL\"/\"MAINLINE_API_LEVEL: $TARGET_PRODUCT_FIRST_API_LEVEL\"/g" \
            "$APKTOOL_DIR/$f"
        sed -i "s/\"$SOURCE_PRODUCT_FIRST_API_LEVEL\"/\"$TARGET_PRODUCT_FIRST_API_LEVEL\"/g" "$APKTOOL_DIR/$f"
    done
fi

if [ "$SOURCE_AUTO_BRIGHTNESS_TYPE" != "$TARGET_AUTO_BRIGHTNESS_TYPE" ] && [ "$TARGET_AUTO_BRIGHTNESS_TYPE" != "4" ]; then
    echo "Applying auto brightness type patches"

    DECODE_APK "system/framework/services.jar"
    DECODE_APK "system/framework/ssrm.jar"
    DECODE_APK "system/priv-app/SecSettings/SecSettings.apk"

    FTP="
    system/framework/services.jar/smali_classes2/com/android/server/power/PowerManagerUtil.smali
    system/framework/ssrm.jar/smali/com/android/server/ssrm/PreMonitor.smali
    system/priv-app/SecSettings/SecSettings.apk/smali_classes4/com/samsung/android/settings/Rune.smali
    "
    for f in $FTP; do
        sed -i "s/\"$SOURCE_AUTO_BRIGHTNESS_TYPE\"/\"$TARGET_AUTO_BRIGHTNESS_TYPE\"/g" "$APKTOOL_DIR/$f"
    done

    if [ "$TARGET_AUTO_BRIGHTNESS_TYPE" = "3" ]; then
        HEX_PATCH "$WORK_DIR/system/system/lib64/libsensorservice.so" "0660009420008052" "0660009400008052"
    fi
fi

if [ "$SOURCE_HAS_QHD_DISPLAY" = "true" ]; then
    if [ "$TARGET_HAS_QHD_DISPLAY" != "true" ]; then
        echo "Applying multi resolution patches"
        ADD_TO_WORK_DIR "e1qzcx" "system" "."
        APPLY_PATCH "system/framework/framework.jar" "resolution/framework.jar/0001-Disable-dynamic-resolution-control.patch"
        APPLY_PATCH "system/framework/gamemanager.jar" "resolution/gamemanager.jar/0001-Disable-dynamic-resolution-control.patch"
        APPLY_PATCH "system/priv-app/SecSettings/SecSettings.apk" "resolution/SecSettings.apk/0001-Disable-dynamic-resolution-control.patch"
    fi
fi

if [ "$(GET_FP_SENSOR_TYPE "$SOURCE_FP_SENSOR_CONFIG")" != "$(GET_FP_SENSOR_TYPE "$TARGET_FP_SENSOR_CONFIG")" ]; then
    echo "Applying fingerprint sensor patches"

    DECODE_APK "system/framework/framework.jar"
    DECODE_APK "system/framework/services.jar"
    DECODE_APK "system/priv-app/SecSettings/SecSettings.apk"
    DECODE_APK "system/priv-app/BiometricSetting/BiometricSetting.apk"

    FTP="
    system/framework/framework.jar/smali_classes2/android/hardware/fingerprint/FingerprintManager.smali
    system/framework/framework.jar/smali_classes2/android/hardware/fingerprint/HidlFingerprintSensorConfig.smali
    system/framework/framework.jar/smali_classes5/com/samsung/android/bio/fingerprint/SemFingerprintManager.smali
    system/framework/framework.jar/smali_classes5/com/samsung/android/bio/fingerprint/SemFingerprintManager\$Characteristics.smali
    system/framework/framework.jar/smali_classes6/com/samsung/android/rune/InputRune.smali
    system/framework/services.jar/smali/com/android/server/biometrics/sensors/fingerprint/FingerprintUtils.smali
    system/priv-app/SecSettings/SecSettings.apk/smali_classes4/com/samsung/android/settings/biometrics/fingerprint/FingerprintSettingsUtils.smali
    "
    for f in $FTP; do
        sed -i "s/$SOURCE_FP_SENSOR_CONFIG/$TARGET_FP_SENSOR_CONFIG/g" "$APKTOOL_DIR/$f"
    done

    if [ "$(GET_FP_SENSOR_TYPE "$TARGET_FP_SENSOR_CONFIG")" = "optical" ]; then
        ADD_TO_WORK_DIR "r12sxxx" "system" "system/bin/surfaceflinger"
        ADD_TO_WORK_DIR "r12sxxx" "system" "system/lib64/libgui.so"
        ADD_TO_WORK_DIR "r12sxxx" "system" "system/lib64/libui.so"
        APPLY_PATCH "system/framework/services.jar" "fingerprint/services.jar/0001-Set-FP_FEATURE_SENSOR_IS_ULTRASONIC-to-false.patch"
        APPLY_PATCH "system/priv-app/BiometricSetting/BiometricSetting.apk" "fingerprint/BiometricSetting.apk/0001-Set-FP_FEATURE_SENSOR_IS_ULTRASONIC-to-false.patch"
        APPLY_PATCH "system/priv-app/BiometricSetting/BiometricSetting.apk" "fingerprint/BiometricSetting.apk/0002-Always-use-ultrasonic-FOD-animation.patch"
    elif [ "$(GET_FP_SENSOR_TYPE "$TARGET_FP_SENSOR_CONFIG")" = "side" ]; then
        ADD_TO_WORK_DIR "b6qxxx" "system" "."
        DELETE_FROM_WORK_DIR "system" "system/priv-app/BiometricSetting/oat"
        APPLY_PATCH "system/framework/services.jar" "fingerprint/services.jar/0001-Set-FP_FEATURE_SENSOR_IS_ULTRASONIC-to-false.patch"
        APPLY_PATCH "system/framework/services.jar" "fingerprint/services.jar/0002-Set-FP_FEATURE_SENSOR_IS_IN_DISPLAY_TYPE-to-false.patch"
    fi
fi

if [ "$SOURCE_HAS_HW_MDNIE" = "true" ]; then
    if [ "$TARGET_HAS_HW_MDNIE" != "true" ]; then
        echo "Applying HW mDNIe patches"
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LCD_SUPPORT_MDNIE_HW" --delete
        APPLY_PATCH "system/framework/framework.jar" "mdnie/hw/framework.jar/0001-Disable-HW-mDNIe.patch"
        APPLY_PATCH "system/framework/services.jar" "mdnie/hw/services.jar/0001-Disable-HW-mDNIe.patch"
        DELETE_FROM_WORK_DIR "system" "system/bin/mafpc_write"
    fi
fi

if [ "$SOURCE_MDNIE_SUPPORT_HDR_EFFECT" = "true" ]; then
    if [ "$TARGET_MDNIE_SUPPORT_HDR_EFFECT" != "true" ]; then
        echo "Applying mDNIe HDR effect patches"
        SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_SUPPORT_HDR_EFFECT" --delete
        APPLY_PATCH "system/priv-app/SecSettings/SecSettings.apk" "mdnie/hdr/SecSettings.apk/0001-Disable-HDR-Settings.patch"
    fi
fi

if [ "$SOURCE_MDNIE_SUPPORTED_MODES" != "$TARGET_MDNIE_SUPPORTED_MODES" ]; then
    echo "Applying mDNIe features patches"
    DECODE_APK "system/framework/services.jar"
    sed -i "s/\"$SOURCE_MDNIE_SUPPORTED_MODES\"/\"$TARGET_MDNIE_SUPPORTED_MODES\"/g" \
        "$APKTOOL_DIR/system/framework/services.jar/smali_classes2/com/samsung/android/hardware/display/SemMdnieManagerService.smali"
fi

if [ "$SOURCE_MDNIE_WEAKNESS_SOLUTION_FUNCTION" != "$TARGET_MDNIE_WEAKNESS_SOLUTION_FUNCTION" ]; then
    echo "Applying mDNIe weakness features patches"
    DECODE_APK "system/framework/framework.jar"
    sed -i "s/\"$SOURCE_MDNIE_WEAKNESS_SOLUTION_FUNCTION\"/\"$TARGET_MDNIE_WEAKNESS_SOLUTION_FUNCTION\"/g" \
        "$APKTOOL_DIR/system/framework/framework.jar/smali_classes4/android/view/accessibility/A11yRune.smali"
fi

# ------------------------------------------------------------------
# Multi-resolution patches (QHD → non-QHD case handled in part 1)
# ------------------------------------------------------------------

if [[ "$SOURCE_HAS_HIGH_REFRESH_RATE" == "true" ]]; then
    if [[ "$TARGET_HAS_HIGH_REFRESH_RATE" != "true" ]]; then
        echo "Applying refresh rate patches"
        ADD_TO_WORK_DIR "e1qzcx" "system" "."

        FTP="system/framework/framework.jar/smali_classes6/com/samsung/android/hardware/display/RefreshRateConfig.smali"
        for f in $FTP; do
            sed -i "s/\"$SOURCE_HFR_SEAMLESS_BRT\"/\"$TARGET_HFR_SEAMLESS_BRT\"/g" "$APKTOOL_DIR/$f"
            sed -i "s/\"$SOURCE_HFR_SEAMLESS_LUX\"/\"$TARGET_HFR_SEAMLESS_LUX\"/g" "$APKTOOL_DIR/$f"
            sed -i "s/\"$SOURCE_HFR_LOW_BRT\"/\"$TARGET_HFR_LOW_BRT\"/g" "$APKTOOL_DIR/$f"
            sed -i "s/\"$SOURCE_HFR_LOW_LUX\"/\"$TARGET_HFR_LOW_LUX\"/g" "$APKTOOL_DIR/$f"
        done

        APPLY_PATCH "system/framework/services.jar" "refresh_rate/services.jar/0001-Disable-high-refresh-rate.patch"
        APPLY_PATCH "system/priv-app/SecSettings/SecSettings.apk" "refresh_rate/SecSettings.apk/0001-Disable-high-refresh-rate.patch"
    fi
fi

# ------------------------------------------------------------------
# Fingerprint sensor patches
# ------------------------------------------------------------------

FP_TYPE=$(GET_FP_SENSOR_TYPE "$SOURCE_FP_SENSOR_TYPE")
if [[ "$FP_TYPE" == "ultrasonic" ]]; then
    if [[ "$TARGET_FP_SENSOR_TYPE" != "ultrasonic" ]]; then
        echo "Applying fingerprint patches"
        ADD_TO_WORK_DIR "e1qzcx" "system" "."

        APPLY_PATCH "system/framework/framework.jar" "fingerprint/framework.jar/0001-Disable-fingerprint-ultrasonic.patch"
        APPLY_PATCH "system/priv-app/SecSettings/SecSettings.apk" "fingerprint/SecSettings.apk/0001-Disable-fingerprint-ultrasonic.patch"
    fi
fi

# ------------------------------------------------------------------
# Done
# ------------------------------------------------------------------

echo "All product feature patches applied successfully."

# ------------------------------------------------------------------
# Secure Folder patches
# ------------------------------------------------------------------

if [[ "$SOURCE_HAS_SECURE_FOLDER" == "true" ]]; then
    if [[ "$TARGET_HAS_SECURE_FOLDER" != "true" ]]; then
        echo "Disabling Secure Folder"
        ADD_TO_WORK_DIR "e1qzcx" "system" "."

        APPLY_PATCH "system/framework/services.jar" "secure_folder/services.jar/0001-Disable-secure-folder.patch"
        APPLY_PATCH "system/priv-app/SecSettings/SecSettings.apk" "secure_folder/SecSettings.apk/0001-Disable-secure-folder.patch"
    fi
fi

# ------------------------------------------------------------------
# Samsung DeX patches
# ------------------------------------------------------------------

if [[ "$SOURCE_HAS_DEX" == "true" ]]; then
    if [[ "$TARGET_HAS_DEX" != "true" ]]; then
        echo "Disabling Samsung DeX"
        ADD_TO_WORK_DIR "e1qzcx" "system" "."

        APPLY_PATCH "system/framework/framework.jar" "dex/framework.jar/0001-Disable-dex.patch"
        APPLY_PATCH "system/priv-app/SecSettings/SecSettings.apk" "dex/SecSettings.apk/0001-Disable-dex.patch"
    fi
fi

# ------------------------------------------------------------------
# Final message
# ------------------------------------------------------------------

echo " Feature compatibility patching completed."