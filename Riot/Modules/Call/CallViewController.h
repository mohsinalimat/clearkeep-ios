/*
 Copyright 2016 OpenMarket Ltd
 
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

#import <MatrixKit/MatrixKit.h>

/**
 'CallViewController' instance displays a call. Only one matrix session is supported by this view controller.
 */
@interface CallViewController : MXKCallViewController

@property (weak, nonatomic) IBOutlet UIView *gradientMaskContainerView;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *sideChatButton;
@property (weak, nonatomic) IBOutlet UILabel *smallTimeLabel;

@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *callerImageViewWidthConstraint;

//CK
- (void)setMxCall:(MXCall *)call;

@end
