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
//  LabelledStepperTableViewCell.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/11/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "LabelledStepperTableViewCell.h"

@interface LabelledStepperTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *cellStepperValueLabel;

@end

@implementation LabelledStepperTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
    [_cellStepper addTarget:_stepperDelegate action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void) setValue:(double)value {
    _cellStepper.value = value;
    [self updateValueLabel];
}

- (double) value {
    return _cellStepper.value;
}

- (void) updateValueLabel {
    if(_floatingPointValue) {
        _cellStepperValueLabel.text = [NSString stringWithFormat:@"%f", _cellStepper.value];
    }
    else {
        _cellStepperValueLabel.text = [NSString stringWithFormat:@"%ld", (long)_cellStepper.value];
    }
}

- (IBAction)stepperValueChanged:(id)sender {
    [self updateValueLabel];
}

@end
