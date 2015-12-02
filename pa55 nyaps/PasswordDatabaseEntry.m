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
//  PasswordDatabaseEntry.m
//  pa55v2
//
//  Created by Anirban Basu on 7/26/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import "PasswordDatabaseEntry.h"

@implementation PasswordDatabaseEntry

- (instancetype) initWithDefaultValues {
    self = [[PasswordDatabaseEntry alloc] init];
    if(self) {
        _characterTypes = [[NSMutableArray alloc] init];
        _tag = [NSString stringWithFormat:@"%@%ld",kPasswordDatabaseEntryDefaultTag,(long)[[NSDate date] timeIntervalSince1970]];;
        [_characterTypes addObject:[[UserPreference alloc] initWithCharacterType:digits minimum:1]];
        [_characterTypes addObject:[[UserPreference alloc] initWithCharacterType:lowercase minimum:1]];
        [_characterTypes addObject:[[UserPreference alloc] initWithCharacterType:uppercase minimum:1]];
        [_characterTypes addObject:[[UserPreference alloc] initWithCharacterType:special minimum:1]];
        _length = kPasswordLengthDefault;
        _notes = [[ExtendedNotes alloc] initWithServiceName:_tag];
    }
    return self;
}

- (void) dealloc {
    _tag = nil;
    _characterTypes = nil;
    _userDefinedCharacters = nil;
    _notes = nil;
}

- (instancetype) initWithDictionary:(NSDictionary *) dict {
    self = [[PasswordDatabaseEntry alloc] init];
    if(self) {
        _tag = [dict objectForKey:@"Id"];
        _characterTypes = [[NSMutableArray alloc] init];
        [[dict objectForKey:@"CharacterTypes"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_characterTypes addObject:[[UserPreference alloc] initWithDictionary:obj] ];
        }];
        _userDefinedCharacters = [dict objectForKey:@"UserDefinedCharacters"];
        _notes = [[ExtendedNotes alloc] initWithDictionary:[dict objectForKey:@"Notes"]];
        _excludeNotes = false;
        _issue = [(NSNumber *)[dict objectForKey:@"Issue"] integerValue];
        _length = [(NSNumber *)[dict objectForKey:@"Length"] integerValue];
    }
    return self;
}

-(NSDictionary *)dictionary {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    if(_tag!=nil) {
        [result setObject:_tag forKey:@"Id"];
    }
    else {
        [result setObject:@"" forKey:@"Id"];
    }
    NSMutableArray *charTypeDictionary = [[NSMutableArray alloc] init];
    
    [_characterTypes enumerateObjectsUsingBlock:^(UserPreference *obj, NSUInteger idx, BOOL *stop) {
        [charTypeDictionary addObject:[obj dictionary]];
    }];
    
    [result setObject:charTypeDictionary forKey:@"CharacterTypes"];
    if(_userDefinedCharacters!=nil) {
        [result setObject:_userDefinedCharacters forKey:@"UserDefinedCharacters"];
    }
    else {
        [result setObject:@"" forKey:@"UserDefinedCharacters"];
    }
    [result setObject:[_notes dictionary] forKey:@"Notes"];
    [result setObject:[NSNumber numberWithInteger:_issue] forKey:@"Issue"];
    [result setObject:[NSNumber numberWithInteger:_length] forKey:@"Length"];
    return result;
}

- (void) removeFirstOccurrenceOfCharacterType:(CharacterType) type {
    __block UserPreference *toRemove = nil;
    [_characterTypes enumerateObjectsUsingBlock:^(UserPreference * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.characterType == type) {
            toRemove = obj;
            *stop = YES;
        }
    }];
    [_characterTypes removeObject:toRemove];
}

- (void) removeAllOccurrencesOfCharacterType:(CharacterType) type {
    __block NSMutableArray<UserPreference *> *toRemove = [[NSMutableArray alloc] init];
    [_characterTypes enumerateObjectsUsingBlock:^(UserPreference * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.characterType == type) {
            [toRemove addObject:obj];
        }
    }];
    [_characterTypes removeObjectsInArray:toRemove];
}

@end
