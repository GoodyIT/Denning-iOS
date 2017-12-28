//
//  GroupInfoContactCell.h
//  Denning
//
//  Created by Denning IT on 2017-12-26.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "GeneralContactCell.h"
@interface GroupInfoContactCell : GeneralContactCell

@property (strong, nonatomic) void (^updateRoleBlock)(UITableViewCell *cell);

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastSeenLabel;
@property (weak, nonatomic) IBOutlet UIButton *roleBtn;

@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;

- (void) configureCellWithContact: (QBUUser*) user inChatDialog:(QBChatDialog*) chatDialog;


@end
