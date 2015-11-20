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
//  FileManagementHelper.h
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/8/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PasswordDatabase.h"
#import "AESCryptosystem.h"

static NSString *UIFileListShouldRefreshNotification = @"uiFileListShouldRefreshNotification";
static NSString* lcFileManagementHelperErrorEmptyFile = @"filemanagementhelper-error-empty-file";

@interface FileManagementHelper : NSObject

@property (nonatomic, retain, readonly) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *lastSavedFileName;

+ (instancetype) defaultHelper;

- (NSString *) documentsDirectory;

- (void) moveWithOverwriteItemAt:(NSURL *) url to:(NSURL*) destination;
- (NSArray<NSString *> *) contentsOfDirectoryAtPath:(NSString *) path excludeSubDirectories:(BOOL) exclude;
- (NSError *) deleteFile:(NSString *) file inDirectory:(NSString *) path;
- (NSError *) deleteFileAtPath:(NSString *) filePath;

- (PasswordDatabase *) readDbFromFile:(NSString *) file withPassword:(NSString *)password catchErrorMessage:(NSString **) errorMessage;
- (BOOL) writeDb:(PasswordDatabase *) database toFile:(NSString *) file withPassword:(NSString *)password catchError:(NSString **) errorMessage;

@end
