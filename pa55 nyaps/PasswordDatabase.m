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
//  PasswordDatabase.m
//  pa55v2
//
//  Created by Anirban Basu on 7/26/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import "PasswordDatabase.h"
#import "PasswordDatabaseEntry.h"

@implementation PasswordDatabase

- (instancetype) initWithEmptyDatabase {
    self = [[PasswordDatabase alloc] init];
    if(self) {
        _database = [[NSMutableDictionary alloc] init];
        _version = kDbVersion;
    }
    return self;
}

- (void) dealloc {
    _database = nil;
    _randomBits = nil;
    _version = nil;
}

- (instancetype) initWithDictionary:(NSDictionary *) dict {
    self = [[PasswordDatabase alloc] init];
    if(self) {
        _database = [[NSMutableDictionary alloc] init];
        NSDictionary *dataDict = [dict objectForKey:@"Database"];
        
        [dataDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [_database setObject:[[PasswordDatabaseEntry alloc] initWithDictionary:obj] forKey:key];
        }];
        
        _version = [dict objectForKey:@"Version"];
        if(_version==nil) {
            _version = kDbVersion;
        }
        
        _randomBits = [dict objectForKey:@"RandomBits"];
        _randomBitsSize = [(NSNumber *)[dict objectForKey:@"RandomBitsSize"] integerValue];
    }
    return self;
}

-(NSDictionary *) dictionary {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:_version forKey:@"Version"];
    if(_randomBits!=nil) {
        [result setObject:_randomBits forKey:@"RandomBits"];
        [result setObject:[NSNumber numberWithInteger:_randomBitsSize] forKey:@"RandomBitsSize"];
    }
    NSMutableDictionary *dbDictionary = [[NSMutableDictionary alloc] init];
    [_database enumerateKeysAndObjectsUsingBlock:^(NSString *key, PasswordDatabaseEntry *obj, BOOL *stop) {
        [dbDictionary setObject:[obj dictionary] forKey:key];
    }];
    [result setObject:dbDictionary forKey:@"Database"];
    return result;
}

@end
