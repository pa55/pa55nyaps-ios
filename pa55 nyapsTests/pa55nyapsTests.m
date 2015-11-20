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
//  pa55nyapsUnitTests.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/19/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NYAPSCore.h"
#import "UserPreference.h"
#import "PA55Encoder.h"

@interface pa55nyapsUnitTests : XCTestCase

@end

@implementation pa55nyapsUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAESRandomGenerator {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSString *rawSeedString = @"0123456789abcdef"; //16 bytes string
    AESDRBG *byteDRBG = [[AESDRBG alloc] initWithRawSeed:[rawSeedString dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray<NSNumber *> *expectedBytes = [NSArray arrayWithObjects:@(11), @(27), @(21), @(26), @(11), @(4), @(0), nil];
    NSMutableArray<NSNumber *> *resultBytes = [[NSMutableArray alloc] init];
    for(int i = 255; i>2;) {
        uint8_t byte = [byteDRBG nextByte:i];
        [resultBytes addObject:@(byte)];
        i = ((i+1)>>1) - 1;
    }
    XCTAssertEqualObjects(expectedBytes, resultBytes, @"The DRBG did not generate the expected sequence of bytes.");
    
    AESDRBG *intDRBG = [[AESDRBG alloc] initWithRawSeed:[rawSeedString dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray<NSNumber *> *expectedInts = [NSArray arrayWithObjects:@(194713050),@(189047029),@(85839812),@(132172331),@(28331064),@(6743273),@(9491039),@(5022996),@(2239045),@(1405757),@(618064),@(247678),@(147778),@(111950),@(48067),@(24523),@(13443),@(1503),@(67),@(1206),@(605),@(279),@(43),@(34),@(17),@(2),@(5),@(3),@(0), nil];
    NSMutableArray<NSNumber *> *resultInts = [[NSMutableArray alloc] init];
    for(int i = (1<<30)-1; i>2;) {
        [resultInts addObject:@([intDRBG nextInt:i])];
        i = ((i+1)>>1) - 1;
    }
    XCTAssertEqualObjects(expectedInts, resultInts, @"The DRBG did not generate the expected sequence of integers.");
}

- (NSMutableArray<UserPreference *> *) createUserPreferences {
    NSMutableArray<UserPreference *> *prefs = [[NSMutableArray alloc] init];
    [prefs addObject:[[UserPreference alloc] initWithCharacterType:brackets minimum:1]];
    [prefs addObject:[[UserPreference alloc] initWithCharacterType:digits minimum:1]];
    [prefs addObject:[[UserPreference alloc] initWithCharacterType:lowercase minimum:1]];
    [prefs addObject:[[UserPreference alloc] initWithCharacterType:special minimum:1]];
    [prefs addObject:[[UserPreference alloc] initWithCharacterType:uppercase minimum:1]];
    return prefs;
}

- (void)testNYAPSConsistencyAndPerformance {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        NSString *pwd = [NYAPSCore generateAESDRBGPasswordWithPhrase:@"hello world" hint:@"test" length:32 userPreferences:[self createUserPreferences] userCharset:nil];
        NSString *expected = @"dQ#gkSB{=xo$1<Gn0)v*&6BA9BG(RpA{";
        XCTAssertEqualObjects(expected, pwd, @"NYAPS core did not generate the expected password.");
    }];
}

@end
