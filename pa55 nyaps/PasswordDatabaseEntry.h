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
//  PasswordDatabaseEntry.h
//  pa55v2
//
//  Created by Anirban Basu on 7/26/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtendedNotes.h"
#import "UserPreference.h"
#import "PA55Encoder.h"

static NSString *kPasswordDatabaseEntryDefaultTag = @"new entry";

@interface PasswordDatabaseEntry : NSObject

@property (nonatomic, strong) NSString *tag; //cannot rename to id -- it is a keyword in Objective C
@property (nonatomic, strong) NSMutableArray<UserPreference *> *characterTypes;
@property (nonatomic, strong) NSString *userDefinedCharacters;
@property (nonatomic, strong) ExtendedNotes *notes;
@property (nonatomic) BOOL excludeNotes;
@property (nonatomic) NSUInteger issue;
@property (nonatomic) NSUInteger length;

- (instancetype) initWithDefaultValues;
- (instancetype) initWithDictionary:(NSDictionary *) dict;
- (NSDictionary *) dictionary;

- (void) removeFirstOccurrenceOfCharacterType:(CharacterType) type;
- (void) removeAllOccurrencesOfCharacterType:(CharacterType) type;

@end
