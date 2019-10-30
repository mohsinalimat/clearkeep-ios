/*
 Copyright 2015 OpenMarket Ltd

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

#import "MXKSampleJSQRoomBubbleCellData.h"

#import "MXKSampleJSQMessageMediaData.h"

@implementation MXKSampleJSQRoomBubbleCellData

#pragma mark - JSQMessageData

- (BOOL)isMediaMessage
{
    // For now, support only image as media
    return (self.attachment && self.attachment.type == MXKAttachmentTypeImage);
}

- (NSUInteger)messageHash
{
    return self.hash;
}

- (NSString *)text
{
    return self.attributedTextMessage.string;
}

- (id<JSQMessageMediaData>)media
{
    return [[MXKSampleJSQMessageMediaData alloc] initWithCellData:self];
}

@end
