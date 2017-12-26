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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithContact: (QBUUser*) user
{
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                                    title:user.fullName
                           completedBlock:nil];
    
    self.userNameLabel.text = user.fullName;
    self.lastSeenLabel.text = [[QMCore instance].contactManager onlineStatusForUser:user];
}

@end
