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
//  AppDelegate.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 7/28/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import "AppDelegate.h"
#import "FileManagementHelper.h"
#import "FileListTableViewController.h"
#import "PasswordEntryTableViewController.h"
#import "PasswordListTableViewController.h"
#import "GlobalConstants.h"
#import "NYAPSCore.h"

@interface AppDelegate ()

@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, strong) NSDate *startTimeout;
@property (nonatomic) BOOL shouldExecuteAutoSaveTask;
@property (nonatomic) BOOL shouldNotifyUser;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // Override point for customization after application launch.
    if([userDefaults objectForKey:strPreferencesAutoSaveTimeout]==nil) {
        [userDefaults setInteger:kAutoSaveTimeoutInSeconds forKey:strPreferencesAutoSaveTimeout];
    }
    NSString *versionAndBuild = [NSString stringWithFormat:@"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [userDefaults setObject:versionAndBuild forKey:strPreferencesAppVersion];
    _shouldNotifyUser = NO;
    return YES;
}

- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    FileManagementHelper *fmHelper = [FileManagementHelper defaultHelper];
    
    NSString *appFile = [[fmHelper documentsDirectory] stringByAppendingPathComponent:[url lastPathComponent]];
    
    [fmHelper moveWithOverwriteItemAt:url to:[NSURL fileURLWithPath:appFile]];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIFileListShouldRefreshNotification object:nil];
    
#ifdef DEBUG
    NSLog(@"Incoming file %@ copied locally to %@", [url path], appFile);
#endif
    _shouldNotifyUser = NO;
    return TRUE;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    _startTimeout = [NSDate date];
    NSInteger timeOut = [[NSUserDefaults standardUserDefaults] integerForKey:strPreferencesAutoSaveTimeout];
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    if(navController.viewControllers.count > 1) {
#ifdef DEBUG
        NSLog(@"Will start a background task to auto-save after %ld seconds.", timeOut);
#endif
        _shouldExecuteAutoSaveTask = YES;
        if(timeOut > 0) {
            _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
#ifdef DEBUG
                NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:_startTimeout];
                NSLog(@"Time elapsed before background task warning: %f seconds.", interval);
#endif
                [self saveDataAndPopoutToFileList];
                [[UIApplication sharedApplication] endBackgroundTask: _bgTask];
                _bgTask = UIBackgroundTaskInvalid;
            }];
            
            if(_bgTask == UIBackgroundTaskInvalid) {
                //immediately clear the data
                [self saveDataAndPopoutToFileList];
            }
            else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    @synchronized(self) {
                        [self saveDataAndPopoutToFileList];
                        [[UIApplication sharedApplication] endBackgroundTask: _bgTask];
                        _bgTask = UIBackgroundTaskInvalid;
                    }
                });
            }
        }
        else if (timeOut == 0) {
            [self saveDataAndPopoutToFileList];
        }
    }
    else if(navController.presentedViewController!=nil) {
#ifdef DEBUG
        NSLog(@"The navigation controller had a modally presented view controller that will be closed, and any unsaved file will be closed and saved.");
#endif
        FileListTableViewController *fileListVC = [navController.viewControllers objectAtIndex:0];
        [fileListVC.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [navController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        if ([fileListVC saveFileIfUnsaved]) { //having dismissed the alert controllers if any, we should save any unsaved data.
            _shouldNotifyUser = YES;
        }
    }
    else {
#ifdef DEBUG
        NSLog(@"The current file list view does not require further protection through auto-save and close.");
#endif
    }
    
}

- (void) notifyTheUserOfAutoSave {
    if(_shouldNotifyUser) {
        UIAlertController *notice = [UIAlertController
                                   alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(lcAppAutoSaveTitle, nil), [FileManagementHelper defaultHelper].lastSavedFileName]
                                   message:[NSString stringWithFormat:NSLocalizedString(lcAppAutoSaveMessage, nil), [FileManagementHelper defaultHelper].lastSavedFileName]
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppOkLabel, nil) style:UIAlertActionStyleDefault handler:nil];
        [notice addAction:okButton];
        dispatch_async(dispatch_get_main_queue(), ^ {
            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
            [navController presentViewController:notice animated:YES completion:^{
                _shouldNotifyUser = NO;
            }];
        });
    }
}

- (void) saveDataAndPopoutToFileList {
    //TODO: This method needs to be more clever to run validations of user inputs
    //FIXME: Unsaved data from the PasswordEntryTableViewController is not getting saved although the call to the file management helper has now been reduced to 1 from the PasswordListTableViewController because the unwindSegue is now called just once. Why is the unwindSegue not called on the PasswordEntryTableViewController?
    if(_shouldExecuteAutoSaveTask) {
        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        while (navController.viewControllers.count > 1) {
            [navController.viewControllers.lastObject.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            if([navController.viewControllers.lastObject isKindOfClass:[PasswordListTableViewController class]]) {
                PasswordListTableViewController *vc = (PasswordListTableViewController *) navController.viewControllers.lastObject;
                vc.shouldSaveSilently = YES;
            }
            else if([navController.viewControllers.lastObject isKindOfClass:[PasswordEntryTableViewController class]]) {
                PasswordEntryTableViewController *vc = (PasswordEntryTableViewController *) navController.viewControllers.lastObject;
                [vc updateModelWithUI];
            }
            [navController popViewControllerAnimated:NO]; //will this call unwind segue, if any?
        }
        FileListTableViewController *fileVC = (FileListTableViewController *)navController.viewControllers.lastObject;
        if([fileVC saveFileIfUnsaved]) {
#ifdef DEBUG
            NSLog(@"Auto-saved database to %@.", [FileManagementHelper defaultHelper].lastSavedFileName);
#endif
            _shouldNotifyUser = YES;
        }
        _shouldExecuteAutoSaveTask = NO;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    _shouldExecuteAutoSaveTask = NO;
    if(_bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask: _bgTask];
        _bgTask = UIBackgroundTaskInvalid;
#ifdef DEBUG
        NSLog(@"Background auto-save task has been cancelled.");
#endif
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIFileListShouldRefreshNotification object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self notifyTheUserOfAutoSave];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if(_bgTask != UIBackgroundTaskInvalid) {
        [self saveDataAndPopoutToFileList];
        [[UIApplication sharedApplication] endBackgroundTask: _bgTask];
        _bgTask = UIBackgroundTaskInvalid;
#ifdef DEBUG
        NSLog(@"Background auto-save task has been executed due to app termination request.");
#endif
    }
}

@end
