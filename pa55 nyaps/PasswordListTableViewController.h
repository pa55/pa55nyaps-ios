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
//  PasswordListTableViewController.h
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/6/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasswordDatabase.h"
#import "PasswordDatabaseEntry.h"
#import "UserPreference.h"
#import "AESCryptosystem.h"
#import "DecoratedPasswordEntryTableViewCell.h"
#import "GlobalConstants.h"

static NSString *lcPasswordListTableViewControllerBackButton = @"passwordlisttableviewcontroller-back-button";
static NSString *lcPasswordListTableViewControllerTableHeaderSection0 = @"passwordlisttableviewcontroller-table-header-section0";
static NSString *lcPasswordListTableViewControllerTableFooterSection0 = @"passwordlisttableviewcontroller-table-footer-section0";
static NSString *lcPasswordListTableViewControllerTableFooterSection0Empty = @"passwordlisttableviewcontroller-table-footer-section0-empty";
static NSString *lcPasswordListTableViewControllerDeletEntryPrompt = @"passwordlisttableviewcontroller-delete-entry-prompt";
static NSString *lcPasswordListTableViewControllerDeletEntryPromptTitle = @"passwordlisttableviewcontroller-delete-entry-prompt-title";

@interface PasswordListTableViewController : UITableViewController<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSString *passwordDatabaseFile;
@property (nonatomic, strong) PasswordDatabase *passwordDatabase;
@property (nonatomic, strong) NSString *databasePassword;

@property (nonatomic) BOOL shouldSaveSilently;

@end
