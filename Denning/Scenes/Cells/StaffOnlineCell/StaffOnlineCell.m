//
//  StaffOnlineCell.m
//  Denning
//
//  Created by Ho Thong Mee on 17/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "StaffOnlineCell.h"

@implementation StaffOnlineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithModel:(StaffOnlineModel*) model
{
    _staff.text = model.name;
    if ([model.onlineExe boolValue]) {
        _exeStatus.image = [UIImage imageNamed:@"icon_status"];
    } else {
        _exeStatus.image = [UIImage imageNamed:@"icon_status_offline"];
    }
    
    if ([model.onlineWeb boolValue]) {
        _webStatus.image = [UIImage imageNamed:@"icon_status"];
    } else {
        _webStatus.image = [UIImage imageNamed:@"icon_status_offline"];
    }
    
    if ([model.onlineApp boolValue]) {
        _appStatus.image = [UIImage imageNamed:@"icon_status"];
    } else {
        _appStatus.image = [UIImage imageNamed:@"icon_status_offline"];
    }
}
@end
