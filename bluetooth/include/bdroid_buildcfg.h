/*
 *  Copyright (c) 2013, The Linux Foundation. All rights reserved.
 *  Not a Contribution.
 *
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef _BDROID_BUILDCFG_H
#define _BDROID_BUILDCFG_H
#include <cutils/properties.h>
#include <string.h>

inline const char* BtmGetDefaultName()
{
	char sku[PROPERTY_VALUE_MAX];
	property_get("ro.boot.product.hardware.sku", sku, "");

        if (!strcmp("haydn", sku)) {
		return "Mi 11i Global";
        } else if (!strcmp("haydn_in", sku)) {
                return "Mi 11X Pro";
        } else if (!strcmp("haydnpro", sku)) {
                return "Redmi K40 Pro+";
        } else if (!strcmp("mars", sku)) {
		return "Mi 11 Pro";
        } else if (!strcmp("star", sku)) {
                return "Mi 11 Ultra";
        } else if (!strcmp("viliin", sku)) {
                return "Xiaomi 11T Pro";
        } else if (!strcmp("viligl", sku)) {
                return "Xiaomi 11T Pro";
        } else if (!strcmp("vilijp", sku)) {
                return "Xiaomi 11T Pro";
        } else {
		return "MiLahaina";
	}
}

#define BTM_DEF_LOCAL_NAME BtmGetDefaultName()
// Disables read remote device feature
#define MAX_ACL_CONNECTIONS   16
#define MAX_L2CAP_CHANNELS    32
#define BLE_VND_INCLUDED   TRUE
#define GATT_MAX_PHY_CHANNEL  10
// skips conn update at conn completion
#define BT_CLEAN_TURN_ON_DISABLED 1

#define AVDT_NUM_SEPS 35
#endif
