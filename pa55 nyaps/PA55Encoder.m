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
//  PA55Encoder.m
//  pa55v2
//
//  Created by Anirban Basu on 6/28/15.
//  Copyright (c) 2015 Anirban Basu. All rights reserved.
//

#import "PA55Encoder.h"
#import "CharacterTypeCount.h"
#import "UserPreference.h"
#import "NYAPSCore.h"

@implementation PA55Encoder {
    NSString *_assignedUserCharset;
}

- (instancetype) initWithCharsets {
    self = [[PA55Encoder alloc] init];
    if(self) {
        _shuffleSeed = 0;
        _charsets = [[NSMutableDictionary alloc] init];
        [_charsets setObject:kCharTypeLowercase forKey:@(lowercase)];
        [_charsets setObject:kCharTypeUppercase forKey:@(uppercase)];
        [_charsets setObject:kCharTypeDigits forKey:@(digits)];
        [_charsets setObject:kCharTypeSpecial forKey:@(special)];
        [_charsets setObject:kCharTypeBrackets forKey:@(brackets)];
        _userPreferences = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void) setUserPreferences:(NSMutableArray *)userPreferences {
    //userPreferences = [PA55Encoder userPreferencesSortedByCharacterType:userPreferences];
    
    //PRINT the caller function
    /*
    void *addr[2];
    int nframes = backtrace(addr, sizeof(addr)/sizeof(*addr));
    if (nframes > 1) {
        char **syms = backtrace_symbols(addr, nframes);
        NSLog(@"%s: caller: %s", __func__, syms[1]);
        free(syms);
    } else {
        NSLog(@"%s: *** Failed to generate backtrace.", __func__);
    }
    */
    
    [_userPreferences removeAllObjects]; //clear
    //check for duplicates
    NSMutableDictionary *seen = [[NSMutableDictionary alloc] init];
    for(int i=0; i<userPreferences.count; i++) {
        UserPreference *up = [userPreferences objectAtIndexedSubscript:i];
        if(up.include) {
            if([seen objectForKey:@(up.characterType)] == nil) {
                [_userPreferences addObject:up];
                [seen setObject:@(up.include) forKeyedSubscript:@(up.characterType)];
            }
        }
    }
    _userPreferences = [PA55Encoder userPreferencesSortedByCharacterType:_userPreferences];
    //_userPreferences = [self shuffleList:_userPreferences];
}

- (NSString*) shuffleString:(NSString*) data withSeed: (NSData *) seed {
    if(seed.length == kCCKeySizeAES128) {
        AESDRBG* random = [[AESDRBG alloc] initWithRawSeed:seed];
        unichar *buffer = calloc(data.length, sizeof (unichar));
        [data getCharacters:buffer];
        uint32_t n = (uint32_t) data.length;
        while(n>1) {
            uint32_t k = [random nextInt:n--];
            //NSLog(@"Random number: %d", k);
            unichar t = buffer[n];
            buffer[n] = buffer[k];
            buffer[k] = t;
        }
        NSString *result = [NSString stringWithCharacters:buffer length:data.length];
        free(buffer);
        return result;
    }
    else {
        return data;
    }
}

- (NSString *) removeCharactersFrom:(NSString *) from in:(NSString *) source {
    NSMutableString* result = [[NSMutableString alloc] init];
    for(int i=0; i<from.length; i++) {
        unichar c = [from characterAtIndex:i];
        NSString *formattedStr = [NSString stringWithFormat:@"%C", c];
        if(![source containsString:formattedStr]) {
            [result appendString:formattedStr];
        }
    }
    return result;
}

- (bool) assignUserCharacterSet:(NSString *) characters {
    if(characters!=nil) {
        NSMutableString *charsetsConcatenated = [[NSMutableString alloc] init];
        
        [charsetsConcatenated appendString:kCharTypeLowercase];
        [charsetsConcatenated appendString:kCharTypeUppercase];
        [charsetsConcatenated appendString:kCharTypeDigits];
        [charsetsConcatenated appendString:kCharTypeSpecial];
        [charsetsConcatenated appendString:kCharTypeBrackets];
        
        
        NSString *userCharacters = [self removeCharactersFrom:characters in:charsetsConcatenated];
        if(userCharacters.length>0) {
            _assignedUserCharset = userCharacters;
            [_charsets setObject:_assignedUserCharset forKey:@(user)];
            //NSLog(@"User charset: %@", _assignedUserCharset);
            return true;
        }
    }
    return false;
}

+ (NSMutableArray *) characterTypeCountsSortedByCounts:(NSMutableArray *) data {
    //in-place sort
    [data sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CharacterTypeCount *o1 = obj1;
        CharacterTypeCount *o2 = obj2;
        return o1.count - o2.count;
    }];
    return data;
}

+ (NSMutableArray *) userPreferencesSortedByCharacterType:(NSMutableArray *) data {
    //in-place sort
    [data sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UserPreference *o1 = obj1;
        UserPreference *o2 = obj2;
        return o1.characterType - o2.characterType;
    }];
    return data;
}

+ (NSString*)charTypeToString:(CharacterType)charType {
    NSString *result = nil;
    
    switch(charType) {
        case brackets:
            result = @"brackets";
            break;
        case digits:
            result = @"digits";
            break;
        case lowercase:
            result = @"lowercase";
            break;
        case special:
            result = @"special";
            break;
        case uppercase:
            result = @"uppercase";
            break;
        case user:
            result = @"user";
            break;
        default:
            break;
    }
    return result;
}

+ (CharacterType)stringToCharType:(NSString *)charType {
    CharacterType result;
    
    if([charType isEqualToString:@"brackets"]) {
        result = brackets;
    }
    else if([charType isEqualToString:@"digits"]) {
        result = digits;
    }
    else if([charType isEqualToString:@"lowercase"]) {
        result = lowercase;
    }
    else if([charType isEqualToString:@"special"]) {
        result = special;
    }
    else if([charType isEqualToString:@"uppercase"]) {
        result = uppercase;
    }
    else if([charType isEqualToString:@"brackets"]) {
        result = user;
    }
    else {
        return brackets-1; //brackets has the lowest index, so 1 below it will be deemed as invalid
    }
    return result;
}

- (NSString *) encodeData: (NSData *) randomSeeds outputLength:(NSUInteger) length {
    NSMutableString *intermediate = [[NSMutableString alloc] init]; //intermediate password string
    NSMutableString *concatenatedCharsets = [[NSMutableString alloc] init];
    int byteOffset = kCCKeySizeAES128;
    //first keySize bits
    NSData *characterSelectorSeed = [randomSeeds subdataWithRange:NSMakeRange(0, byteOffset)];
    //second keySize bits
    NSData *shuffleSeed = [randomSeeds subdataWithRange:NSMakeRange(byteOffset, byteOffset)];
    //character type indices cumulative count
    NSMutableArray *typeIndexCounts = [[NSMutableArray alloc] init];
    //current maximum constraints for each character types
    NSMutableDictionary *typeMaximumCounts = [[NSMutableDictionary alloc] init];
    //sum of maximum constraints
    int sumOfMaximumConstraints = 0; //set this to -1 to ignore under allocation check

    //AES deterministic random bits generator
    AESDRBG *characterSelector = [[AESDRBG alloc] initWithRawSeed:characterSelectorSeed];
    //Satisfy the minimum constraints
    for(int i=0; i<_userPreferences.count; i++) {
        UserPreference *up = [_userPreferences objectAtIndex:i];
        if(up.minimum > 0) {
            NSString *charset = [_charsets objectForKey:@(up.characterType)];
            [concatenatedCharsets appendString:charset];
            //set the end index (cumulative indices) for each character type
            [typeIndexCounts addObject:[[CharacterTypeCount alloc] initWithCharacterType:up.characterType count:concatenatedCharsets.length]];
            //set the maximum counts to expected minimum constraints for each character type
            [typeMaximumCounts setObject:[NSNumber numberWithInteger:up.minimum] forKey:@(up.characterType)];
            //sum the maximum constraints to check for under allocation
            if(up.minimum <= up.maximum && sumOfMaximumConstraints!=-1) {
                sumOfMaximumConstraints += up.maximum;
            }
            else if(up.maximum < 0) {
                sumOfMaximumConstraints = -1;
            }
            //pick until minimum constraint is satisfied
            for(int minConstraint = 0; minConstraint < up.minimum; minConstraint++) {
                int pos = [characterSelector nextByte:(uint16_t) charset.length]; //[characterSelector nextInt:(uint32_t)charset.length];
                //NSLog(@"%d", pos);
                [intermediate appendString:[NSString stringWithFormat:@"%C", [charset characterAtIndex:pos]]];
            }
        }
    }
    
    //Check for over allocation: required length is too small to accommodate the minimum allowed characters
    if(intermediate.length > length) {
        [NSException raise:NSLocalizedString(lcNYAPSCoreExceptionTitle, nil) format:NSLocalizedString(lcPA55EncoderExceptionPasswordLengthTooShort, nil), (unsigned long)length];
    }
    
    //Check for under allocation: required length is too long to accommodate the maximum allowed characters
    if(sumOfMaximumConstraints > 0 && sumOfMaximumConstraints < length) {
        [NSException raise:NSLocalizedString(lcNYAPSCoreExceptionTitle, nil) format:NSLocalizedString(lcPA55EncoderExceptionPasswordLengthTooLong, nil), (unsigned long)length];
    }
    
    //Keep picking characters at random, satisfying maximum constraints if any
    while(intermediate.length < length) {
        //pick the next position to select a character from the concatenated character set
        int position = [characterSelector nextByte:(uint16_t) concatenatedCharsets.length]; //[characterSelector nextInt:(uint32_t)concatenatedCharsets.length];
        UserPreference *prefForCharTypeAtSelectedPosition = nil;
        CharacterType positionPickedType = -1; //unset
        //Determine the character type for the character at the selected position
        for(int i=0; i<typeIndexCounts.count; i++) {
            CharacterTypeCount *ctc = [typeIndexCounts objectAtIndex:i];
            if(position < ctc.count) {
                positionPickedType = ctc.characterType;
                break;
            }
        }
        //This is really not supposed to happen!
        if([@(positionPickedType) intValue] == -1) { //check for an unset value
            [NSException raise:NSLocalizedString(lcNYAPSCoreExceptionTitle, nil) format:NSLocalizedString(lcPA55EncoderExceptionUnknownCharacterType, nil)];
        }
        //find the corresponding user preference
        for(int i=0; i<_userPreferences.count; i++) {
            UserPreference *up = [_userPreferences objectAtIndex:i];
            if(up.characterType == positionPickedType) {
                prefForCharTypeAtSelectedPosition = up;
            }
        }
        //This is really not supposed to happen either!
        if(prefForCharTypeAtSelectedPosition == nil) {
            [NSException raise:NSLocalizedString(lcNYAPSCoreExceptionTitle, nil) format:NSLocalizedString(lcPA55EncoderExceptionUnknownPreferencesType, nil)];
        }
        //If the minimum constraint is less than or equal to the maximumConstraint, otherwise ignore maximum constraints
        if(prefForCharTypeAtSelectedPosition.minimum <= prefForCharTypeAtSelectedPosition.maximum) {
            //Find or set, if necessary, the current number of counts for the selected character type
            NSInteger maxCount = [[typeMaximumCounts objectForKey:@(positionPickedType)] integerValue];
            //Pick a character unless the maximum constraints for this type of characters has been satisfied
            if(maxCount < prefForCharTypeAtSelectedPosition.maximum) {
                [intermediate appendString:[NSString stringWithFormat:@"%C", [concatenatedCharsets characterAtIndex:position]]];
                maxCount++;
            }
            //update the current maximum counts for this character type
            [typeMaximumCounts setObject:[NSNumber numberWithInteger:maxCount] forKey:@(positionPickedType)];
        }
        else {
            [intermediate appendString:[NSString stringWithFormat:@"%C", [concatenatedCharsets characterAtIndex:position]]];
        }
    }
    
    return [self shuffleString:intermediate withSeed:shuffleSeed];
}

@end
