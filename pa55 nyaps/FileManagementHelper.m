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
//  FileManagementHelper.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/8/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "FileManagementHelper.h"

@implementation FileManagementHelper {
    AESCryptosystem *_cryptosystem;
}

#pragma mark Singleton Methods

+ (instancetype) defaultHelper {
    static FileManagementHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
    });
    return sharedHelper;
}

- (instancetype) init {
    _fileManager = [NSFileManager defaultManager];
    _cryptosystem = [[AESCryptosystem alloc] init];
    return self;
}

- (NSString *) documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (void) moveWithOverwriteItemAt:(NSURL *) url to:(NSURL*) destination {
    NSError *error;
    if([_fileManager fileExistsAtPath:[destination path]]) {
        [_fileManager removeItemAtURL:destination error:&error];
        if(error!=nil) {
            NSLog(@"File delete error: %@", [error localizedDescription]);
        }
        error = nil;
    }
    
    [_fileManager moveItemAtURL:url toURL:destination error:&error];
    
    if(error!=nil) {
        NSLog(@"File move error: %@", [error localizedDescription]);
    }
}

- (NSArray<NSString *> *) contentsOfDirectoryAtPath: (NSString *) path excludeSubDirectories:(BOOL) exclude {
    NSMutableArray<NSString *> *retVal = [[NSMutableArray alloc] init];
    NSArray *contents = [_fileManager contentsOfDirectoryAtPath:path error:NULL];
    for(int i=0; i<[contents count]; i++) {
        NSString *item = [contents objectAtIndex:i];
        BOOL directory = FALSE;
        BOOL exists = [_fileManager fileExistsAtPath:[path stringByAppendingPathComponent:item] isDirectory:&directory];
        if(exists) {
            if(directory) {
                if(!exclude) {
                    [retVal addObject:item];
                }
            }
            else {
                [retVal addObject:item];
            }
        }
        //NSLog(@"File %@ exists (=%d) and is a directory (=%d)",item,exists,directory);
    }
    return retVal;
}

- (NSError *) deleteFile:(NSString *) file inDirectory:(NSString *) path {
    NSError *error;
    [_fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
    return error;
}

- (NSError *) deleteFileAtPath:(NSString *) filePath {
    NSError *error;
    [_fileManager removeItemAtPath:filePath error:&error];
    return error;
}

#pragma mark - File I/O

- (BOOL) writeDb:(PasswordDatabase *) database toFile:(NSString *) file withPassword:(NSString *)password catchError:(NSString **) errorMessage {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    _lastSavedFileName = nil;
    BOOL success = NO;
    NSError *writeError = nil;
    Ciphertext *ct = nil;
    NSString *plaintextJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[database dictionary] options:NSJSONWritingPrettyPrinted error:&writeError] encoding:NSUTF8StringEncoding];
    if(writeError!=nil) {
        *errorMessage = [writeError localizedDescription];
    }
    else {
        @try {
            ct = [_cryptosystem encryptWithHmac:plaintextJSON password:password];
            //NSLog(@"About to save: %@", ct.ciphertext);
            writeError = nil;
            NSData *fileContents = [NSJSONSerialization dataWithJSONObject:[ct dictionary] options:NSJSONWritingPrettyPrinted error:&writeError];
            if(writeError!=nil) {
                *errorMessage = [writeError localizedDescription];
            }
            else {
                writeError = nil;
                [fileContents writeToFile:file options:NSDataWritingAtomic error:&writeError];
                if(writeError!=nil) {
                    *errorMessage = [writeError localizedDescription];
                }
                else {
                    success = YES;
                }
            }
        }
        @catch(NSException *exception) {
            *errorMessage = [exception reason];
        }
    }
    if(success) {
        _lastSavedFileName = [file lastPathComponent];
    }
    return success;
}

- (PasswordDatabase *) readDbFromFile:(NSString *) file withPassword:(NSString *)password catchErrorMessage:(NSString **) errorMessage {
    BOOL unreadableFile = NO;
    PasswordDatabase *inDb = nil;
    NSData *content = [NSData dataWithContentsOfFile:file];
    if(content==nil) {
        unreadableFile = YES;
        *errorMessage = NSLocalizedString(lcFileManagementHelperErrorEmptyFile, nil);
    }
    
    if(!unreadableFile) {
        NSError *readError = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:content options:NSJSONReadingMutableContainers error:&readError];
        
        if(!readError) {
            @try {
                Ciphertext *ciphertext = [[Ciphertext alloc] initWithDictionary:jsonDict];
                NSString *readFileContents = [_cryptosystem decryptWithHmac:ciphertext password:password];
                //NSLog(@"%@", readFileContents);
                
                NSData *readIn = [readFileContents dataUsingEncoding:NSUTF8StringEncoding];
                inDb = [[PasswordDatabase alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:readIn options:NSJSONReadingMutableContainers error:&readError]];
                if(readError!=nil) {
                    *errorMessage = [readError localizedDescription];
                    unreadableFile = YES;
                }
            }
            @catch(NSException *exception) {
                *errorMessage = [exception reason];
                unreadableFile = YES;
            }
        }
        else {
            *errorMessage = [readError localizedDescription];
            unreadableFile = YES;
        }
    }
    if(unreadableFile) {
        return nil;
    }
    else {
        return inDb;
    }
}

@end
