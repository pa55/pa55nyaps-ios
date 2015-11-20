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
//  AESCryptosystem.h
//  pa55v2
//
//  Created by Anirban Basu on 7/27/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ciphertext.h"

static NSUInteger kKeySize = 16; //bytes
static NSUInteger kHmacKeySize = 32; //bytes
static NSUInteger kSaltSize = 16; //bytes
static NSUInteger kIvSize = 16; //bytes

static NSString *lcAESCryptosystemGenerateRandomDataFailTitle = @"aescryptosystem-gen-rnd-data-fail-title";
static NSString *lcAESCryptosystemGenerateRandomDataFail = @"aescryptosystem-gen-rnd-data-fail";
static NSString *lcAESCryptosystemCryptorFailTitle = @"aescryptosystem-cryptor-fail-title";
static NSString *lcAESCryptosystemEncryptCryptorFail = @"aescryptosystem-encrypt-cryptor-fail";
static NSString *lcAESCryptosystemEncryptFail = @"aescryptosystem-encrypt-fail";
static NSString *lcAESCryptosystemDecryptHmacFailTitle = @"aescryptosystem-decrypt-hmac-fail-title";
static NSString *lcAESCryptosystemDecryptHmacFail = @"aescryptosystem-decrypt-hmac-fail";
static NSString *lcAESCryptosystemDecryptCryptorFail = @"aescryptosystem-decrypt-cryptor-fail";
static NSString *lcAESCryptosystemDecryptFail = @"aescryptosystem-decrypt-fail";

@interface AESCryptosystem : NSObject

- (Ciphertext *) encryptWithHmac: (NSString *) inputString password: (NSString *) password;
- (NSString *) decryptWithHmac: (Ciphertext *) ciphertext password: (NSString *) password;

@end
