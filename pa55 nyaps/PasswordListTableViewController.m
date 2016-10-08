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
//  PasswordListTableViewController.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/6/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "PasswordListTableViewController.h"
#import "PasswordEntryTableViewController.h"
#import "FileListTableViewController.h"
#import "FileManagementHelper.h"

@interface PasswordListTableViewController ()

@property (nonatomic, strong) NSMutableArray<NSString *> *passwordDatabaseKeys;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation PasswordListTableViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self setEditing:NO animated:YES]; //is this necessary?
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"DecoratedPasswordEntryTableViewCell" bundle:nil] forCellReuseIdentifier:@"passwordEntry"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.backBarButtonItem.title = NSLocalizedString(lcPasswordListTableViewControllerBackButton, nil);
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    
    // Use the current view controller to update the search results.
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // It is usually good to set the presentation context
    self.definesPresentationContext = YES;
    
    
    [self updateDatabaseKeysForcingDataReload:YES];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [searchController.searchBar.text lowercaseString];
    
    // Check if the user cancelled or deleted the search term so we can display the full list instead.
    if (![searchString isEqualToString:@""]) {
        if(_passwordDatabaseKeys==nil) {
            _passwordDatabaseKeys = [[NSMutableArray alloc] init];
        }
        [_passwordDatabaseKeys removeAllObjects];
        [_passwordDatabase.database enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, PasswordDatabaseEntry * _Nonnull obj, BOOL * _Nonnull stop) {
            if([[obj.tag lowercaseString] containsString:searchString] ||
               [[obj.notes.userID lowercaseString] containsString:searchString] ||
               [[obj.notes.serviceName lowercaseString] containsString:searchString] ||
               [[obj.notes.serviceLink lowercaseString] containsString:searchString] ||
               [[obj.notes.additionalInfo lowercaseString] containsString:searchString] ||
               [searchString isEqualToString:[NSString stringWithFormat:@"%lu", (unsigned long)obj.length]] ||
               [searchString isEqualToString:[NSString stringWithFormat:@"%lu", (unsigned long)obj.issue]]) {
                [_passwordDatabaseKeys addObject:key];
            }
        }];
        [self.tableView reloadData];
    }
    else {
        [self updateDatabaseKeysForcingDataReload:YES];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self updateDatabaseKeysForcingDataReload:YES];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    [self updateDatabaseKeysForcingDataReload:YES];
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
    return [_passwordDatabaseKeys count];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DecoratedPasswordEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"passwordEntry" forIndexPath:indexPath];
    
    // Configure the cell...
    if(cell!=nil) {
        PasswordDatabaseEntry *dbEntry = [_passwordDatabase.database objectForKey:[_passwordDatabaseKeys objectAtIndex:indexPath.row]];
        if(dbEntry!=nil) {
            //cell.textLabel.text = dbEntry.tag;
            //cell.detailTextLabel.text = [NSString stringWithFormat:@"Length: %ld. Issue: %ld. Service name: %@", dbEntry.length, dbEntry.issue, dbEntry.notes.serviceName];
            //cell.imageView.image = [UIImage imageNamed:@"PasswordEntry"];
            cell.cellID.text = dbEntry.tag;
            cell.cellServiceName.text = [NSString stringWithFormat:@"%@ %@", dbEntry.notes.serviceName, dbEntry.notes.userID];
            cell.cellLength.text = [NSString stringWithFormat:@"%ld",(unsigned long)dbEntry.length];
            cell.cellIssueNumber.text = [NSString stringWithFormat:@"%ld",(unsigned long)dbEntry.issue];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //cell.detailTextLabel.text = [NSString stringWithFormat:@"[%ld] [%ld] [%@]", dbEntry.length, dbEntry.issue, [characterTypeSummary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        }
    }
    
    return cell;
}

- (void) updateDatabaseKeysForcingDataReload:(BOOL) reload {
    if(_passwordDatabaseKeys==nil) {
        _passwordDatabaseKeys = [[NSMutableArray alloc] init];
    }
    [_passwordDatabaseKeys removeAllObjects];
    [_passwordDatabaseKeys addObjectsFromArray:[[_passwordDatabase.database allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }]];
    if(reload) {
        [self.tableView reloadData];
    }
}

- (void) setPasswordDatabase:(PasswordDatabase *)passwordDatabase {
    _passwordDatabase = passwordDatabase;
    [self updateDatabaseKeysForcingDataReload:YES];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return NSLocalizedString(lcPasswordListTableViewControllerTableHeaderSection0, nil);
    }
    else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 0) {
        if([_passwordDatabaseKeys count] == 0) {
            return NSLocalizedString(lcPasswordListTableViewControllerTableFooterSection0Empty, nil);
        }
        else {
            return NSLocalizedString(lcPasswordListTableViewControllerTableFooterSection0, nil);
        }
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //fire it correctly
    if(indexPath.section == 0) {
        if(tableView.isEditing) {
            [self performSegueWithIdentifier:@"showPasswordEntry" sender:self];
        }
        else {
            [self performSegueWithIdentifier:@"generatePassword" sender:self];
        }
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void) deleteWithConfirmationDatabaseIdentifiedBy:(NSIndexPath *) indexPath inTableView:(UITableView *) tableView {
    UIAlertController *deleteEntryDialog = [UIAlertController
                                           alertControllerWithTitle:NSLocalizedString(lcPasswordListTableViewControllerDeletEntryPromptTitle, nil)
                                           message:[NSString stringWithFormat:NSLocalizedString(lcPasswordListTableViewControllerDeletEntryPrompt, nil), [_passwordDatabaseKeys objectAtIndex:indexPath.row]]
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppYesLabel, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [_passwordDatabase.database removeObjectForKey:[_passwordDatabaseKeys objectAtIndex:indexPath.row]];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateDatabaseKeysForcingDataReload:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self setEditing:NO animated:YES];
    }];
    
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppNoLabel, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self setEditing:NO animated:YES];
    }];
    
    [deleteEntryDialog addAction:yesButton];
    [deleteEntryDialog addAction:noButton];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:deleteEntryDialog animated:YES completion:nil];
    });
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if(indexPath.section == 0) {
            [self deleteWithConfirmationDatabaseIdentifiedBy:indexPath inTableView:tableView];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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


#pragma mark - User Interaction

- (IBAction)showShareDialog:(id)sender {
    NSString *errorMessage;
    [[FileManagementHelper defaultHelper] writeDb:_passwordDatabase toFile:_passwordDatabaseFile withPassword:_databasePassword catchError:&errorMessage];
    if(errorMessage == nil) {
        NSURL *fileURL = [NSURL fileURLWithPath:_passwordDatabaseFile];
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:
                                         @[fileURL] applicationActivities:nil];
        avc.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypePostToTwitter, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:avc animated:YES completion:nil];
        });
    }
    else {
        UIAlertController *warn = [UIAlertController
                                   alertControllerWithTitle:NSLocalizedString(lcAppFileWriteErrorTitle, nil)
                                   message:errorMessage
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppOkLabel, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        }];
        [warn addAction:okButton];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:warn animated:YES completion:nil];
        });
    }
}

- (IBAction)createNewDefaultPasswordEntry:(id)sender {
    if(self.tableView.indexPathForSelectedRow!=nil) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
    [self performSegueWithIdentifier:@"showPasswordEntry" sender:self];
}


#pragma mark - Navigation

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UIViewController *vc = self.navigationController.topViewController;
    if ([vc isKindOfClass:[FileListTableViewController class]]) {
        [self performSegueWithIdentifier:segidUnwindToFileList sender:self];
    }
}

- (void)dealloc {
    [self.searchController.view removeFromSuperview];
}

- (IBAction)unwindToPasswordList:(UIStoryboardSegue*)sender {
    // Pull any data from the view controller which initiated the unwind segue.
    if([sender.sourceViewController isKindOfClass:[PasswordEntryTableViewController class]]) {
        [self updateDatabaseKeysForcingDataReload:YES];
    }
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showPasswordEntry"]) {
        PasswordEntryTableViewController *destinationVC = segue.destinationViewController;
        if(self.tableView.indexPathForSelectedRow!=nil) {
            destinationVC.databaseEntry = [_passwordDatabase.database objectForKey:[_passwordDatabaseKeys objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        }
        else {
            PasswordDatabaseEntry *newEntry = [[PasswordDatabaseEntry alloc] initWithDefaultValues];
            destinationVC.databaseEntry = newEntry;
            [_passwordDatabase.database setObject:newEntry forKey:newEntry.tag];
            [_passwordDatabaseKeys addObject:newEntry.tag];
        }
        destinationVC.databaseReference = _passwordDatabase;
    }
    else if([segue.identifier isEqualToString:@"generatePassword"]) {
        GeneratePasswordViewController *destinationVC = segue.destinationViewController;
        PasswordDatabaseEntry *entry = [_passwordDatabase.database objectForKey:[_passwordDatabaseKeys objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        //do not pass any of the parameters as pointers, always copy.
        destinationVC.passwordLength = entry.length;
        destinationVC.userPreferences = [[NSMutableArray alloc] initWithArray:entry.characterTypes];
        destinationVC.dynamicHint = [NSString stringWithFormat:@"%@%ld",[entry.notes description], (unsigned long)entry.issue];
        destinationVC.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(lcGeneratePasswordViewControllerTitle, nil), entry.tag];
        //destinationVC.userCharset = [NSString stringWithString:_databaseEntry.userDefinedCharacters];
    }
}


@end
