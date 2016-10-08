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
//  FileListTableViewController.h
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/6/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FileManagementHelper.h"
#import "GlobalConstants.h"
#import "MiscellaneousUtilities.h"

#import "LabelledSwitchTableViewCell.h"
#import "PasswordListTableViewController.h"
#import "GeneratePasswordViewController.h"

static NSString *lcFileListTableViewControllerSettingsButton = @"filelisttableviewcontroller-settings-button";
static NSString *lcFileListTableViewControllerBackButton = @"filelisttableviewcontroller-back-button";
static NSString *lcFileListTableViewControllerLastUpdated = @"filelisttableviewcontroller-last-updated";
static NSString *lcFileListTableViewControllerTableHeaderSection0 = @"filelisttableviewcontroller-table-header-section0";
static NSString *lcFileListTableViewControllerTableFooterSection0 = @"filelisttableviewcontroller-table-footer-section0";
static NSString *lcFileListTableViewControllerTableFooterSection0Empty = @"filelisttableviewcontroller-table-footer-section0-empty";
static NSString *lcFileListTableViewControllerReadPasswordPrompt = @"filelisttableviewcontroller-read-password-prompt";
static NSString *lcFileListTableViewControllerReadPasswordPromptTitle = @"filelisttableviewcontroller-read-password-prompt-title";
static NSString *lcFileListTableViewControllerNewPasswordPrompt = @"filelisttableviewcontroller-new-password-prompt";
static NSString *lcFileListTableViewControllerNewPasswordPromptTitle = @"filelisttableviewcontroller-new-password-prompt-title";
static NSString *lcFileListTableViewControllerWritePasswordPrompt = @"filelisttableviewcontroller-write-password-prompt";
static NSString *lcFileListTableViewControllerWritePasswordPromptTitle = @"filelisttableviewcontroller-write-password-prompt-title";
static NSString *lcFileListTableViewControllerDeleteFilePrompt = @"filelisttableviewcontroller-delete-file-prompt";
static NSString *lcFileListTableViewControllerDeleteFilePromptTitle = @"filelisttableviewcontroller-delete-file-prompt-title";
static NSString *lcFileListTableViewControllerQRCodeButtonTitle = @"filelisttableviewcontroller-qrcode-button-title";

@interface FileListTableViewController : UITableViewController

- (BOOL) saveFileIfUnsaved;

@end
