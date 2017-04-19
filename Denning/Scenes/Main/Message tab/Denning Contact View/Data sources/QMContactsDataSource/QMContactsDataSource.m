//
//  QMContactsDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactsDataSource.h"
#import "QMContactCell.h"
#import "QMNoContactsCell.h"
#import "QMCore.h"

@implementation QMContactsDataSource

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
    [cell setTitle:user.fullName placeholderID:user.ID avatarUrl:user.avatarUrl];
    
    NSString *onlineStatus = [[QMCore instance].contactManager onlineStatusForUser:user];
    [cell setBody:onlineStatus];
    
    return cell;
}

@end
