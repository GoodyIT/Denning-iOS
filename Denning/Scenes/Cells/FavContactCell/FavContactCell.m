//
//  FavContactCell.m
//  Denning
//
//  Created by DenningIT on 07/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FavContactCell.h"
#import "SDWebImageManager.h"
#import "QMPlaceholder.h"

@interface FavContactCell()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastseenLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;

@end

@implementation FavContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
}

- (void) configureCellWithContact: (QBUUser*) user
{
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                                    title:user.fullName
                           completedBlock:nil];

    self.userNameLabel.text = user.fullName;
    self.lastseenLabel.text = [[QMCore instance].contactManager onlineStatusForUser:user];
    self.positionLabel.text = user.twitterDigitsID;
}

@end
