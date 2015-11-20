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
//  LabelledLabelTableViewCell.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/11/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "LabelledLabelTableViewCell.h"

@implementation LabelledLabelTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setValue:(NSString *)value {
    _cellDetailedLabel.text = value;
}

- (NSString *) value {
    return _cellDetailedLabel.text;
}

@end
