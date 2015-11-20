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
//  PasswordDatabase.h
//  pa55v2
//
//  Created by Anirban Basu on 7/26/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PasswordDatabaseEntry.h"

static NSString* kDbVersion = @"pa55v2_fs1.0";

@interface PasswordDatabase : NSObject

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *randomBits;
@property (nonatomic) NSUInteger randomBitsSize;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PasswordDatabaseEntry *> *database;

- (instancetype) initWithEmptyDatabase;
- (instancetype) initWithDictionary:(NSDictionary *) dict;
- (NSDictionary *) dictionary;

@end
