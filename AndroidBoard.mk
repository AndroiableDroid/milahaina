LOCAL_PATH := $(call my-dir)

#----------------------------------------------------------------------
# Host compiler configs
#----------------------------------------------------------------------
SOURCE_ROOT := $(shell pwd)
TARGET_HOST_COMPILER_PREFIX_OVERRIDE := prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.17-4.8/bin/x86_64-linux-
TARGET_HOST_CC_OVERRIDE := $(TARGET_HOST_COMPILER_PREFIX_OVERRIDE)gcc
TARGET_HOST_CXX_OVERRIDE := $(TARGET_HOST_COMPILER_PREFIX_OVERRIDE)g++
TARGET_HOST_AR_OVERRIDE := $(TARGET_HOST_COMPILER_PREFIX_OVERRIDE)ar
TARGET_HOST_LD_OVERRIDE := $(TARGET_HOST_COMPILER_PREFIX_OVERRIDE)ld

#----------------------------------------------------------------------
# Compile (L)ittle (K)ernel bootloader and the nandwrite utility
#----------------------------------------------------------------------
ifneq ($(strip $(TARGET_NO_BOOTLOADER)),true)

# Compile
include bootable/bootloader/edk2/AndroidBoot.mk

$(INSTALLED_BOOTLOADER_MODULE): $(TARGET_EMMC_BOOTLOADER) | $(ACP)
#   $(transform-prebuilt-to-target)
$(BUILT_TARGET_FILES_PACKAGE): $(INSTALLED_BOOTLOADER_MODULE)

droidcore: $(INSTALLED_BOOTLOADER_MODULE)
endif

#----------------------------------------------------------------------
# Compile Linux Kernel
#----------------------------------------------------------------------
include device/qcom/kernelscripts/kernel_definitions.mk

#----------------------------------------------------------------------
# Radio image
#----------------------------------------------------------------------
ifeq ($(ADD_RADIO_FILES), true)
radio_dir := $(LOCAL_PATH)/radio
RADIO_FILES := $(shell cd $(radio_dir) ; ls)
$(foreach f, $(RADIO_FILES), \
    $(call add-radio-file,radio/$(f)))
endif

#----------------------------------------------------------------------
# Configs common to AndroidBoard.mk for all targets
#----------------------------------------------------------------------
include vendor/qcom/opensource/core-utils/build/AndroidBoardCommon.mk

#----------------------------------------------------------------------
# Generate device tree overlay image (dtbo.img)
#----------------------------------------------------------------------
ifneq ($(strip $(TARGET_NO_KERNEL)),true)
$(info "dfdfsF")
ifeq ($(strip $(BOARD_KERNEL_SEPARATED_DTBO)),true)

MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg$(HOST_EXECUTABLE_SUFFIX)

# Most specific paths must come first in possible_dtbo_dirs
possible_dtbo_dirs = $(KERNEL_OUT)/arch/$(TARGET_KERNEL_ARCH)/boot/dts $(KERNEL_OUT)/arch/arm/boot/dts
$(shell mkdir -p $(possible_dtbo_dirs))
dtbo_dir = $(firstword $(wildcard $(possible_dtbo_dirs)))
dtbo_objs = $(shell find $(dtbo_dir) -name \*.dtbo)

define build-dtboimage-target
    $(call pretty,"Target dtbo image: $(BOARD_PREBUILT_DTBOIMAGE)")
    $(hide) $(MKDTIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) $(dtbo_objs)
    $(hide) chmod a+r $@
endef

# Definition of BOARD_PREBUILT_DTBOIMAGE is in AndroidBoardCommon.mk
# so as to ensure it is defined well in time to set the dependencies on
# BOARD_PREBUILT_DTBOIMAGE
$(BOARD_PREBUILT_DTBOIMAGE): $(MKDTIMG) $(INSTALLED_KERNEL_TARGET)
	$(build-dtboimage-target)

endif
endif

#----------------------------------------------------------------------
# wlan specific
#----------------------------------------------------------------------
ifeq ($(strip $(BOARD_HAS_QCOM_WLAN)),true)
include device/qcom/wlan/lahaina/AndroidBoardWlan.mk
endif
