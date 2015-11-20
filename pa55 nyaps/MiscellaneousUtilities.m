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
//  MiscellaneousUtilities.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/14/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "MiscellaneousUtilities.h"

@interface MiscellaneousUtilities()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation MiscellaneousUtilities

+ (instancetype) defaultInstance {
    static MiscellaneousUtilities *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.dateFormatter = [[NSDateFormatter alloc] init];
        [sharedInstance.dateFormatter setDateFormat:NSLocalizedString(lcAppDateTimeFormat, nil)];
    });
    return sharedInstance;
}

- (NSString *) appFormattedDateStringFrom:(NSDate *) date {
    return [_dateFormatter stringFromDate:date];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
