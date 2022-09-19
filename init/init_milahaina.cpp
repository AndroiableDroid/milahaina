/*
   Copyright (c) 2015, The Linux Foundation. All rights reserved.
   Copyright (C) 2016 The CyanogenMod Project.
   Copyright (C) 2019-2020 The LineageOS Project.
   Copyright (C) 2021 The Android Open Source Project.
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of The Linux Foundation nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
   THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
   ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
   BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
   IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <cstdlib>
#include <string.h>

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>
#include <android-base/properties.h>

#include "property_service.h"
#include "vendor_init.h"
#include "util.h"

using android::base::GetProperty;
using std::string;

#define FIND_AND_REMOVE(s, delimiter, variable_name) \
    std::string variable_name = s.substr(0, s.find(delimiter)); \
    s.erase(0, s.find(delimiter) + delimiter.length());

#define APPEND_STRING(s, to_append) \
    s.append(" "); \
    s.append(to_append);

string fingerprint = GetProperty("ro.vendor.build.fingerprint", "");

string fingerprint_to_description(string fingerprint) {
    string delimiter = "/";
    string delimiter2 = "/";
    string build_fingerprint_copy = fingerprint;

    FIND_AND_REMOVE(build_fingerprint_copy, delimiter, brand)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter, product)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter2, device)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter, platform_version)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter, build_id)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter2, build_number)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter, build_variant)
    std::string build_version_tags = build_fingerprint_copy;

    std::string description = product + "-" + build_variant;
    APPEND_STRING(description, platform_version)
    APPEND_STRING(description, build_id)
    APPEND_STRING(description, build_number)
    APPEND_STRING(description, build_version_tags)

    return description;
}

void property_override(char const prop[], char const value[])
{
    auto pi = (prop_info*) __system_property_find(prop);

    if (pi != nullptr)
        __system_property_update(pi, value, strlen(value));
    else
        __system_property_add(prop, strlen(prop), value, strlen(value));
}

void set_ro_build_prop(const string &source, const string &prop,
                       const string &value, bool product = true) {
    string prop_name;

    if (product)
        prop_name = "ro.product." + source + prop;
    else
        prop_name = "ro." + source + "build." + prop;

    property_override(prop_name.c_str(), value.c_str());
}

void set_device_props(const string brand, const string device, const string model, const string name, const string marketname) {
    // list of partitions to override props
    string source_partitions[] = { "", "bootimage.", "odm.", "product.",
                                   "system.", "system_ext.", "vendor.",
                                    "vendor_dlkm." };

    for (const string &source : source_partitions) {
        set_ro_build_prop(source, "brand", brand);
        set_ro_build_prop(source, "device", device);
        set_ro_build_prop(source, "model", model);
        set_ro_build_prop(source, "name", name);
        set_ro_build_prop(source, "marketname", marketname);
    }
}

void vili_vendor_properties()
{
    // Detect device and configure properties
    string region = GetProperty("ro.boot.hwc", "");

    property_override("ro.boot.milahaina_version", "vili");
    property_override("ro.odm.milahaina.nfc", "true");

    if (region == "IN") { // India
        set_device_props("Xiaomi", "viliin", "2107113SI", "vili_in", "Xiaomi 11T Pro");
    } else if (region == "JP") { // Japan
        set_device_props("Xiaomi", "vili", "2107113SR", "vili", "Xiaomi 11T Pro");
    } else { // Global
        set_device_props("Xiaomi", "viligl", "2107113SG", "vili_global", "Xiaomi 11T Pro");
    }
}

void haydn_vendor_properties()
{
    // Detect device and configure properties
    string region = GetProperty("ro.boot.hwc", "");

    property_override("ro.boot.milahaina_version", "haydn");

    if (region == "IN") { // India
        set_device_props("Xiaomi", "haydnin", "M2012K11I", "haydn_in", "Mi 11X Pro");
    } else if (region == "CN") { // China
        set_device_props("Redmi", "haydnpro", "M2012K11C", "haydnpro", "Redmi K40 Pro+");
        property_override("ro.odm.milahaina.nfc", "true");
    } else { // Global
        set_device_props("Xiaomi", "haydn", "M2012K11G", "haydn_global", "Mi 11i Globa");
        property_override("ro.odm.milahaina.nfc", "true");
    }
}

void set_build_fingerprint()
{
    property_override("ro.build.fingerprint", GetProperty("ro.vendor.build.fingerprint", "").c_str());
    property_override("ro.build.description", fingerprint_to_description(GetProperty("ro.vendor.build.fingerprint", "")).c_str());
}

void vendor_load_properties()
{
    string device = GetProperty("ro.boot.product.hardware.sku", "");
    if (!android::init::IsRecoveryMode()) {    // DO-NOT Update props in recovery
        if (device == "vili") {
            vili_vendor_properties();
        } else if (device == "viliin") {
            vili_vendor_properties();
        } else if (device == "viligl") {
            vili_vendor_properties();
        } else if (device == "vilijp") {
            vili_vendor_properties();
        } else if (device == "haydn") {
            haydn_vendor_properties();
        } else if (device == "haydn_in") {
            haydn_vendor_properties();
        } else if (device == "haydnpro") {
            haydn_vendor_properties();
        } else if (device == "star") {
            set_device_props("Xiaomi", "star", "M2102K1G", "star", "Mi 11 Ultra");
            property_override("ro.odm.milahaina.nfc", "true");
            property_override("ro.boot.milahaina_version", "star");
        } else if (device == "mars") {
            set_device_props("Xiaomi", "mars", "M2102K1AC", "mars", "Mi 11 Pro");
            property_override("ro.odm.milahaina.nfc", "true");
            property_override("ro.boot.milahaina_version", "star");
        } else {
            set_device_props("Xiaomi", "milahaina", "milahaina", "milahaina", "milahaina for xiaomi 888");
        }
    }

    // Set Build fingerprint same as of vendor
    if (!android::init::IsRecoveryMode()) {    // DO-NOT Update props in recovery
        set_build_fingerprint();               // increamental OTA checks build fingerprint
    }
    // Set hardware revision
    property_override("ro.boot.hardware.revision", GetProperty("ro.boot.hwversion", "").c_str());
}

