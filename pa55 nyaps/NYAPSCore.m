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
//  NYAPSCore.m
//  pa55v2
//
//  Created by Anirban Basu on 7/3/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import "NYAPSCore.h"

@implementation NYAPSCore


+ (NSString *) generateAESDRBGPasswordWithPhrase:(NSString *) phrase hint: (NSString *) hint length:(NSUInteger) length userPreferences:(NSMutableArray<UserPreference *> *) userPreferences userCharset: (NSString *) userCharset {
    //NSDate *methodStart = [NSDate date];
    PA55Encoder *encoder = [[PA55Encoder alloc] initWithCharsets];
    
    if(userCharset!=nil) {
        NSString *trimmed = [userCharset stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(trimmed.length > 0) {
            if([encoder assignUserCharacterSet:trimmed]) {
                [userPreferences addObject:[[UserPreference alloc] initWithCharacterType:user minimum:1]];
            }
        }
        
    }
    
    if([userPreferences count]==0) {
        [NSException raise:NSLocalizedString(lcNYAPSCoreExceptionTitle, nil) format:NSLocalizedString(lcNYAPSCoreExceptionCharTypeChoiceRequired, nil)];
    }
    if(phrase.length==0) {
        [NSException raise:NSLocalizedString(lcNYAPSCoreExceptionTitle, nil) format:NSLocalizedString(lcNYAPSCoreExceptionMasterSecretEmpty, nil)];
    }
    if(hint.length==0) {
        [NSException raise:NSLocalizedString(lcNYAPSCoreExceptionTitle, nil) format:NSLocalizedString(lcNYAPSCoreExceptionPasswordHintEmpty, nil)];
    }
    if(length<=0) {
        [NSException raise:NSLocalizedString(lcNYAPSCoreExceptionTitle, nil) format:NSLocalizedString(lcNYAPSCoreExceptionDesiredLengthInvalid, nil)];
    }
    
    //must set it here, not later, to enforce consistent ordering of the user preferences
    encoder.userPreferences = userPreferences;
    
    NSMutableString *concatenatedCharSequence = [[NSMutableString alloc] init];
    
    
    for(int i=0; i<encoder.userPreferences.count; i++) {
        UserPreference *up = [encoder.userPreferences objectAtIndex:i];
        if(up.minimum > 0) {
            NSString *selectedCharset = [encoder.charsets objectForKey:@(up.characterType)];
            [concatenatedCharSequence appendString:selectedCharset];
        }
    }
    
    NSMutableString *mutableHint = [hint mutableCopy];
    [mutableHint appendString:[NSString stringWithFormat:@"%lu%@", (unsigned long)length, concatenatedCharSequence]];
    
    NSData *hPass = [PBKDF2StreamGenerator generateStreamWithPassword:[phrase dataUsingEncoding:NSUTF8StringEncoding] salt:[mutableHint dataUsingEncoding:NSUTF8StringEncoding] length:kCCKeySizeAES128*2];
    
    //NSLog(@"hPass: %@", [hPass base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]);
    NSString* result = [encoder encodeData:hPass outputLength:length];
    //NSDate *methodFinish = [NSDate date];
    //NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    //NSLog(@"executionTime = %f", executionTime);
    return result;
}

+ (void) testNYAPSCore {
    /*BEGIN: test code */
    NSMutableArray<UserPreference *> *userPreferences = [[NSMutableArray alloc] init];
    [userPreferences addObject:[[UserPreference alloc] initWithCharacterType:brackets minimum:1]];
    [userPreferences addObject:[[UserPreference alloc] initWithCharacterType:digits minimum:1]];
    [userPreferences addObject:[[UserPreference alloc] initWithCharacterType:lowercase minimum:1]];
    [userPreferences addObject:[[UserPreference alloc] initWithCharacterType:special minimum:1]];
    [userPreferences addObject:[[UserPreference alloc] initWithCharacterType:uppercase minimum:1]];
    
    
    int minLength = 269, maxLength = 270;
    NSString *phrase = @"my test master secret sentence";
    NSString *hint = @"ServiceName=facebook;ServiceLink=http://www.facebook.com;UserID=myself;AdditionalInfo=nothing1"; //the last '1' indicates issue number
    
    for(int i=minLength; i<=maxLength; ++i) {
        printf("Password (%d chars): %s\n", i, [[NYAPSCore generateAESDRBGPasswordWithPhrase:phrase hint:hint length:i userPreferences:userPreferences userCharset:nil] UTF8String]);
    }
    
    
    AESDRBG *drbg = [[AESDRBG alloc] initWithRawSeed:[@"0123456789abcdef" dataUsingEncoding:NSUTF8StringEncoding]];
    for(int i=(1<<30) - 1; i>2 ;) {
        printf("%d\n", [drbg nextInt:i]);
        i = ((i + 1)>>1) - 1;
    }
    drbg = [[AESDRBG alloc] initWithRawSeed:[@"0123456789abcdef" dataUsingEncoding:NSUTF8StringEncoding]];
    for(int i=255; i>2 ; i--) {
        printf("%d\n", [drbg nextByte:i]);
    }
    
    
    /*END: test code*/
}

@end
