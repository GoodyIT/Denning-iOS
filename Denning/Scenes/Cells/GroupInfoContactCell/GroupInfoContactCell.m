//
//  GroupInfoContactCell.m
//  Denning
//
//  Created by Denning IT on 2017-12-26.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "GroupInfoContactCell.h"

@implementation GroupInfoContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithContact: (QBUUser*) user inChatDialog:(QBChatDialog*) chatDialog
{
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                                    title:user.fullName
                           completedBlock:nil];
    
    self.userNameLabel.text = user.fullName;
    self.lastSeenLabel.text = [[QMCore instance].contactManager onlineStatusForUser:user];
    
    NSArray* adminRoles = [chatDialog.data objectForKey:@"role_admin"];
    NSArray* readerRoles = [chatDialog.data objectForKey:@"role"];
    self.roleLabel.textColor = [UIColor flatBlackColorDark];
    self.roleLabel.text = @"---";
    if (adminRoles != nil && adminRoles.count > 0) {
        if  ([adminRoles containsObject:@(user.ID)]) {
            self.roleLabel.text = @"Admin";
            self.roleLabel.textColor = [UIColor babyRed];
        }
    }
    
    if (readerRoles != nil && readerRoles.count > 0) {
        if ([readerRoles containsObject:@(user.ID)]) {
            self.roleLabel.text = @"Reader";
            self.roleLabel.textColor = [UIColor babyBule];
        }
    }
}

@end
