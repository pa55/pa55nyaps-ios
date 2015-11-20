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
//  PasswordEntryTableViewController.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/11/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "PasswordEntryTableViewController.h"

@interface PasswordEntryTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *uitvPasswordSetting;

@property (nonatomic, weak) LabelledTextTableViewCell *idCell;
@property (nonatomic, weak) LabelledStepperTableViewCell *lengthCell;
@property (nonatomic, weak) LabelledStepperTableViewCell *issueNumberCell;

@property (nonatomic, weak) LabelledTextTableViewCell *serviceNameCell;
@property (nonatomic, weak) LabelledTextTableViewCell *serviceLinkCell;
@property (nonatomic, weak) LabelledTextTableViewCell *userIdCell;
@property (nonatomic, weak) LabelledTextTableViewCell *additionalInfoCell;

@property (nonatomic, weak) LabelledSwitchTableViewCell *charTypeBracketsCell;
@property (nonatomic, weak) LabelledSwitchTableViewCell *charTypeDigitsCell;
@property (nonatomic, weak) LabelledSwitchTableViewCell *charTypeLowercaseCell;
@property (nonatomic, weak) LabelledSwitchTableViewCell *charTypeSpecialCell;
@property (nonatomic, weak) LabelledSwitchTableViewCell *charTypeUppercaseCell;
@property (nonatomic, weak) LabelledTextTableViewCell *charTypeUserCell;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uibbiGeneratePassword;

//declare a property to store your current responder
@property (nonatomic, assign) id currentResponder;

@end

@implementation PasswordEntryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelledSwitchTableViewCell" bundle:nil] forCellReuseIdentifier:@"labelledSwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelledTextTableViewCell" bundle:nil] forCellReuseIdentifier:@"labelledTextCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LabelledStepperTableViewCell" bundle:nil] forCellReuseIdentifier:@"labelledStepperCell"];
    
    _originalTag = [NSString stringWithString:_databaseEntry.tag];
    
    self.navigationItem.backBarButtonItem.title = NSLocalizedString(lcPasswordEntryTableViewControllerBackButton, nil);
    _uibbiGeneratePassword.title = NSLocalizedString(lcPasswordEntryTableViewControllerButtonGenPwd, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3; //0 = ID, length, issue; 1 = notes; 2 = character classes
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 3;
    }
    else if (section == 1) {
        return 4;
    }
    else if (section == 2) {
        return user; //character_type_count; //the total allowed character types
    }
    else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if(indexPath.section == 0) {
        switch(indexPath.row) {
            case 0:
                //ID
                _idCell = [tableView dequeueReusableCellWithIdentifier:@"labelledTextCell" forIndexPath:indexPath];
                _idCell.cellTextField.placeholder = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelId, nil);
                _idCell.value = _databaseEntry.tag;
                if(_idCell.textFieldDelegate == nil) {
                    _idCell.textFieldDelegate = self;
                    _idCell.validationRegex = [NSRegularExpression regularExpressionWithPattern:@"^(?!\\s*$).+" options:0 error:NULL];
                    _idCell.navigationItemReference = self.navigationItem;
                }
                cell = _idCell;
                break;
            case 1:
                //Length
                _lengthCell = [tableView dequeueReusableCellWithIdentifier:@"labelledStepperCell" forIndexPath:indexPath];
                _lengthCell.cellLabel.text = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelLength, nil);
                _lengthCell.cellStepper.minimumValue = kPasswordLengthMinimum;
                _lengthCell.cellStepper.maximumValue = kPasswordLengthMaximum;
                _lengthCell.cellStepper.stepValue = kPasswordLengthStep;
                _lengthCell.floatingPointValue = NO;
                _lengthCell.value = _databaseEntry.length;
                cell = _lengthCell;
                break;
            case 2:
                //Issue number
                _issueNumberCell = [tableView dequeueReusableCellWithIdentifier:@"labelledStepperCell" forIndexPath:indexPath];
                _issueNumberCell.cellLabel.text = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelIssue, nil);
                _issueNumberCell.cellStepper.minimumValue = kIssueMinimum;
                _issueNumberCell.cellStepper.maximumValue = kIssueMaximum;
                _issueNumberCell.cellStepper.stepValue = kIssueStep;
                _issueNumberCell.floatingPointValue = NO;
                _issueNumberCell.value = _databaseEntry.issue;
                cell = _issueNumberCell;
                break;
            default:
                break;
        }
    }
    else if(indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                _serviceNameCell = [tableView dequeueReusableCellWithIdentifier:@"labelledTextCell" forIndexPath:indexPath];
                _serviceNameCell.cellTextField.placeholder = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelServiceName, nil);
                _serviceNameCell.value = _databaseEntry.notes.serviceName;
                _serviceNameCell.validationRegex = [NSRegularExpression regularExpressionWithPattern:@"^(?!\\s*$).+" options:0 error:NULL];
                _serviceNameCell.navigationItemReference = self.navigationItem;
                cell = _serviceNameCell;
                break;
            case 1:
                _serviceLinkCell = [tableView dequeueReusableCellWithIdentifier:@"labelledTextCell" forIndexPath:indexPath];
                _serviceLinkCell.cellTextField.placeholder = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelServiceLink, nil);
                _serviceLinkCell.validationRegex = [NSRegularExpression regularExpressionWithPattern:@"^$|^(https?|ftp|file)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]" options:0 error:NULL];
                _serviceLinkCell.navigationItemReference = self.navigationItem;
                _serviceLinkCell.value = _databaseEntry.notes.serviceLink;
                cell = _serviceLinkCell;
                break;
            case 2:
                _userIdCell = [tableView dequeueReusableCellWithIdentifier:@"labelledTextCell" forIndexPath:indexPath];
                _userIdCell.cellTextField.placeholder = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelUserId, nil);
                _userIdCell.value = _databaseEntry.notes.userID;
                cell = _userIdCell;
                break;
            case 3:
                _additionalInfoCell = [tableView dequeueReusableCellWithIdentifier:@"labelledTextCell" forIndexPath:indexPath];
                _additionalInfoCell.cellTextField.placeholder = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelAdditionalInfo, nil);
                _additionalInfoCell.value = _databaseEntry.notes.additionalInfo;
                cell = _additionalInfoCell;
                break;
            default:
                break;
        }
    }
    else if(indexPath.section == 2) {
        // Configure the cell...
        switch(indexPath.row) {
            case brackets:
                _charTypeBracketsCell = [tableView dequeueReusableCellWithIdentifier:@"labelledSwitchCell" forIndexPath:indexPath];
                _charTypeBracketsCell.cellLabel.text = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelBrackets, nil);
                cell = _charTypeBracketsCell;
                break;
            case digits:
                _charTypeDigitsCell = [tableView dequeueReusableCellWithIdentifier:@"labelledSwitchCell" forIndexPath:indexPath];
                _charTypeDigitsCell.cellLabel.text = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelDigits, nil);
                cell = _charTypeDigitsCell;
                break;
            case lowercase:
                _charTypeLowercaseCell = [tableView dequeueReusableCellWithIdentifier:@"labelledSwitchCell" forIndexPath:indexPath];
                _charTypeLowercaseCell.cellLabel.text = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelLowercase, nil);
                cell = _charTypeLowercaseCell;
                break;
            case special:
                _charTypeSpecialCell = [tableView dequeueReusableCellWithIdentifier:@"labelledSwitchCell" forIndexPath:indexPath];
                _charTypeSpecialCell.cellLabel.text = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelSpecial, nil);
                cell = _charTypeSpecialCell;
                break;
            case uppercase:
                _charTypeUppercaseCell = [tableView dequeueReusableCellWithIdentifier:@"labelledSwitchCell" forIndexPath:indexPath];
                _charTypeUppercaseCell.cellLabel.text = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelUppercase, nil);
                cell = _charTypeUppercaseCell;
                break;
                /*
            case user:
                _charTypeUserCell = [tableView dequeueReusableCellWithIdentifier:@"labelledTextCell" forIndexPath:indexPath];
                _charTypeUserCell.cellLabel.text = NSLocalizedString(lcPasswordEntryTableViewControllerCellLabelUserDefined, nil);
                _charTypeUserCell.value = _databaseEntry.userDefinedCharacters;
                cell = _charTypeUserCell;
                break;
                 */
            default:
                break;
        }
        [_databaseEntry.characterTypes enumerateObjectsUsingBlock:^(UserPreference * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            switch (obj.characterType) {
                case brackets:
                    _charTypeBracketsCell.on = obj.minimum > 0? YES : NO;
                    break;
                case digits:
                    _charTypeDigitsCell.on = obj.minimum > 0? YES : NO;
                    break;
                case lowercase:
                    _charTypeLowercaseCell.on = obj.minimum > 0? YES : NO;
                    break;
                case special:
                    _charTypeSpecialCell.on = obj.minimum > 0? YES : NO;
                    break;
                case uppercase:
                    _charTypeUppercaseCell.on = obj.minimum > 0? YES : NO;
                    break;
                default:
                    break;
            }
        }];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return NSLocalizedString(lcPasswordEntryTableViewControllerTableHeaderSection0, nil);
    }
    else if(section == 1) {
        return NSLocalizedString(lcPasswordEntryTableViewControllerTableHeaderSection1, nil);
    }
    else if(section == 2) {
        return NSLocalizedString(lcPasswordEntryTableViewControllerTableHeaderSection2, nil);
    }
    else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 0) {
        return NSLocalizedString(lcPasswordEntryTableViewControllerTableFooterSection0, nil);
    }
    else if(section == 1) {
        return NSLocalizedString(lcPasswordEntryTableViewControllerTableFooterSection1, nil);
    }
    else if(section == 2) {
        return NSLocalizedString(lcPasswordEntryTableViewControllerTableFooterSection2, nil);
    }
    else {
        return nil;
    }
}


- (void) updateModelWithUI {
    if(_idCell!=nil) {
        _databaseEntry.tag = _idCell.value;
    }
    if(_lengthCell!=nil) {
        _databaseEntry.length = _lengthCell.value;
    }
    if(_issueNumberCell!=nil) {
        _databaseEntry.issue = _issueNumberCell.value;
    }
    
    if(_serviceNameCell!=nil) {
        _databaseEntry.notes.serviceName = _serviceNameCell.value;
    }
    if(_serviceLinkCell!=nil) {
        _databaseEntry.notes.serviceLink = _serviceLinkCell.value;
    }
    if(_userIdCell!=nil) {
        _databaseEntry.notes.userID = _userIdCell.value;
    }
    if(_additionalInfoCell!=nil) {
        _databaseEntry.notes.additionalInfo = _additionalInfoCell.value;
    }
    /*
    if(_charTypeUserCell!=nil) {
        [_databaseEntry removeFirstOccurrenceOfCharacterType:user];
        _databaseEntry.userDefinedCharacters = _charTypeUserCell.value;
        [_databaseEntry.userDefinedCharacters length]>0 ? [_databaseEntry.characterTypes addObject:[[UserPreference alloc] initWithCharacterType:user minimum:1]] : nil;
    }
    */
    if(_charTypeBracketsCell!=nil) {
        [_databaseEntry removeFirstOccurrenceOfCharacterType:brackets];
        _charTypeBracketsCell.on == YES? [_databaseEntry.characterTypes addObject:[[UserPreference alloc] initWithCharacterType:brackets minimum:1]] : nil;
    }
    
    if(_charTypeDigitsCell!=nil) {
        [_databaseEntry removeFirstOccurrenceOfCharacterType:digits];
        _charTypeDigitsCell.on == YES? [_databaseEntry.characterTypes addObject:[[UserPreference alloc] initWithCharacterType:digits minimum:1]] : nil;
    }
    
    if(_charTypeLowercaseCell!=nil) {
        [_databaseEntry removeFirstOccurrenceOfCharacterType:lowercase];
        _charTypeLowercaseCell.on == YES? [_databaseEntry.characterTypes addObject:[[UserPreference alloc] initWithCharacterType:lowercase minimum:1]] : nil;
    }
    
    if(_charTypeSpecialCell!=nil) {
        [_databaseEntry removeFirstOccurrenceOfCharacterType:special];
        _charTypeSpecialCell.on == YES? [_databaseEntry.characterTypes addObject:[[UserPreference alloc] initWithCharacterType:special minimum:1]] : nil;
    }
    
    if(_charTypeUppercaseCell!=nil) {
        [_databaseEntry removeFirstOccurrenceOfCharacterType:uppercase];
        _charTypeUppercaseCell.on == YES? [_databaseEntry.characterTypes addObject:[[UserPreference alloc] initWithCharacterType:uppercase minimum:1]] : nil;
    }
    
}


- (void) setDatabaseEntry:(PasswordDatabaseEntry *)databaseEntry {
    _databaseEntry = databaseEntry;
    self.navigationItem.title = _databaseEntry.tag;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField == _idCell.cellTextField) {
        self.navigationItem.title = _idCell.value;
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}


#pragma mark - Navigation

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.currentResponder resignFirstResponder];
    
    UIViewController *vc = self.navigationController.topViewController;
    if ([vc isKindOfClass:[PasswordListTableViewController class]]) {
        [self performSegueWithIdentifier:segidUnwindToPasswordList sender:self];
    }
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"generatePassword"]) {
        [self updateModelWithUI];
        GeneratePasswordViewController *destinationVC = segue.destinationViewController;
        //do not pass any of the parameters as pointers, always copy.
        destinationVC.passwordLength = _databaseEntry.length;
        destinationVC.userPreferences = [[NSMutableArray alloc] initWithArray:_databaseEntry.characterTypes];
        destinationVC.dynamicHint = [NSString stringWithFormat:@"%@%ld",[_databaseEntry.notes description], (unsigned long)_databaseEntry.issue];
        destinationVC.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(lcGeneratePasswordViewControllerTitle, nil), _databaseEntry.tag];
        //destinationVC.userCharset = [NSString stringWithString:_databaseEntry.userDefinedCharacters];
    }
    else if([segue.identifier isEqualToString:segidUnwindToPasswordList]) {
        [self updateModelWithUI];
    }
}


@end
