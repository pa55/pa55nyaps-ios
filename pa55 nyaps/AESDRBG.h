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

//  AESDRBG.h
//  pa55v2

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonCryptor.h>

static NSString *lcAESDRBGFailTitle = @"aesdrbg-fail-title";
static NSString *lcAESDRBGUpdateFail = @"aesdrbg-update-fail";
static NSString *lcAESDRBGInvalidSeed = @"aesdrbg-invalid-seed";
static NSString *lcAESDRBGInvalidBound = @"aesdrbg-invalid-bound";

@interface AESDRBG : NSObject

- (instancetype) initWithRawSeed:(NSData *) seed;
- (uint32_t) nextInt:(uint32_t) bound;
- (uint8_t) nextByte:(uint16_t) bound;

@end
