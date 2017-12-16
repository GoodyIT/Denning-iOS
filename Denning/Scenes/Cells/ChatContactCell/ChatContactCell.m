//
//  ChatContactCell.m
//  Denning
//
//  Created by DenningIT on 12/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ChatContactCell.h"
#import "QMPlaceholder.h"

@interface ChatContactCell()
{
    QBUUser* curUser;
}

@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastSeenLabel;
@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;

@end

@implementation ChatContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithContact: (QBUUser*) user
{
    curUser = user;
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                                title:user.fullName
                       completedBlock:nil];
    
    self.userNameLabel.text = user.fullName;
    self.lastSeenLabel.text = [[QMCore instance].contactManager onlineStatusForUser:user];
    if (![self isExistInFavoriteList:user]) {
        [self.favoriteBtn setImage:[UIImage imageNamed:@"icon_favorite"] forState:UIControlStateNormal];
    } else {
        [self.favoriteBtn setImage:[UIImage imageNamed:@"icon_favorite_selected"] forState:UIControlStateNormal];
    }
}

- (BOOL) isExistInFavoriteList: (QBUUser*) user {
    NSArray* favArray = [[DataManager sharedManager].favClientContactsArray arrayByAddingObjectsFromArray:[DataManager sharedManager].favStaffContactsArray];
    for (ChatFirmModel* newModel in favArray) {
        if ([newModel.users containsObject:user])
            return YES;
    }
    
    return NO;
}

- (IBAction)didTapFavBtn:(id)sender {
    if (![self isExistInFavoriteList:curUser]) {
       [self.chatDelegate didFavTapped:self user:curUser tapType:@"Add"];
    } else {
        [self.chatDelegate didFavTapped:self user:curUser tapType:@"Remove"];
    }
}

@end
