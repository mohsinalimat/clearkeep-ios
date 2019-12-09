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

#import "MXKSampleRoomMembersViewController.h"

#import "MXKSampleRoomMemberTableViewCell.h"

@interface MXKSampleRoomMembersViewController ()

@end

@implementation MXKSampleRoomMembersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Turn off optional navigation bar items
    self.enableMemberInvitation = NO;
    self.enableMemberSearch = NO;
    
    // Set up customized table view cell class
    [self.membersTableView registerNib:MXKSampleRoomMemberTableViewCell.nib forCellReuseIdentifier:MXKSampleRoomMemberTableViewCell.defaultReuseIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override MXKDataSourceDelegate to use customized table view cell

- (Class<MXKCellRendering>)cellViewClassForCellData:(MXKCellData*)cellData
{
    // Return the default member table view cell
    return MXKSampleRoomMemberTableViewCell.class;
}

- (NSString *)cellReuseIdentifierForCellData:(MXKCellData*)cellData
{
    // Consider the default member table view cell
    return MXKSampleRoomMemberTableViewCell.defaultReuseIdentifier;
}

@end
