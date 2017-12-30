//
//  GroupInfoContactCell.m
//  Denning
//
//  Created by Denning IT on 2017-12-26.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "GroupInfoContactCell.h"

@interface GroupInfoContactCell() {
    QBUUser* _user;
}

@end

@implementation GroupInfoContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) configureCellWithContact: (QBUUser*) user inChatDialog:(QBChatDialog*) chatDialog
{
    _user = user;
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                                    title:user.fullName
                           completedBlock:nil];
    
    NSString* userName = user.fullName;
    if ([user.email isEqualToString:[QBSession currentSession].currentUser.email]) {
        userName = @"You";
    }
    
    self.userNameLabel.text = userName;
    self.lastSeenLabel.text = [[QMCore instance].contactManager onlineStatusForUser:user];
    
    if ([DIHelpers isSupportChat:chatDialog]) {
        NSString *role = [DIHelpers getCurrentUserRole:user.ID fromChatDialog:chatDialog];
        NSString* btnTitle = @"Normal";
        UIColor *color = [UIColor babyBlue];
        
        if ([role isEqualToString:kRoleAdminTag]) {
            btnTitle = @"Admin";
            color = [UIColor babyRed];
        } else if ([role isEqualToString:kRoleNormalTag]) {
            btnTitle = @"Normal";
            color = [UIColor babyBlue];
        } else if ([role isEqualToString:kRoleReaderTag]) {
            btnTitle = @"Reader";
            color = [UIColor babyGreen];
        }
        
        self.roleBtn.hidden = NO;
        [self.roleBtn setTitle:btnTitle forState:UIControlStateNormal];
        [self.roleBtn setTitleColor:color forState:UIControlStateNormal];
    } else {
        self.roleBtn.hidden = YES;
    }
}

- (IBAction)updateUser:(id)sender {
    _updateRoleBlock(self);
}

@end
