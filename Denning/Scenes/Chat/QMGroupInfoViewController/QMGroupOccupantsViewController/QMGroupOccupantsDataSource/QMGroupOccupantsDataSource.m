//
//  QMGroupOccupantsDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupOccupantsDataSource.h"
#import "QMCore.h"

#import "GroupInfoContactCell.h"
#import "QMAddMemberCell.h"
#import "QMLeaveChatCell.h"
#import "QMSeparatorCell.h"
#import "NotificationCell.h"

static const NSUInteger kQMStaticCellsCount = 5;
static const NSUInteger kQMNumberOfStaticCellsBeforeOccupantsList = 1;
static const NSUInteger kQMNumberOfSections = 1;

typedef NS_ENUM(NSUInteger, QMGroupInfoSection) {
    
    DIGroupHeaderInfoSection,
    DIGroupUsersInfoSection,
    DIGroupNotificationSection,
    DIGroupLeaveRemoveChatSection
};

@interface QMGroupOccupantsDataSource ()

@property (assign, nonatomic, readonly) NSInteger separatorCellIndex;

@end

@implementation QMGroupOccupantsDataSource

//MARK: - Getters

- (NSInteger)addMemberCellIndex {
    
    return 0;
}

- (NSInteger)separatorCellIndex {
    
    return self.items.count > 0 ? self.items.count + kQMNumberOfStaticCellsBeforeOccupantsList : 1;
}

- (NSInteger) notificationCellIndex {
    
    return self.separatorCellIndex + 1;
}

- (NSInteger)separatorCellIndex1 {
     return self.notificationCellIndex + 1;
}

- (NSInteger)leaveChatCellIndex {
    
    return self.separatorCellIndex1 + 1;
}

//MARK: - Methods

- (NSUInteger)userIndexForIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.row - kQMNumberOfStaticCellsBeforeOccupantsList;
}

- (NSIndexPath *)indexPathForObject:(id)object {
    NSUInteger idx = [self.items indexOfObject:object];
    if (idx == NSNotFound) {
        return nil;
    }
    return [NSIndexPath indexPathForItem:idx+kQMNumberOfStaticCellsBeforeOccupantsList inSection:0];
}

//MARK: - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.addMemberCellIndex) {
        
        QMAddMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMAddMemberCell cellIdentifier] forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == self.separatorCellIndex) {
        
        QMSeparatorCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMSeparatorCell cellIdentifier] forIndexPath:indexPath];
        return cell;
    }
    else if ( indexPath.row == self.separatorCellIndex1) {
        
        QMSeparatorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMSeparatorCell" forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == self.leaveChatCellIndex) {
        
        QMLeaveChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMLeaveChatCell cellIdentifier] forIndexPath:indexPath];
        return cell;
    }
    else if ( indexPath.row == self.notificationCellIndex) {
        
        NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:[NotificationCell cellIdentifier] forIndexPath:indexPath];
        NSNumber* enable = [_chatDialog.data valueForKey:@"notifications"];
        if (enable == nil || [enable integerValue] == 1) {
            cell.notificationSwitch.on = YES;
        } else {
            cell.notificationSwitch.on = NO;
        }
        
        if (![DIHelpers canMuteforDialog:self.chatDialog]) {
            cell.userInteractionEnabled = NO;
        } else {
            cell.userInteractionEnabled = YES;
        }
        
        return cell;
    }
    else {
        
        GroupInfoContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[GroupInfoContactCell cellIdentifier] forIndexPath:indexPath];
        
        QBUUser *user = self.items[indexPath.row - kQMNumberOfStaticCellsBeforeOccupantsList];
        
        [cell configureCellWithContact:user inChatDialog:_chatDialog];
        
        cell.updateRoleBlock = _updateRoleBlock;
        
//        BOOL isRequestRequired = ![QMCore.instance.contactManager isContactListItemExistentForUserWithID:user.ID];
//
//        if (QMCore.instance.currentProfile.userData.ID == user.ID) {
//
//            isRequestRequired = NO;
//        }
//
//
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    
    return kQMNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    
    NSInteger count = self.items.count + kQMStaticCellsCount;
    
    if ([DIHelpers isSupportChat:self.chatDialog]) {
        if (![DataManager sharedManager].isDenningUser) {
            // Only Denning user can change the avatar for Denning support
            count -= 1;
        }
    } else if (![DataManager sharedManager].isStaff) {
        count -= 1;
    }
    
    return count;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.addMemberCellIndex) {
        
        return [QMAddMemberCell height];
    }
    else if (indexPath.row == self.separatorCellIndex || indexPath.row == self.separatorCellIndex1) {
        
        return [QMSeparatorCell height];
    }
    else if (indexPath.row == self.leaveChatCellIndex) {
        
        return [QMLeaveChatCell height];
    }
    else {
        
        return [GroupInfoContactCell height];
    }
}

@end
