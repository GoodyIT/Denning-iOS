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
@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastseenLabel;

@end

@implementation FavContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) configureCellWithContact: (QBUUser*) user
{
    UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.avatarImageView.bounds title:user.fullName ID:user.ID];
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                              placeholder:placeholder
                                  options:1
                                 progress:nil
                           completedBlock:nil];

    self.userNameLabel.text = user.fullName;
    self.lastseenLabel.text = [[QMCore instance].contactManager onlineStatusForUser:user];
}

@end
