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
        --devices=* )
                DATA=$(echo $1 | cut -d'=' -f2-)
                # --devices=vili=<path>:lahaina=<path>....
                IFS=':' read -ra DEVICES <<< "$DATA"
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ] && [ -z $DEVICES ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
    vendor/etc/camera/pure*_parameter.xml)
        sed -i 's:=100:="100":g; s;=200;="200";g; s;=400;="400";g; s;=800;="800";g; s;=1600;="1600";g; s;=3200;="3200";g; s;=6400;="6400";g; s;Id=0;Id="0";g; s:Id=1:Id="1":g' "${2}"
    ;;
    odm/etc/*/camera/pure*_parameter.xml)
        sed -i 's:=100:="100":g; s;=200;="200";g; s;=400;="400";g; s;=800;="800";g; s;=1600;="1600";g; s;=3200;="3200";g; s;=6400;="6400";g; s;Id=0;Id="0";g; s:Id=1:Id="1":g' "${2}"
    ;;
    odm/etc/vili/camera/vili_motiontuning.xml)
        sed -i 's:xml=version:xml version:g' "${2}"
    ;;
    # Remove dependency on android.hidl.base@1.0.
    vendor/lib64/android.hardware.secure_element@1.0-impl.so )
        "${PATCHELF}" --remove-needed "android.hidl.base@1.0.so" "${2}"
    ;;
    odm/haydn/lib64/hw/camera.xiaomi.so)
        hexdump -ve '1/1 "%.2X"' "${2}" | sed "s/52070094/1F2003D5/g" | xxd -r -p > "${TMPDIR}/${1##*/}"
        mv "${TMPDIR}/${1##*/}" "${2}"
    ;;
    odm/vili/lib64/hw/camera.xiaomi.so)
        hexdump -ve '1/1 "%.2X"' "${2}" | sed "s/524D070094/521F2003D5/g" | xxd -r -p > "${TMPDIR}/${1##*/}"
        mv "${TMPDIR}/${1##*/}" "${2}"
    ;;
    esac
}

# Initialize the helper.
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"
if [ ! -z $DEVICES ]; then
    for i in ${DEVICES[@]}; do
        DEVICE=-$(echo ${i} | cut -d'=' -f1)
        if [ "$DEVICE" == "-common" ]; then
            DEVICE=""
        fi
        SRC=$(echo ${i} | cut -d'=' -f2)
        PROP_FILE="proprietary-files"${DEVICE}".txt"
        echo "Extracting $DEVICE from $SRC using $PROP_FILE"
        extract "${MY_DIR}/${PROP_FILE}" "${SRC}" "${KANG}" --section "${SECTION}"
    done
else
    extract "${MY_DIR}/${PROP_FILE}" "${SRC}" "${KANG}" --section "${SECTION}"
fi

"${MY_DIR}/setup-makefiles.sh" "${PROP_FILE}"
