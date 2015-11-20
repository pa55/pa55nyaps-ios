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
//  ExtendedNotes.m
//  pa55v2
//
//  Created by Anirban Basu on 10/7/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "ExtendedNotes.h"
#import "GlobalConstants.h"

@implementation ExtendedNotes

- (instancetype) initWithServiceName:(NSString *) serviceName {
    self = [[ExtendedNotes alloc] init];
    if(self) {
        _serviceName = serviceName;
        _serviceLink = NSLocalizedString(lcAppEmptyString, nil);
        _userID = NSLocalizedString(lcAppEmptyString, nil);
        _additionalInfo = NSLocalizedString(lcAppEmptyString, nil);
    }
    return self;
}

- (void) dealloc {
    _serviceName = nil;
    _serviceLink = nil;
    _userID = nil;
    _additionalInfo = nil;
}

- (instancetype) initWithJSON:(NSString *) jsonString {
    NSError *readError;
    self = [[ExtendedNotes alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&readError]];
    if(readError!=nil) {
        NSLog(@"Read error: %@", [readError description]);
    }
    return self;
}

- (instancetype) initWithDictionary:(NSDictionary *) dict {
    self = [[ExtendedNotes alloc] init];
    if(self) {
        _serviceName = [dict objectForKey:@"ServiceName"];
        _serviceLink = [dict objectForKey:@"ServiceLink"];
        _userID = [dict objectForKey:@"UserID"];
        _additionalInfo = [dict objectForKey:@"AdditionalInfo"];
    }
    return self;
}

- (NSDictionary *) dictionary {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:_serviceName forKey:@"ServiceName"];
    [result setObject:_serviceLink forKey:@"ServiceLink"];
    [result setObject:_userID forKey:@"UserID"];
    [result setObject:_additionalInfo forKey:@"AdditionalInfo"];
    return result;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"ServiceName=%@;ServiceLink=%@;UserID=%@;AdditionalInfo=%@",_serviceName,_serviceLink,_userID,_additionalInfo];
}

- (NSString *) contentExcerpt {
    return [NSString stringWithFormat:@"%@ %@ %@ %@",_serviceName,_serviceLink,_userID,_additionalInfo];
}

@end
