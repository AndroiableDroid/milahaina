#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

BUILD_BROKEN_DUP_RULES := true
DEVICE_PATH := device/xiaomi/milahaina

include build/make/target/board/BoardConfigMainlineCommon.mk

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS := \
    boot \
    dtbo \
    odm \
    product \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot

# AVB
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA2048
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_VBMETA_SYSTEM := product system system_ext
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a76

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a76

# Audio
AUDIO_FEATURE_ENABLED_AHAL_EXT := false
AUDIO_FEATURE_ENABLED_DYNAMIC_LOG := false
AUDIO_FEATURE_ENABLED_SPKR_PROTECTION := false
AUDIO_FEATURE_ENABLED_SSR := false

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := lahaina

# DTB
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_BOOT_HEADER_VERSION := 3
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOT_HEADER_VERSION)

# DTBO
BOARD_KERNEL_SEPARATED_DTBO := true

# Display
include hardware/qcom-caf/sm8350/display/config/display-board.mk

TARGET_SCREEN_DENSITY := 440

# FSConfig
TARGET_FS_CONFIG_GEN := $(DEVICE_PATH)/config.fs

# HIDL
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := \
    $(DEVICE_PATH)/xiaomi_framework_matrix.xml \
    $(DEVICE_PATH)/device_framework_matrix.xml \
    vendor/lineage/config/device_framework_matrix.xml

DEVICE_MANIFEST_FILE := \
    $(DEVICE_PATH)/xiaomi_manifest.xml \
    $(DEVICE_PATH)/manifest.xml

DEVICE_MATRIX_FILE := \
    $(DEVICE_PATH)/compatibility_matrix.xml

ODM_MANIFEST_SKUS := haydnpro
ODM_MANIFEST_HAYDNPRO_FILES := $(DEVICE_PATH)/haydnpro_manifest.xml

# Kernel
BOARD_KERNEL_CMDLINE := \
    androidboot.console=ttyMSM0 \
    androidboot.hardware=qcom \
    androidboot.memcg=1 \
    androidboot.usbcontroller=a600000.dwc3 \
    cgroup.memory=nokmem,nosocket \
    console=ttyMSM0,115200n8 \
    ip6table_raw.raw_before_defrag=1 \
    iptable_raw.raw_before_defrag=1 \
    loop.max_part=7 \
    lpm_levels.sleep_disabled=1 \
    msm_rtb.filter=0x237 \
    pcie_ports=compat \
    service_locator.enable=1 \
    swiotlb=0 \
    loop.max_part=7

BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/modules.load))

TARGET_MODULE_ALIASES += wlan.ko:qca_cld3_wlan.ko

BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_RAMDISK_USE_LZ4 := true

BOARD_KERNEL_IMAGE_NAME := Image
TARGET_KERNEL_ADDITIONAL_FLAGS := \
    DTC_EXT=$(shell pwd)/prebuilts/misc/linux-x86/dtc/dtc \
    LLVM=1

TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_CONFIG := vendor/milahaina_defconfig
TARGET_KERNEL_SOURCE := kernel/xiaomi/sm8350

# Partitions
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := odm product system system_ext vendor
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 7512192768 # BOARD_SUPER_PARTITION_SIZE - 4MB
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_SUPER_PARTITION_SIZE := 7516192768

BOARD_BOOTIMAGE_PARTITION_SIZE := 0x6000000
BOARD_DTBOIMG_PARTITION_SIZE := 0x1800000
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 0x06000000

BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

TARGET_COPY_OUT_ODM := odm

# Platform
BOARD_USES_QCOM_HARDWARE := true
TARGET_BOARD_PLATFORM := lahaina

# Power
TARGET_TAP_TO_WAKE_NODE := "/sys/touchpanel/double_tap"

# RIL
ENABLE_VENDOR_RIL_SERVICE := true

# Recovery
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_USES_RECOVERY_AS_BOOT := true
BOOT_KERNEL_MODULES := $(strip $(shell cat $(DEVICE_PATH)/modules.load.recovery))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(BOOT_KERNEL_MODULES)
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/init/fstab.default
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 100
TARGET_USERIMAGES_USE_F2FS := true

# SELinux
include device/qcom/sepolicy_vndr/SEPolicy.mk

BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
PRODUCT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private

# WLAN
BOARD_HAS_QCOM_WLAN := true
BOARD_WLAN_DEVICE := qcwcn
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_DRIVER := $(BOARD_HOSTAPD_DRIVER)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := $(BOARD_HOSTAPD_PRIVATE_LIB)
HOSTAPD_VERSION := VER_0_8_X
WPA_SUPPLICANT_VERSION := $(HOSTAPD_VERSION)

CONFIG_ACS := true
CONFIG_IEEE80211AC := true
CONFIG_IEEE80211AX := true
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
