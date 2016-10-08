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
//  GeneratePasswordViewController.h
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/12/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYAPSCore.h"
#import "MiscellaneousUtilities.h"

static NSString *lcGeneratePasswordViewControllerTitle = @"generatepasswordviewcontroller-title";
static NSString *lcGeneratePasswordViewControllerLabelMasterSecret = @"generatepasswordviewcontroller-label-master-secret";
static NSString *lcGeneratePasswordViewControllerPlaceholderMasterSecret = @"generatepasswordviewcontroller-placeholder-master-secret";
static NSString *lcGeneratePasswordViewControllerLabelGeneratedPassword = @"generatepasswordviewcontroller-label-generated-password";
static NSString *lcGeneratePasswordViewControllerLabelEncryptQR = @"generatepasswordviewcontroller-label-encrypt-qr";
static NSString *lcGeneratePasswordViewControllerPlaceholderGeneratedPassword = @"generatepasswordviewcontroller-placeholder-generated-password";
static NSString *lcGeneratePasswordViewControllerButtonCopyToClipboard = @"generatepasswordviewcontroller-button-copy-to-clipboard";
static NSString *lcGeneratePasswordViewControllerCopyTitle = @"generatepasswordviewcontroller-copy-title";
static NSString *lcGeneratePasswordViewControllerCopySuccessMessage = @"generatepasswordviewcontroller-copy-success-message";
static NSString *lcGeneratePasswordViewControllerButtonFlipQR = @"generatepasswordviewcontroller-flip-qr";

static NSString *lcGeneratePasswordViewControllerButtonReveal1 = @"generatepasswordviewcontroller-reveal-title1";
static NSString *lcGeneratePasswordViewControllerButtonReveal2 = @"generatepasswordviewcontroller-reveal-title2";

@interface GeneratePasswordViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, strong) NSString *dynamicHint;
@property (nonatomic, strong) NSString *userCharset;
@property (nonatomic, strong) NSMutableArray <UserPreference *> *userPreferences;
@property (nonatomic) NSUInteger passwordLength;

@end
