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
//  PA55Encoder.h
//  pa55v2
//
//  Created by Anirban Basu on 6/28/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AESDRBG.h"
#include "GlobalEnums.h"

#import "UserPreference.h"
#import "CharacterTypeCount.h"

static NSString* lcPA55EncoderExceptionPasswordLengthTooShort = @"pa55encoder-exception-pwd-length-too-short";
static NSString* lcPA55EncoderExceptionPasswordLengthTooLong = @"pa55encoder-exception-pwd-length-too-long";
static NSString* lcPA55EncoderExceptionUnknownCharacterType = @"pa55encoder-exception-unknown-char-type";
static NSString* lcPA55EncoderExceptionUnknownPreferencesType = @"pa55encoder-exception-unknown-pref-type";

static NSString* kCharTypeLowercase = @"abcdefghijkmnopqrstuvwxyz";
static NSString* kCharTypeUppercase = @"ABCDEFGHJKLMNPQRSTUVWXYZ";
static NSString* kCharTypeDigits = @"0123456789";
static NSString* kCharTypeSpecial = @"!=+@#$?%^&/:*_,";
static NSString* kCharTypeBrackets = @"(){}[]<>";

static NSUInteger kPasswordLengthMinimum = 3;
static NSUInteger kPasswordLengthMaximum = 64;
static NSUInteger kPasswordLengthDefault = 16;
static NSUInteger kPasswordLengthStep = 1;
static NSUInteger kIssueMinimum = 1;
static NSUInteger kIssueStep = 1;
static NSUInteger kIssueMaximum = INT32_MAX;

@interface PA55Encoder : NSObject

@property (nonatomic, strong) NSMutableDictionary* charsets;
@property (nonatomic, strong) NSMutableArray<UserPreference*> *userPreferences;
@property (nonatomic) long shuffleSeed;

- (instancetype) initWithCharsets;

- (bool) assignUserCharacterSet:(NSString *) characters;
- (NSString*) shuffleString:(NSString*) data withSeed: (NSData *) seed;
- (NSString *) encodeData: (NSData *) randomSeeds outputLength:(NSUInteger) length;

+ (NSString*) charTypeToString:(CharacterType)charType;
+ (CharacterType) stringToCharType:(NSString *)charType;
+ (NSMutableArray <CharacterTypeCount *> *) characterTypeCountsSortedByCounts:(NSMutableArray <CharacterTypeCount *> *) data;
+ (NSMutableArray <UserPreference *> *) userPreferencesSortedByCharacterType:(NSMutableArray <UserPreference *>*) data;

@end
