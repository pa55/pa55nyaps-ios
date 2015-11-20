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
//  Ciphertext.m
//  pa55v2
//
//  Created by Anirban Basu on 7/27/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import "Ciphertext.h"

@implementation Ciphertext

- (instancetype) initWithDictionary:(NSDictionary *) dict {
    self = [[Ciphertext alloc] init];
    if(self) {
        _salt = [dict objectForKey:@"Salt"];
        _iv = [dict objectForKey:@"Iv"];
        _ciphertext = [dict objectForKey:@"Ciphertext"];
        _hmac = [dict objectForKey:@"Hmac"];
        
        _keySize = [(NSNumber *)[dict objectForKey:@"KeySize"] integerValue];
        _saltSize = [(NSNumber *)[dict objectForKey:@"SaltSize"] integerValue];
        _ivSize = [(NSNumber *)[dict objectForKey:@"IvSize"] integerValue];
        _hmacKeySize = [(NSNumber *)[dict objectForKey:@"HmacKeySize"] integerValue];
    }
    return self;
}

-(NSDictionary *) dictionary {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:_salt forKey:@"Salt"];
    [result setObject:_iv forKey:@"Iv"];
    [result setObject:_ciphertext forKey:@"Ciphertext"];
    [result setObject:_hmac forKey:@"Hmac"];
    
    [result setObject:[NSNumber numberWithInteger:_keySize] forKey:@"KeySize"];
    [result setObject:[NSNumber numberWithInteger:_saltSize] forKey:@"SaltSize"];
    [result setObject:[NSNumber numberWithInteger:_ivSize] forKey:@"IvSize"];
    [result setObject:[NSNumber numberWithInteger:_hmacKeySize] forKey:@"HmacKeySize"];
    return result;
}

@end
