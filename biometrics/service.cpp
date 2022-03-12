/*
 * Copyright (C) 2017 The Android Open Source Project
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

#include "BiometricsFingerprint.h"
#include <vendor/xiaomi/hardware/fingerprintextension/1.0/IXiaomiFingerprint.h>

// libhwbinder:
using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;

// Generated HIDL files
using android::hardware::biometrics::fingerprint::V2_3::IBiometricsFingerprint;
using android::hardware::biometrics::fingerprint::V2_3::implementation::BiometricsFingerprint;
using vendor::xiaomi::hardware::fingerprintextension::V1_0::IXiaomiFingerprint;

int main() {
    android::sp<IBiometricsFingerprint> service = BiometricsFingerprint::getInstance();
    android::sp<IXiaomiFingerprint> xfe = BiometricsFingerprint::getXiaomiInstance();

    if (service == nullptr) {
        ALOGE("Instance of BiometricsFingerprint is null");
        return 1;
    }

    configureRpcThreadpool(1, true /*callerWillJoin*/);

    android::status_t status = service->registerAsService();
    if (status != android::OK) {
        ALOGE("Cannot register BiometricsFingerprint service");
        return 1;
    }

    if (xfe != nullptr) {
        if (::android::OK != xfe->registerAsService()) {
            return 1;
        }
    } else {
        ALOGE("Can't create instance of XiaomiFingerprint, nullptr");
    }

    joinRpcThreadpool();

    return 0;  // should never get here
}
