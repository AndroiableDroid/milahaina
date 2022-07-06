#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=milahaina
VENDOR=xiaomi

# Load extract utilities and do some sanity checks.
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction.
CLEAN_VENDOR=true

KANG=
SECTION=
PROP_FILE="proprietary-files.txt"
while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -c | --clean )
                CLEAN_VENDOR=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        --lahaina )
		PROP_FILE="proprietary-files-lahaina.txt"
                cat ${MY_DIR}/${PROP_FILE} > ${MY_DIR}/.tmp.prop.txt
		PROP_FILE="proprietary-files-qssi.txt"
                cat ${MY_DIR}/${PROP_FILE} >> ${MY_DIR}/.tmp.prop.txt
                PROP_FILE=".tmp.prop.txt"
                CLEAN_VENDOR=false
                ;;
        --vili )
		PROP_FILE="proprietary-files-vili.txt"
                CLEAN_VENDOR=false
                ;;
        --haydn )
		PROP_FILE="proprietary-files-haydn.txt"
                CLEAN_VENDOR=false
                ;;
        --star )
		PROP_FILE="proprietary-files-star.txt"
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
    vendor/etc/camera/pure*_parameter.xml)
        sed -i 's:=100:="100":g; s;=200;="200";g; s;=400;="400";g; s;=800;="800";g; s;=1600;="1600";g; s;=3200;="3200";g; s;=6400;="6400";g; s;Id=0;Id="0";g; s:Id=1:Id="1":g' "${2}"
    ;;
    vendor/etc/camera/vili_motiontuning.xml)
        sed -i 's:xml=version:xml version:g' "${2}"
    ;;
    # Remove dependency on android.hidl.base@1.0.
    vendor/lib64/android.hardware.secure_element@1.0-impl.so )
        "${PATCHELF}" --remove-needed "android.hidl.base@1.0.so" "${2}"
    ;;
    esac
}

# Initialize the helper.
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/${PROP_FILE}" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh" "${PROP_FILE}"
