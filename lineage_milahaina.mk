#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from the device configuration.
$(call inherit-product, device/xiaomi/milahaina/device.mk)

# Inherit from the Lineage configuration.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_BRAND := xiaomi
PRODUCT_DEVICE := milahaina
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := Project-MiLahaina
PRODUCT_NAME := lineage_milahaina

LINEAGE_VERSION_APPEND_TIME_OF_DAY := true
PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_DEVICE=milahaina \
    PRODUCT_NAME=milahaina \
    PRIVATE_BUILD_DESC="haydnin-user 11 RKQ1.201112.002 V12.0.3.0.RKKCNXM release-keys"

BUILD_FINGERPRINT := Xiaomi/haydn_in/haydnin:11/RKQ1.201112.002/V12.0.3.0.RKKCNXM:user/release-keys
