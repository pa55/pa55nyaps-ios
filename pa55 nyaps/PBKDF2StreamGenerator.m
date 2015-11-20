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
//  PBKDF2StreamGenerator.m
//  pa55v2
//
//  Created by Anirban Basu on 7/3/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import "PBKDF2StreamGenerator.h"

@implementation PBKDF2StreamGenerator

+ (NSData *) generateStreamWithPassword: (NSData *)password salt:(NSData *) salt length:(NSUInteger) length {
    return [PBKDF2StreamGenerator generateStreamWithPassword:password salt:salt length:length rounds:kPBKDF2Rounds];
}

+ (NSData *) generateStreamWithPassword: (NSData *)password salt:(NSData *) salt length:(NSUInteger) length rounds:(NSUInteger) rounds {
    uint8_t result[length];
    CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA512, (uint)rounds, result, length);
    return [NSData dataWithBytes:result length:length];
}

+ (NSData *) generateSHA1StreamWithPassword: (NSData *)password salt:(NSData *) salt length:(NSUInteger) length rounds:(NSUInteger) rounds {
    uint8_t result[length];
    CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA1, (uint)rounds, result, length);
    return [NSData dataWithBytes:result length:length];
}

@end
