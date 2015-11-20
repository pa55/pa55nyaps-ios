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
//  PasswordEntryTableViewController.h
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/11/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasswordDatabaseEntry.h"
#import "PA55Encoder.h"
#import "LabelledSwitchTableViewCell.h"
#import "LabelledStepperTableViewCell.h"
#import "LabelledTextTableViewCell.h"
#import "PasswordListTableViewController.h"
#import "GeneratePasswordViewController.h"

static NSString *lcPasswordEntryTableViewControllerBackButton = @"passwordentrytableviewcontroller-back-button";
static NSString *lcPasswordEntryTableViewControllerCellLabelId = @"passwordentrytableviewcontroller-cell-label-id";
static NSString *lcPasswordEntryTableViewControllerCellLabelLength = @"passwordentrytableviewcontroller-cell-label-length";
static NSString *lcPasswordEntryTableViewControllerCellLabelIssue = @"passwordentrytableviewcontroller-cell-label-issue";
static NSString *lcPasswordEntryTableViewControllerCellLabelNotes = @"passwordentrytableviewcontroller-cell-label-notes";
static NSString *lcPasswordEntryTableViewControllerCellLabelBrackets = @"passwordentrytableviewcontroller-cell-label-brackets";
static NSString *lcPasswordEntryTableViewControllerCellLabelDigits = @"passwordentrytableviewcontroller-cell-label-digits";
static NSString *lcPasswordEntryTableViewControllerCellLabelLowercase = @"passwordentrytableviewcontroller-cell-label-lowercase";
static NSString *lcPasswordEntryTableViewControllerCellLabelSpecial = @"passwordentrytableviewcontroller-cell-label-special";
static NSString *lcPasswordEntryTableViewControllerCellLabelUppercase = @"passwordentrytableviewcontroller-cell-label-uppercase";
static NSString *lcPasswordEntryTableViewControllerCellLabelUserDefined = @"passwordentrytableviewcontroller-cell-label-user-defined";
static NSString *lcPasswordEntryTableViewControllerButtonGenPwd = @"passwordentrytableviewcontroller-button-genpwd";
static NSString *lcPasswordEntryTableViewControllerTableHeaderSection0 = @"passwordentrytableviewcontroller-table-header-section0";
static NSString *lcPasswordEntryTableViewControllerTableFooterSection0 = @"passwordentrytableviewcontroller-table-footer-section0";
static NSString *lcPasswordEntryTableViewControllerTableHeaderSection2 = @"passwordentrytableviewcontroller-table-header-section2";
static NSString *lcPasswordEntryTableViewControllerTableFooterSection2 = @"passwordentrytableviewcontroller-table-footer-section2";
static NSString *lcPasswordEntryTableViewControllerSegueExtendedNotesVCTitle = @"passwordentrytableviewcontroller-segue-extended-notesvc-title";

static NSString *lcPasswordEntryTableViewControllerTableHeaderSection1 = @"passwordentrytableviewcontroller-table-header-section1";
static NSString *lcPasswordEntryTableViewControllerTableFooterSection1 = @"passwordentrytableviewcontroller-table-footer-section1";
static NSString *lcPasswordEntryTableViewControllerCellLabelServiceName = @"passwordentrytableviewcontroller-cell-label-service-name";
static NSString *lcPasswordEntryTableViewControllerCellLabelServiceLink = @"passwordentrytableviewcontroller-cell-label-service-link";
static NSString *lcPasswordEntryTableViewControllerCellLabelUserId = @"passwordentrytableviewcontroller-cell-label-user-id";
static NSString *lcPasswordEntryTableViewControllerCellLabelAdditionalInfo = @"passwordentrytableviewcontroller-cell-label-additional-info";

@interface PasswordEntryTableViewController : UITableViewController<UITextFieldDelegate>

@property (nonatomic, strong) PasswordDatabaseEntry *databaseEntry;
@property (nonatomic, weak) PasswordDatabase *databaseReference;

@property (nonatomic, strong, readonly) NSString *originalTag;

- (void) updateModelWithUI;

@end
