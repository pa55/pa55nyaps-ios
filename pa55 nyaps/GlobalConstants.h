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
//  GlobalConstants.h
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/14/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#ifndef GlobalConstants_h
#define GlobalConstants_h

static NSString *lcAppEmptyString = @"app-empty-string";
static NSString *lcAppTitle = @"app-title";
static NSString *lcAppTitleShort = @"app-title-short";
static NSString *lcAppDateTimeFormat = @"app-date-time-format";
static NSString *lcAppOkLabel = @"app-ok-label";
static NSString *lcAppCancelLabel = @"app-cancel-label";
static NSString *lcAppConfirmLabel = @"app-confirm-label";
static NSString *lcAppContinueLabel = @"app-continue-label";
static NSString *lcAppSettingsLabel = @"app-settings-label";
static NSString *lcAppYesLabel = @"app-yes-label";
static NSString *lcAppNoLabel = @"app-no-label";
static NSString *lcAppFileWriteErrorTitle = @"app-file-write-error-title";
static NSString *lcAppFileReadErrorTitle = @"app-file-read-error-title";
static NSString *lcAppInputErrorTitle = @"app-input-error-title";
static NSString *lcAppRegExErrorMessage = @"app-regex-error-message";
static NSString *lcAppAutoSaveTitle = @"app-auto-save-title";
static NSString *lcAppAutoSaveMessage = @"app-auto-save-message";
static NSString *lcAppPlaceholderPasswordLabel = @"app-placeholder-password-label";
static NSString *lcAppPlaceholderFilenameLabel = @"app-placeholder-filename-label";

static NSUInteger kPBKDF2Rounds = 25000;
static NSInteger kAutoSaveTimeoutInSeconds = 60;
static NSString *strPreferencesAutoSaveTimeout = @"preferences_AutoSaveTimeout";
static NSString *strPreferencesAppVersion = @"preferences_AppVersion";

static NSString *segidUnwindToFileList = @"unwindToFileList";
static NSString *segidUnwindToPasswordList = @"unwindToPasswordList";
static NSString *segidUnwindToPasswordEntry = @"unwindToPasswordEntry";

#endif /* GlobalConstants_h */
