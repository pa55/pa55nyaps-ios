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
//  AESCryptosystem.m
//  pa55v2
//
//  Created by Anirban Basu on 7/27/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import "AESCryptosystem.h"
#import "PBKDF2StreamGenerator.h"

@implementation AESCryptosystem

- (NSData*) generateRandomDataOfSize:(NSUInteger) size {
    uint8_t randomBytes[size];
    int result = SecRandomCopyBytes(kSecRandomDefault, size, randomBytes);
    if(result!=0) {
        [NSException raise:NSLocalizedString(lcAESCryptosystemGenerateRandomDataFailTitle, nil) format:NSLocalizedString(lcAESCryptosystemGenerateRandomDataFail, nil), size];
    }
    return [NSData dataWithBytes:randomBytes length:size];
}


- (Ciphertext *) encryptWithHmac: (NSString *) inputString password: (NSString *) password {
    Ciphertext *result = [[Ciphertext alloc] init];
    NSData *encrypted = nil;
    NSData *data = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    
    NSData *salt = [self generateRandomDataOfSize:kSaltSize];
    NSData *iv = [self generateRandomDataOfSize:kIvSize];
    
    NSData *concatenatedKeys = [PBKDF2StreamGenerator generateStreamWithPassword:[password dataUsingEncoding:NSUTF8StringEncoding] salt:salt length:(kKeySize + kHmacKeySize)];
    
    NSData *encryptionKey = [concatenatedKeys subdataWithRange:NSMakeRange(0, kKeySize)];
    NSData *hmacKey = [concatenatedKeys subdataWithRange:NSMakeRange(kKeySize, kHmacKeySize)];
    
    //Create Cryptor
    CCCryptorRef cryptor = NULL;
    
    CCCryptorStatus  create = CCCryptorCreateWithMode(kCCEncrypt, kCCModeCTR, kCCAlgorithmAES, ccNoPadding, iv.bytes, encryptionKey.bytes, encryptionKey.length, NULL, 0, 0, kCCModeOptionCTR_BE, &cryptor);
    
    if(create != kCCSuccess){
        [NSException raise:NSLocalizedString(lcAESCryptosystemCryptorFailTitle, nil) format:NSLocalizedString(lcAESCryptosystemEncryptCryptorFail, nil)];
    }
    
    //alloc number of bytes written to data Out
    size_t outLength;
    NSMutableData *cipherData = [NSMutableData dataWithLength:data.length /*+ kCCBlockSizeAES128*/];
    
    //Update Cryptor
    CCCryptorStatus  update = CCCryptorUpdate(cryptor,
                                              data.bytes,
                                              data.length,
                                              cipherData.mutableBytes,
                                              cipherData.length,
                                              &outLength);
    
    if (update == kCCSuccess) {
        //Cut Data Out with needed length
        cipherData.length = outLength;
        
        //Final Cryptor
        CCCryptorStatus final = CCCryptorFinal(cryptor, //CCCryptorRef cryptorRef,
                                               cipherData.mutableBytes, //void *dataOut,
                                               cipherData.length, // size_t dataOutAvailable,
                                               &outLength); // size_t *dataOutMoved)
        
        if (final == kCCSuccess) {
            encrypted = [NSData dataWithBytes:cipherData.bytes length:cipherData.length];
            NSMutableData *concatenatedHmacData = [NSMutableData data];
            [concatenatedHmacData appendData:salt];
            [concatenatedHmacData appendData:iv];
            [concatenatedHmacData appendData:encrypted];
            CCHmac(kCCHmacAlgSHA256, hmacKey.bytes, hmacKey.length, concatenatedHmacData.bytes, concatenatedHmacData.length, cHMAC);
        }
        else {
            [NSException raise:NSLocalizedString(lcAESCryptosystemCryptorFailTitle, nil) format:NSLocalizedString(lcAESCryptosystemEncryptFail, nil), final];
        }
    }
    else {
        [NSException raise:NSLocalizedString(lcAESCryptosystemCryptorFailTitle, nil) format:NSLocalizedString(lcAESCryptosystemEncryptFail, nil), update];
    }
    
    NSData *hmacData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    if(result!=nil) {
        result.salt = [salt base64EncodedStringWithOptions:0];
        result.iv = [iv base64EncodedStringWithOptions:0];
        result.ciphertext = [encrypted base64EncodedStringWithOptions:0];
        result.hmac = [hmacData base64EncodedStringWithOptions:0];
        result.keySize = kKeySize;
        result.saltSize = kSaltSize;
        result.ivSize = kIvSize;
        result.hmacKeySize = kHmacKeySize;
    }
    
    CCCryptorRelease(cryptor); //CCCryptorRef cryptorRef
    
    return  result;
}

- (NSString *) decryptWithHmac: (Ciphertext *) ciphertext password: (NSString *) password {
    //NSLog(@"About to decrypt: %@", [[ciphertext dictionary] description]);
    NSData *decrypted = nil;
    
    //char keyPtr [ kCCKeySizeAES128 +1 ];
    //bzero( keyPtr, sizeof(keyPtr) );
    
    NSData *salt = [[NSData alloc] initWithBase64EncodedString:ciphertext.salt options:0];
    NSData *iv = [[NSData alloc] initWithBase64EncodedString:ciphertext.iv options:0];
    NSData *encyptedData = [[NSData alloc] initWithBase64EncodedString:ciphertext.ciphertext options:0];
    
    
    NSData *concatenatedKeys = [PBKDF2StreamGenerator generateStreamWithPassword:[password dataUsingEncoding:NSUTF8StringEncoding] salt:salt length:(ciphertext.keySize + ciphertext.hmacKeySize)];
    NSData *decryptionKey = [concatenatedKeys subdataWithRange:NSMakeRange(0, ciphertext.keySize)];
    NSData *hmacKey = [concatenatedKeys subdataWithRange:NSMakeRange(ciphertext.keySize, ciphertext.hmacKeySize)];
    
    if([ciphertext.hmac length]>0) {
        //verify hmac
        unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
        NSMutableData *concatenatedHmacData = [NSMutableData data];
        [concatenatedHmacData appendData:salt];
        [concatenatedHmacData appendData:iv];
        [concatenatedHmacData appendData:encyptedData];
        CCHmac(kCCHmacAlgSHA256, hmacKey.bytes, hmacKey.length, concatenatedHmacData.bytes, concatenatedHmacData.length, cHMAC);
        NSData *hmacData = [NSData dataWithBytes:cHMAC length:CC_SHA256_DIGEST_LENGTH];
        NSString *hmacString = [hmacData base64EncodedStringWithOptions:0];
        //NSLog(@"Computed HMAC %@. Original HMAC: %@, hmac key length: %d, key size: %d", hmacString, ciphertext.hmac, ciphertext.hmacKeySize, ciphertext.keySize);
        if(![hmacString isEqualToString:ciphertext.hmac]) {
            [NSException raise:NSLocalizedString(lcAESCryptosystemDecryptHmacFailTitle, nil) format:NSLocalizedString(lcAESCryptosystemDecryptHmacFail, nil)];
        }
    }
    
    // Init cryptor
    CCCryptorRef cryptor = NULL;
    
    // Create Cryptor
    CCCryptorStatus createDecrypt = CCCryptorCreateWithMode(kCCDecrypt, // operation
                                                            kCCModeCTR, // mode CTR
                                                            kCCAlgorithmAES, // Algorithm
                                                            ccNoPadding, // padding
                                                            iv.bytes, // can be NULL, because null is full of zeros
                                                            decryptionKey.bytes, // key
                                                            decryptionKey.length, // keylength
                                                            NULL, //const void *tweak
                                                            0, //size_t tweakLength,
                                                            0, //int numRounds,
                                                            kCCModeOptionCTR_BE, //CCModeOptions options,
                                                            &cryptor); //CCCryptorRef *cryptorRef
    
    
    if (createDecrypt != kCCSuccess) {
        [NSException raise:NSLocalizedString(lcAESCryptosystemCryptorFailTitle, nil) format:NSLocalizedString(lcAESCryptosystemDecryptCryptorFail, nil)];
    }
    // Alloc Data Out
    NSMutableData *cipherDataDecrypt = [NSMutableData dataWithLength:encyptedData.length /*+ kCCBlockSizeAES128*/];
    
    //alloc number of bytes written to data Out
    size_t outLengthDecrypt;
    
    //Update Cryptor
    CCCryptorStatus updateDecrypt = CCCryptorUpdate(cryptor,
                                                    encyptedData.bytes, //const void *dataIn,
                                                    encyptedData.length,  //size_t dataInLength,
                                                    cipherDataDecrypt.mutableBytes, //void *dataOut,
                                                    cipherDataDecrypt.length, // size_t dataOutAvailable,
                                                    &outLengthDecrypt); // size_t *dataOutMoved)
    
    if (updateDecrypt != kCCSuccess) {
        [NSException raise:NSLocalizedString(lcAESCryptosystemCryptorFailTitle, nil) format:NSLocalizedString(lcAESCryptosystemDecryptFail, nil), updateDecrypt];
    }
    
    
    //Cut Data Out with needed length
    cipherDataDecrypt.length = outLengthDecrypt;
        
        
    //Final Cryptor
    updateDecrypt = CCCryptorFinal(cryptor, //CCCryptorRef cryptorRef,
                                           cipherDataDecrypt.mutableBytes, //void *dataOut,
                                           cipherDataDecrypt.length, // size_t dataOutAvailable,
                                           &outLengthDecrypt); // size_t *dataOutMoved)
    
    if (updateDecrypt != kCCSuccess) {
        [NSException raise:NSLocalizedString(lcAESCryptosystemCryptorFailTitle, nil) format:NSLocalizedString(lcAESCryptosystemDecryptFail, nil), updateDecrypt];
    }
    
    decrypted = [NSData dataWithBytes:cipherDataDecrypt.bytes length:cipherDataDecrypt.length];
    
    CCCryptorRelease(cryptor); //CCCryptorRef cryptorRef
    
    
    return [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
}

@end
