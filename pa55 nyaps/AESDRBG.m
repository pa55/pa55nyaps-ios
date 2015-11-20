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
//  AESDRBG.m
//  pa55v2
//
//  Created by Anirban Basu on 7/1/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import "AESDRBG.h"

@implementation AESDRBG {
    NSData *_seed;
    NSMutableData *_aesKey;
    NSMutableData *_iv;
    NSMutableData *_plaintext;
    CCCryptorRef _cryptor;
    
    NSInputStream *_buffer;
}

- (instancetype) initWithRawSeed:(NSData *) seed {
    self = [[AESDRBG alloc] init];
    if(self) {
        if(seed.length != kCCKeySizeAES128) {
            [NSException raise:NSLocalizedString(lcAESDRBGFailTitle, nil) format:NSLocalizedString(lcAESDRBGInvalidSeed, nil), _seed.description];
        }
        char zerobytes [kCCKeySizeAES128];
        bzero(zerobytes, sizeof(zerobytes));
        _seed = [[NSMutableData alloc] initWithBytes:seed.bytes length:kCCKeySizeAES128];
        _aesKey = [[NSMutableData alloc] initWithBytes:seed.bytes length:kCCKeySizeAES128];
        _iv = [NSMutableData dataWithBytes:zerobytes length:kCCKeySizeAES128];
        _plaintext = [NSMutableData dataWithBytes:zerobytes length:kCCBlockSizeAES128];
        //Create Cryptor
        CCCryptorStatus  create = CCCryptorCreateWithMode(kCCEncrypt, kCCModeCTR, kCCAlgorithmAES, ccNoPadding, _iv.bytes, _aesKey.bytes, _aesKey.length, NULL, 0, 0, kCCModeOptionCTR_BE, &_cryptor);
        
        _buffer = nil;
        
        if(create != kCCSuccess){
            return nil;
        }
    }
    return self;
}

- (uint32_t) nextIntFromBuffer {
    if(_buffer == nil || ![_buffer hasBytesAvailable]) {
        if(_buffer!=nil) {
            [_buffer close];
        }
        _buffer = [NSInputStream inputStreamWithData:[NSData dataWithBytes:[self next] length:_plaintext.length]];
        [_buffer open];
    }
    uint8_t bytes4[4];
    bzero(bytes4, 4);
    [_buffer read:bytes4 maxLength:4];
    return abs(NSSwapBigIntToHost(*(uint32_t *)bytes4)); //FIXME: ignore the warning about abs -- it is wrong because NSSwapBigIntToHost does not always generate unsigned numbers?
}

- (uint8_t) nextByteFromBuffer {
    if(_buffer == nil || ![_buffer hasBytesAvailable]) {
        if(_buffer!=nil) {
            [_buffer close];
        }
        _buffer = [NSInputStream inputStreamWithData:[NSData dataWithBytes:[self next] length:_plaintext.length]];
        [_buffer open];
    }
    uint8_t onebyte[1];
    bzero(onebyte, 1);
    [_buffer read:onebyte maxLength:1];
    return onebyte[0];
}

- (const void *) next {
    size_t outLen;
    NSMutableData *result = [NSMutableData dataWithLength:_plaintext.length];
    CCCryptorStatus update = CCCryptorUpdate(_cryptor, _plaintext.bytes, _plaintext.length, result.mutableBytes, result.length, &outLen);
    if(update != kCCSuccess) {
       [NSException raise:NSLocalizedString(lcAESDRBGFailTitle, nil) format:NSLocalizedString(lcAESDRBGUpdateFail, nil), _plaintext.length];
    }
    return result.bytes;
}

- (uint32_t) getPowerOfTwoWithBound: (uint32_t) bound {
    uint32_t hob = bound;
    hob |= (hob >>  1);
    hob |= (hob >>  2);
    hob |= (hob >>  4);
    hob |= (hob >>  8);
    hob |= (hob >> 16);
    hob = hob - (hob >> 1);
    return ((bound & (bound-1))==0)? bound : hob << 1;
}

- (uint32_t) nextInt:(uint32_t) bound {
    if (bound > (1<<30)) {
        [NSException raise:NSLocalizedString(lcAESDRBGFailTitle, nil) format:NSLocalizedString(lcAESDRBGInvalidBound, nil), __PRETTY_FUNCTION__, 2, 2147483648];
    }
    uint32_t actual_bound = [self getPowerOfTwoWithBound:bound];
    uint32_t desired = (1 << 30);
    while(desired >= bound) {
        desired = [self nextIntFromBuffer] % actual_bound;
    }
    return desired;
}

- (uint8_t) nextByte:(uint16_t) bound {
    if (bound >= 256) {
        [NSException raise:NSLocalizedString(lcAESDRBGFailTitle, nil) format:NSLocalizedString(lcAESDRBGInvalidBound, nil), __PRETTY_FUNCTION__, 2, 255];
    }
    uint32_t actual_bound = [self getPowerOfTwoWithBound:bound];
    uint16_t desired = 256;
    while(desired >= bound) {
        desired = [self nextByteFromBuffer] % actual_bound;
    }
    return desired;
}

@end
