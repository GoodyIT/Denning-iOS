//
//  QMContactsDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "FavContactsDataSource.h"
#import "QMContactCell.h"
#import "QMNoContactsCell.h"
#import "QMCore.h"

@implementation FavContactsDataSource

#pragma mark - methods

- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self objectAtIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return self.isEmpty ? [QMNoContactsCell height] : [QMContactCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isEmpty) {
        
        QMNoContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoContactsCell cellIdentifier] forIndexPath:indexPath];
        [cell setTitle:NSLocalizedString(@"QM_STR_NO_CONTACTS", nil)];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMContactCell cellIdentifier] forIndexPath:indexPath];
    
    QBUUser *user = [self userAtIndexPath:indexPath];
    
    [cell setTitle:user.fullName avatarUrl:user.avatarUrl];

    NSString *onlineStatus = [[QMCore instance].contactManager onlineStatusForUser:user];
    [cell setBody:onlineStatus];
    [cell setFavButtonVisible:NO];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)__unused tableView canEditRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)__unused tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        QBUUser *user = [self userAtIndexPath:indexPath];
        [self.delegate favContactDataSource:self commitDeleteDialog:user];
    }
}

@end
