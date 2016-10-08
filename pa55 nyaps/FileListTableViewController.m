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
//  FileListTableViewController.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/6/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "FileListTableViewController.h"

@interface FileListTableViewController()
@property (nonatomic, weak) FileManagementHelper *fmHelper;
@property (nonatomic, strong) NSMutableArray<NSString *> *documentList;
@property (nonatomic, strong) NSString *documentPath;
@property (nonatomic, strong) NSString *databasePassword;
@property (nonatomic, strong) NSString *databaseFile;
@property (nonatomic, strong) PasswordDatabase *passwordDatabase;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *uibbiQRCodePassword;
@end

@implementation FileListTableViewController {
    //NSMutableArray *_importedList;
    //NSString *_importedPath;
    UIAlertController *_inputPasswordDialog;
}
//Tie this up to some UI if relevant, but this is not a very nice idea.
- (IBAction)openSettingsPage:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)viewDidAppear:(BOOL)animated {
    /*
     // This notification is sent when the app resumes from the background
     // no need to register for this notification as the app delegate can post the UIFileListShouldRefreshNotification
     [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(fileListShouldRefresh:) name: UIApplicationWillEnterForegroundNotification object: nil];*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(fileListShouldRefresh:) name: UIFileListShouldRefreshNotification object: nil];
}

- (BOOL) saveFileIfUnsaved {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    if(_passwordDatabase!=nil) { //this happens after this function has been called once because it frees up the memory?
        NSString *errorMessage;
        BOOL result = [_fmHelper writeDb:_passwordDatabase toFile:_databaseFile withPassword:_databasePassword catchError:&errorMessage];
        if(result) {
            [self freeUpMemory];
            return YES;
        }
        if(errorMessage!=nil) {
            UIAlertController *warn = [UIAlertController
                                       alertControllerWithTitle:NSLocalizedString(lcAppFileWriteErrorTitle, nil)
                                       message:errorMessage
                                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppOkLabel, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            }];
            [warn addAction:okButton];
            [self.navigationController presentViewController:warn animated:YES completion:nil];
        }
    }
    return NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    //Remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(lcAppTitleShort, nil);
    
    _uibbiQRCodePassword.title = NSLocalizedString(lcFileListTableViewControllerQRCodeButtonTitle, nil);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(lcFileListTableViewControllerSettingsButton, nil) style:UIBarButtonItemStylePlain target:self action:@selector(launchSettingsApp)];
    
    //setup file manager
    _fmHelper = [FileManagementHelper defaultHelper];
    _documentList = [[NSMutableArray alloc] init];
    _documentPath = [_fmHelper documentsDirectory];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor grayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshFilesList)
                  forControlEvents:UIControlEventValueChanged];
    
    //refresh first time
    [self refreshFilesList];

}

- (void) launchSettingsApp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

//capture the event that application resumes, and refresh the table just in case
- (void) fileListShouldRefresh:(NSNotification *) notification {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [self refreshFilesList];
}

- (void) refreshFilesList {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    if(self.refreshControl) {
        [self.refreshControl beginRefreshing];
    }
    
    [_documentList removeAllObjects];
    [_documentList addObjectsFromArray:[_fmHelper contentsOfDirectoryAtPath:_documentPath excludeSubDirectories:YES]];
    
    [self.tableView reloadData];
    
    if(self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return [_documentList count];
    }
    /*
    else if(section==1) {
        return [_importedList count];
    }
    */
    else {
        return  0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileEntry" forIndexPath:indexPath];
    
    // Configure the cell...
    if(indexPath.section == 0) {
        NSString *filePath = [_documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [_documentList objectAtIndex:indexPath.row]]];
        NSError *error;
        NSDictionary *attributes = [_fmHelper.fileManager attributesOfItemAtPath:filePath error:&error];
        if(error==nil) {
            cell.textLabel.text = [_documentList objectAtIndex:indexPath.row];
            //cell.cellLabel.text = [_documentList objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(lcFileListTableViewControllerLastUpdated, nil), [[MiscellaneousUtilities defaultInstance] appFormattedDateStringFrom:[attributes valueForKey:NSFileModificationDate]]];
            //draw the icon
            //cell.imageView.image = [UIImage imageNamed:@"FileListIcon"];
        }
    }
    /*
    else if(indexPath.section == 1) {
        NSString *filePath = [_importedPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [_importedList objectAtIndex:indexPath.row]]];
        NSError *error;
        NSDictionary *attributes = [_fmHelper.fileManager attributesOfItemAtPath:filePath error:&error];
        if(error==nil) {
            cell.textLabel.text = [_importedList objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [[attributes valueForKey:NSFileModificationDate] description];
        }
    }
    */
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //fire it correctly
    if(indexPath.section == 0 && !tableView.isEditing) {
        [self showPasswordInputDialogForReadingFile:[[_fmHelper documentsDirectory] stringByAppendingPathComponent:[_documentList objectAtIndex:indexPath.row]]];
    }
    if(tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return NSLocalizedString(lcFileListTableViewControllerTableHeaderSection0, nil);
    }
    /*
    else if(section == 1) {
        return @"Imported files";
    }
     */
    else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 0) {
        if([_documentList count] == 0) {
            return NSLocalizedString(lcFileListTableViewControllerTableFooterSection0Empty, nil);
        }
        else {
            return NSLocalizedString(lcFileListTableViewControllerTableFooterSection0, nil);
        }
    }
    /*
    else if(section == 1) {
        return @"These files have been imported from other apps.";
    }
     */
    else {
        return nil;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if(indexPath.section == 0) {
            [self removeWithConfirmationFileIdentifiedByIndexPath:indexPath inTableView:tableView];
        }
        /*
        else if(indexPath.section == 1) {
            error = [_fmHelper deleteFile:[_importedList objectAtIndex:indexPath.row] atPath:_importedPath];
            if(error==nil) {
                [_importedList removeObjectAtIndex:indexPath.row];
            }
        }
         */
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [self createNewEmptyDatabase:nil];
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation


- (IBAction)unwindToFileList:(UIStoryboardSegue*)sender {
    // Pull any data from the view controller which initiated the unwind segue.
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    if([sender.sourceViewController isKindOfClass:[PasswordListTableViewController class]]) {
        PasswordListTableViewController *sourceVC = sender.sourceViewController;
        if(sourceVC.passwordDatabase!=nil) {
            if(sourceVC.shouldSaveSilently) {
                //save silently
                [self saveFileIfUnsaved];
                [self refreshFilesList];
            }
            else {
                //or save with user confirmation
                [self showPasswordInputDialogForWritingDatabase:_passwordDatabase toFile:_databaseFile withCurrentPassword:_databasePassword];
            }
        }
    }
}



//This gets called before prepareForSegue
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return TRUE;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showPasswordFile"]) {
        self.navigationItem.backBarButtonItem.title = NSLocalizedString(lcFileListTableViewControllerBackButton, nil);
        NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
        //decrypt the file
        PasswordListTableViewController *destinationVC = (PasswordListTableViewController *)segue.destinationViewController;
        NSString *fileName;
        if(selected!=nil) {
            if(selected.section == 0) {
                fileName = [_documentList objectAtIndex:selected.row];
            }
        }
        else {
            fileName = [NSString stringWithFormat:@"db%ld.pa55",(long)[[NSDate date] timeIntervalSince1970]];
        }
        _databaseFile = [[_fmHelper documentsDirectory] stringByAppendingPathComponent:fileName];
        destinationVC.passwordDatabaseFile = _databaseFile;
        destinationVC.databasePassword = _databasePassword;
        destinationVC.passwordDatabase = _passwordDatabase;
        destinationVC.navigationItem.title = fileName;
    }
    else if ([segue.identifier isEqualToString:@"showQRCodeScanner"]) {
        self.navigationItem.backBarButtonItem.title = NSLocalizedString(lcAppEmptyString, nil);
    }
}

#pragma mark - User Interaction

- (void) removeWithConfirmationFileIdentifiedByIndexPath:(NSIndexPath *) fileIndexPath inTableView:(UITableView *) tableView {
    NSString *message = [NSString stringWithFormat:NSLocalizedString(lcFileListTableViewControllerDeleteFilePrompt, nil), [_documentList objectAtIndex:fileIndexPath.row]];
    
    UIAlertController *deleteFileDialog = [UIAlertController
                            alertControllerWithTitle:NSLocalizedString(lcFileListTableViewControllerDeleteFilePromptTitle, nil)
                            message:message
                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppYesLabel, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSError *error;
        error = [_fmHelper deleteFile:[_documentList objectAtIndex:fileIndexPath.row] inDirectory:_documentPath];
        if(error==nil) {
            [_documentList removeObjectAtIndex:fileIndexPath.row];
            [tableView deleteRowsAtIndexPaths:@[fileIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        if(error!=nil) {
            UIAlertController *warn = [UIAlertController
                                       alertControllerWithTitle:NSLocalizedString(lcAppFileWriteErrorTitle, nil)
                                       message:[error localizedDescription]
                                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppOkLabel, nil) style:UIAlertActionStyleCancel handler:nil];
            [warn addAction:okButton];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.navigationController presentViewController:warn animated:YES completion:nil];
            });
        }
        [self refreshFilesList];
        [self freeUpMemory];
        [tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
//        [self setEditing:NO animated:YES];
    }];
    
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppNoLabel, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
//        [self setEditing:NO animated:YES];
    }];
    
    [deleteFileDialog addAction:yesButton];
    [deleteFileDialog addAction:noButton];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.navigationController presentViewController:deleteFileDialog animated:YES completion:nil];
    });
    
}

//Based on http://stackoverflow.com/a/25628065/681233

- (void) validateFilenameTextFieldInput:(id) sender {
    BOOL enabled = NO;
    if([sender isKindOfClass:[UITextField class]]) {
        UITextField *tf = sender;
        NSString *data = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSRegularExpression *filenameRegex = [NSRegularExpression regularExpressionWithPattern:@"^[\\w,\\s-]+\\.pa55$" options:0 error:NULL];
        UIResponder *resp = tf;
        while(![resp isKindOfClass:[UIAlertController class]]) {
            resp = [resp nextResponder];
        }
        UIAlertController *alert = (UIAlertController *)resp;
        UIAlertAction *button = alert.actions[0]; //the button index to disable is always assumed to be 0
         enabled = ([filenameRegex matchesInString:data options:0 range:NSMakeRange(0, data.length)].count >= 1);
        /*
        if(enabled) {
            //avoid overwrite
            NSString *filePath = [[_fmHelper documentsDirectory] stringByAppendingPathComponent:data];
            enabled = ![_fmHelper.fileManager fileExistsAtPath:filePath];
        }
        */
        button.enabled = enabled;
    }
}

- (void) validatePasswordTextFieldInput:(id) sender {
    if([sender isKindOfClass:[UITextField class]]) {
        UITextField *tf = sender;
        NSString *data = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        UIResponder *resp = tf;
        while(![resp isKindOfClass:[UIAlertController class]]) {
            resp = [resp nextResponder];
        }
        UIAlertController *alert = (UIAlertController *)resp;
        UIAlertAction *button = alert.actions[0]; //the button index to disable is 0
        button.enabled = (data.length >= 1);
    }
}

- (void) showPasswordInputDialogForReadingFile:(NSString *) fileName {
    NSString *message = [NSString stringWithFormat:NSLocalizedString(lcFileListTableViewControllerReadPasswordPrompt, nil), [fileName lastPathComponent]];
    
    _inputPasswordDialog = [UIAlertController
                            alertControllerWithTitle:NSLocalizedString(lcFileListTableViewControllerReadPasswordPromptTitle, nil)
                            message:message
                            preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    
    [_inputPasswordDialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(lcAppPlaceholderPasswordLabel, nil);
        textField.secureTextEntry = YES;
        [textField addTarget:weakSelf action:@selector(validatePasswordTextFieldInput:) forControlEvents:UIControlEventEditingChanged];
    }];
    
    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppContinueLabel, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        _databasePassword = [_inputPasswordDialog.textFields[0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *errorMessage;
        _passwordDatabase = [_fmHelper readDbFromFile:fileName withPassword:_databasePassword catchErrorMessage:&errorMessage];
        if(_passwordDatabase!=nil) {
            [self performSegueWithIdentifier:@"showPasswordFile" sender:self];
        }
        if(errorMessage!=nil) {
            UIAlertController *warn = [UIAlertController
                                       alertControllerWithTitle:NSLocalizedString(lcAppFileReadErrorTitle, nil)
                                       message:errorMessage
                                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppOkLabel, nil) style:UIAlertActionStyleCancel handler:nil];
            [warn addAction:okButton];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.navigationController presentViewController:warn animated:YES completion:nil];
            });
        }
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppCancelLabel, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }];
    
    continueButton.enabled = NO; //default no
    [_inputPasswordDialog addAction:continueButton];
    [_inputPasswordDialog addAction:cancelButton];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.navigationController presentViewController:_inputPasswordDialog animated:YES completion:nil];
    });
    
}

- (void) showPasswordInputDialogForNewFile {
    
    _inputPasswordDialog = [UIAlertController
                            alertControllerWithTitle:NSLocalizedString(lcFileListTableViewControllerNewPasswordPromptTitle, nil)
                            message:NSLocalizedString(lcFileListTableViewControllerNewPasswordPrompt, nil)
                            preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    
    [_inputPasswordDialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(lcAppPlaceholderPasswordLabel, nil);
        textField.secureTextEntry = YES;
        [textField addTarget:weakSelf action:@selector(validatePasswordTextFieldInput:) forControlEvents:UIControlEventEditingChanged];
    }];
    
    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppContinueLabel, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        _databasePassword = [_inputPasswordDialog.textFields[0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _passwordDatabase = [[PasswordDatabase alloc] initWithEmptyDatabase];
        [self performSegueWithIdentifier:@"showPasswordFile" sender:self];
    }];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppCancelLabel, nil) style:UIAlertActionStyleCancel handler:nil];
    
    continueButton.enabled = NO; //default no
    [_inputPasswordDialog addAction:continueButton];
    [_inputPasswordDialog addAction:cancelButton];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.navigationController presentViewController:_inputPasswordDialog animated:YES completion:nil];
    });
    
}

- (IBAction)createNewEmptyDatabase:(id)sender {
    if(self.tableView.indexPathForSelectedRow!=nil) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
    [self showPasswordInputDialogForNewFile];
    //
}

- (void) showPasswordInputDialogForWritingDatabase:(PasswordDatabase *) passwordDatabase toFile:(NSString *) fileName withCurrentPassword:(NSString *) password {
    //_databaseFile = fileName;
    //_passwordDatabase = passwordDatabase;
    //_databasePassword = password;
    
    NSString *fileComponent = [fileName lastPathComponent];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(lcFileListTableViewControllerWritePasswordPrompt, nil), fileComponent];
    
    _inputPasswordDialog = [UIAlertController
                            alertControllerWithTitle:NSLocalizedString(lcFileListTableViewControllerWritePasswordPromptTitle, nil)
                            message:message
                            preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    
    [_inputPasswordDialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(lcAppPlaceholderFilenameLabel, nil);
        textField.text = fileComponent;
        [textField addTarget:weakSelf action:@selector(validateFilenameTextFieldInput:) forControlEvents:UIControlEventEditingChanged];
    }];
    
    [_inputPasswordDialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(lcAppPlaceholderPasswordLabel, nil);
        textField.secureTextEntry = YES;
        textField.text = password;
        [textField addTarget:weakSelf action:@selector(validatePasswordTextFieldInput:) forControlEvents:UIControlEventEditingChanged];
    }];
    
    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppContinueLabel, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSString *newFileName = [_inputPasswordDialog.textFields[0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *filePassword = [_inputPasswordDialog.textFields[1].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *errorMessage;
        _databaseFile = [[_fmHelper documentsDirectory] stringByAppendingPathComponent:newFileName];
        _databasePassword = filePassword;
        BOOL result = [_fmHelper writeDb:passwordDatabase toFile:_databaseFile withPassword:_databasePassword catchError:&errorMessage];
        //[_inputPasswordDialog dismissViewControllerAnimated:YES completion:nil]; //TODO: is this necessary?
        if(!result) {
            if(errorMessage!=nil) {
                UIAlertController *warn = [UIAlertController
                                           alertControllerWithTitle:NSLocalizedString(lcAppFileWriteErrorTitle, nil)
                                           message:errorMessage
                                           preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppOkLabel, nil) style:UIAlertActionStyleCancel handler:nil];
                [warn addAction:okButton];
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self.navigationController presentViewController:warn animated:YES completion:nil];
                });
            }
        }
        [self freeUpMemory];
        [self refreshFilesList];
    }];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppCancelLabel, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self freeUpMemory];
        [self refreshFilesList];
    }];
    
    //This can only happen if the user has never entered a password before
    if(password.length == 0) {
        continueButton.enabled = NO;
    }
    
    [_inputPasswordDialog addAction:continueButton];
    [_inputPasswordDialog addAction:cancelButton];
    
    /*
     This line causes the following error:
      popToViewController:transition: called on <UINavigationController 0x12345678> while an existing transition or presentation is occurring; the navigation stack will not be updated.
     FIXED: http://stackoverflow.com/questions/24854802/presenting-a-view-controller-modally-from-an-action-sheets-delegate-in-ios8-ios
     */
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.navigationController presentViewController:_inputPasswordDialog animated:YES completion:nil];
    });
    
}

- (void) freeUpMemory {
    //free up memory
    _passwordDatabase = nil;
    _databasePassword = nil;
    _databaseFile = nil;
    [MiscellaneousUtilities defaultInstance].cachedMasterSecret = nil;
}


@end
