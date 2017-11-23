//
//  QMGroupOccupantsDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupOccupantsDataSource.h"
#import "QMCore.h"

#import "QMContactCell.h"
#import "QMAddMemberCell.h"
#import "QMLeaveChatCell.h"
#import "QMSeparatorCell.h"

static const NSUInteger kQMStaticCellsCount = 3;
static const NSUInteger kQMNumberOfStaticCellsBeforeOccupantsList = 1;
static const NSUInteger kQMNumberOfSections = 1;

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

- (NSInteger)leaveChatCellIndex {
    
    return self.separatorCellIndex + 1;
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
    else if (indexPath.row == self.leaveChatCellIndex) {
        
        QMLeaveChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMLeaveChatCell cellIdentifier] forIndexPath:indexPath];
        return cell;
    }
    else {
        
        QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMContactCell cellIdentifier] forIndexPath:indexPath];
        
        QBUUser *user = self.items[indexPath.row - kQMNumberOfStaticCellsBeforeOccupantsList];
        [cell setTitle:user.fullName avatarUrl:user.avatarUrl];
        
        BOOL isRequestRequired = ![QMCore.instance.contactManager isContactListItemExistentForUserWithID:user.ID];
        
        if (QMCore.instance.currentProfile.userData.ID == user.ID) {
            
            isRequestRequired = NO;
        }
        
        [cell setAddButtonVisible:isRequestRequired];
        
        [cell setBody:[QMCore.instance.contactManager onlineStatusForUser:user]];
        
        cell.didAddUserBlock = self.didAddUserBlock;
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    
    return kQMNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    
    return self.items.count + kQMStaticCellsCount;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.addMemberCellIndex) {
        
        return [QMAddMemberCell height];
    }
    else if (indexPath.row == self.separatorCellIndex) {
        
        return [QMSeparatorCell height];
    }
    else if (indexPath.row == self.leaveChatCellIndex) {
        
        return [QMLeaveChatCell height];
    }
    else {
        
        return [QMContactCell height];
    }
}

@end
