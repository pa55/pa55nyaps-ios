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
//  LabelledTextTableViewCell.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/8/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "LabelledTextTableViewCell.h"

@interface LabelledTextTableViewCell()
@property (nonatomic, strong) NSString *lastKnownValidValue;
@end

@implementation LabelledTextTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [_cellTextField addTarget:self action:@selector(validateTextField:) forControlEvents:UIControlEventEditingDidEnd];
}

- (void) validateTextField:(id) sender {
    if([sender isKindOfClass:[UITextField class]]) {
        UITextField *tf = sender;
        if(_validationRegex) {
            BOOL match = ([_validationRegex matchesInString:tf.text options:0 range:NSMakeRange(0, tf.text.length)].count >= 1);
            if(match) {
                _lastKnownValidValue = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            [_navigationItemReference setHidesBackButton:!match animated:YES];
        }
        else {
            _lastKnownValidValue = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    _cellTextField.delegate = self;
}

- (void) setValue:(NSString *)value {
    _cellTextField.text = value;
    _lastKnownValidValue = [NSString stringWithString:value];
}

- (NSString *) value {
    return _lastKnownValidValue;
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [_textFieldDelegate textFieldDidEndEditing:textField];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_textFieldDelegate textFieldDidBeginEditing:textField];
}

@end
