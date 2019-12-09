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

#import <MatrixKit/MatrixKit.h>

/**
 Action identifier used when the user pressed edit button displayed in front of a selected event.
 
 The `userInfo` dictionary contains an `MXEvent` object under the `kMXKRoomBubbleCellEventKey` key, representing the selected event.
 */
extern NSString *const kMXKRoomBubbleCellRiotEditButtonPressed;

/**
 Action identifier used when the user tapped on receipts area.
 
 The 'userInfo' disctionary contains an 'MXKReceiptSendersContainer' object under the 'kMXKRoomBubbleCellReceiptsContainerKey' key, representing the receipts container which was tapped on.
 */
extern NSString *const kMXKRoomBubbleCellTapOnReceiptsContainer;

/**
 Define a `MXKRoomBubbleTableViewCell` category at Riot level to handle bubble customisation.
 */
@interface MXKRoomBubbleTableViewCell (Riot)

/**
 Add timestamp label for a component in receiver.
 
 Note: The label added here is automatically removed when [didEndDisplay] is called.
 
 @param componentIndex index of the component in bubble message data
 */
- (void)addTimestampLabelForComponent:(NSUInteger)componentIndex;

/**
 Highlight a component in receiver.
 
 @param componentIndex index of the component in bubble message data
 */
- (void)selectComponent:(NSUInteger)componentIndex;

/**
 Highlight a component in receiver and show or not edit button.
 
 @param componentIndex index of the component in bubble message data
 @param showEditButton true to show edit button
 @param showTimestamp true to show timestamp label
 */
- (void)selectComponent:(NSUInteger)componentIndex showEditButton:(BOOL)showEditButton showTimestamp:(BOOL)showTimestamp;

/**
 Mark a component in receiver.

 @param componentIndex index of the component in bubble message data
 */
- (void)markComponent:(NSUInteger)componentIndex;

/**
 Add a label to display the date of the cell.
 */
- (void)addDateLabel:(BOOL)timeOnly;

/**
Using custom formatter.
*/
- (void)updateEventFormatter;

/**
 Called when the user taps on the Receipt Container.
 */
- (IBAction)onReceiptContainerTap:(UITapGestureRecognizer *)sender;

/**
 Blur the view by adding a transparent overlay. Default is NO.
 */
@property(nonatomic) BOOL blurred;

/**
 The 'edit' button displayed at in the top-right corner of the selected component (if any). Default is nil.
 */
@property(nonatomic) UIButton *editButton;

/**
 The marker view displayed in front of the marked component (if any).
 */
@property (nonatomic) UIView *markerView;



/**
 Calculate component frame in table view.
 
 @param componentIndex index of the component in bubble message data
 @return component frame in table view if component exist or CGRectNull.
 */
- (CGRect)componentFrameInTableViewForIndex:(NSInteger)componentIndex;

/**
 Calculate surrounding component frame in table view. This frame goes over user name for first visible component for example.
 
 @param componentIndex index of the component in bubble message data
 @return Component surrounding frame in table view if component exist or CGRectNull.
 */
- (CGRect)surroundingFrameInTableViewForComponentIndex:(NSInteger)componentIndex;

/**
 Calculate the component frame in the contentView of the tableview cell.
 
 @param componentIndex index of the component in bubble message data
 @return component frame in the contentView if the component exists or CGRectNull.
 */
- (CGRect)componentFrameInContentViewForIndex:(NSInteger)componentIndex;

/**
 Give the correct cell height for a bubble cell with an attachment view. Handle reactions and read receipts views.
 
 @param cellData The data object to render.
 @param maxWidth The maximum available width.
 @return The cell height.
 */
+ (CGFloat)attachmentBubbleCellHeightForCellData:(MXKCellData *)cellData withMaximumWidth:(CGFloat)maxWidth;

@end
