DELETE_FROM_WORK_DIR "system" "system/apex/com.android.btservices.apex"
DELETE_FROM_WORK_DIR "system" "system/lib64/libbluetooth_jni.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libaudiopolicy.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libaudiopolicymanagerdefault.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libaudiopolicyenginedefault.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libaudiopolicycomponents.so"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/apex/com.android.btservices.apex" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libaudiopolicy.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libaudiopolicymanagerdefault.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libaudiopolicyenginedefault.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libaudiopolicycomponents.so" 0 0 644 "u:object_r:system_lib_file:s0"


