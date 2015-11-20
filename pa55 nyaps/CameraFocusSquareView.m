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
//  CameraFocusSquareView.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/25/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

//Modified from http://stackoverflow.com/a/30879978/681233

#import "CameraFocusSquareView.h"

@implementation CameraFocusSquareView {
    CABasicAnimation *_selectionBlink;
}

/**
 This is the init method for the square. It sets the frame for the view and sets border parameters. It also creates the blink animation.
 */
- (instancetype)initWithTouchPoint:(CGPoint)touchPoint {
    self = [self init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1.0f;
        
        [self updatePoint:touchPoint];
    }
    return self;
}

/**
 Updates the location of the view based on the incoming touchPoint.
 */
- (void)updatePoint:(CGPoint)touchPoint {
    [self.layer removeAnimationForKey:@"selectionAnimation"];
    CGFloat squareWidth = 70.0;
    CGRect frame = CGRectMake(touchPoint.x - squareWidth/2, touchPoint.y - squareWidth/2, squareWidth, squareWidth);
    self.frame = frame;
    [self animateFocusingAction];
}

/**
 This unhides the view and initiates the animation by adding it to the layer.
 */
- (void)animateFocusingAction {
    // create the blink animation
    self.layer.borderColor = [UIColor orangeColor].CGColor;
    _selectionBlink = [CABasicAnimation
                       animationWithKeyPath:@"borderColor"];
    _selectionBlink.toValue = (id)[UIColor whiteColor].CGColor;
    _selectionBlink.repeatCount = 4;  // number of blinks
    _selectionBlink.duration = 0.25;  // this is duration per blink
    _selectionBlink.delegate = self;
    // make the view visible
    self.alpha = 1.0f;
    self.hidden = NO;
    // initiate the animation
    [self.layer addAnimation:_selectionBlink forKey:@"selectionAnimation"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    // hide the view
    self.alpha = 0.0f;
    self.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
