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
//  GlobalEnums.h
//  pa55 nyaps
//
//  Created by Anirban Basu on 12/2/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#ifndef GlobalEnums_h
#define GlobalEnums_h


typedef NS_ENUM(NSInteger, CharacterType) {
    brackets = 0,
    digits,
    lowercase,
    special,
    uppercase,
    user,
    character_type_count
};


#endif /* GlobalEnums_h */
