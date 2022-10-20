#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

include vendor/qcom/opensource/core-utils/build/utils.mk

# Inherit from the device configuration.
$(call inherit-product, device/xiaomi/milahaina/device.mk)

PRODUCT_BRAND := xiaomi
PRODUCT_DEVICE := milahaina
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := milahaina for xiaomi 888
PRODUCT_NAME := milahaina

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
LINEAGE_VERSION_APPEND_TIME_OF_DAY := true
WITH_GMS := true
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_DEVICE=milahaina \
    PRODUCT_NAME=milahaina

