/*
 
 PA55 NYAPS iOS
 
 Copyright 2015 Anirban Basu
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */


//
//  QRCodeViewController.h
//  pa55v2
//
//  Created by Anirban Basu on 10/5/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

static NSString *lcQRCodeViewControllerTitle = @"qrcodeviewcontroller-title";
static NSString *lcQRCodeViewControllerSwitchCameraFront = @"qrcodeviewcontroller-switch-camera-front";
static NSString *lcQRCodeViewControllerSwitchCameraBack = @"qrcodeviewcontroller-switch-camera-back";
static NSString *lcQRCodeViewControllerSuccessfulRead = @"qrcodeviewcontroller-successful-read";
static NSString *lcQRCodeViewControllerEncryptedQRReadError = @"qrcodeviewcontroller-encryptedqr-read-error";
static NSString *lcQRCodeViewControllerEnterMasterSecretDialogTitle = @"qrcodeviewcontroller-enter-master-secret-dialog-title";
static NSString *lcQRCodeViewControllerEnterMasterSecretDialogMessage = @"qrcodeviewcontroller-enter-master-secret-dialog-message";
static NSString *lcQRCodeViewControllerAVWarnTitle = @"qrcodeviewcontroller-avwarn-title";
static NSString *lcQRCodeViewControllerAVWarnMessage = @"qrcodeviewcontroller-avwarn-message";

@interface QRCodeViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong, readonly) NSString *value;

@end
