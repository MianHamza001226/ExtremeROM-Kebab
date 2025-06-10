#
# Copyright (C) 2024 BlackMesa123
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Device configuration file for Galaxy M35 5G (Exynos 1380)
TARGET_NAME="Galaxy M35 5G (Exynos 1380)"
TARGET_CODENAME="m35x"
TARGET_ASSERT_MODEL=("SM-M356B")
TARGET_PLATFORM="exynos1380"
TARGET_FIRMWARE="SM-M356B/EUX/353154437125113"
TARGET_EXTRA_FIRMWARES=("")
TARGET_API_LEVEL=35 
TARGET_PRODUCT_FIRST_API_LEVEL=34
TARGET_VNDK_VERSION=34
TARGET_SINGLE_SYSTEM_IMAGE="essi"
TARGET_OS_FILE_SYSTEM="erofs"
TARGET_SUPER_PARTITION_SIZE=12582912000
TARGET_SUPER_GROUP_NAME="samsung_dynamic_partitions"
TARGET_SUPER_GROUP_SIZE=12578717696
TARGET_HAS_SYSTEM_EXT=true
TARGET_INSTALL_METHOD=zip
TARGET_BOOT_DEVICE_PATH="/dev/block/by-name"

# SEC Product Feature
TARGET_AUTO_BRIGHTNESS_TYPE="5"
TARGET_DVFS_CONFIG_NAME="dvfs_policy_exynos1380"
TARGET_NFC_CHIP_VENDOR="NXP"
TARGET_FP_SENSOR_CONFIG="side_fingerprint"
TARGET_HAS_MASS_CAMERA_APP=false
TARGET_HAS_QHD_DISPLAY=false
TARGET_HFR_MODE="3"
TARGET_HFR_SUPPORTED_REFRESH_RATE="60,90,120"
TARGET_HFR_DEFAULT_REFRESH_RATE="120"
TARGET_DISPLAY_CUTOUT_TYPE="none"
TARGET_IS_ESIM_SUPPORTED=false
TARGET_HAS_HW_MDNIE=false
TARGET_MDNIE_SUPPORTED_MODES=""
TARGET_MDNIE_WEAKNESS_SOLUTION_FUNCTION="0"
TARGET_SUPPORT_WIFI_7=false
TARGET_SUPPORT_HOTSPOT_DUALAP=true
TARGET_SUPPORT_HOTSPOT_WPA3=true
TARGET_SUPPORT_HOTSPOT_6GHZ=false
TARGET_SUPPORT_HOTSPOT_WIFI_6=true
TARGET_SUPPORT_HOTSPOT_ENHANCED_OPEN=true
TARGET_AUDIO_SUPPORT_ACH_RINGTONE=false
TARGET_AUDIO_SUPPORT_VIRTUAL_VIBRATION=false