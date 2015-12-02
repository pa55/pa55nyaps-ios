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
//  UserPreference.m
//  pa55v2
//
//  Created by Anirban Basu on 7/2/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import "UserPreference.h"
#import "PA55Encoder.h"

@implementation UserPreference

- (instancetype) initWithCharacterType: (CharacterType) type include: (bool) include {
    self = [[UserPreference alloc] init];
    if(self) {
        _characterType = type;
        _include = include;
        if(_include == YES) {
            _minimum = 1;
        }
        else {
            _minimum = 0;
        }
        _maximum = -1;
    }
    return self;
}

- (instancetype) initWithCharacterType: (CharacterType) type minimum: (NSInteger) minimum maximum: (NSInteger) maximum {
    self = [[UserPreference alloc] init];
    if(self) {
        _characterType = type;
        _minimum = minimum;
        _maximum = maximum;
        if(_minimum > 0) {
            _include = YES;
        }
        else {
            _include = NO;
        }
    }
    return self;
}

- (instancetype) initWithCharacterType: (CharacterType) type minimum: (NSInteger) minimum {
    self = [[UserPreference alloc] init];
    if(self) {
        _characterType = type;
        _minimum = minimum;
        _maximum = -1;
        if(_minimum > 0) {
            _include = YES;
        }
        else {
            _include = NO;
        }
    }
    return self;
}

- (instancetype) initWithDictionary:(NSDictionary *) dict {
    self = [[UserPreference alloc] init];
    if(self) {
        _minimum = [(NSNumber *)[dict objectForKey:@"Minimum"] integerValue];
        _maximum = [(NSNumber *)[dict objectForKey:@"Maximum"] integerValue];
        _characterType = [PA55Encoder stringToCharType:[dict objectForKey:@"CharacterType"]];
        _include = [(NSNumber *)[dict objectForKey:@"Include"] boolValue];
    }
    return self;
}

- (NSDictionary *) dictionary {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:[NSString stringWithFormat:@"%@", [PA55Encoder charTypeToString:_characterType]] forKey:@"CharacterType"];
    [result setObject:[NSNumber numberWithBool:_include] forKey:@"Include"];
    [result setObject:[NSNumber numberWithInteger:_minimum] forKey:@"Minimum"];
    [result setObject:[NSNumber numberWithInteger:_maximum] forKey:@"Maximum"];
    return result;
}

@end
