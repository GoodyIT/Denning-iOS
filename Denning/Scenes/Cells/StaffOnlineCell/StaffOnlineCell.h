//
//  StaffOnlineCell.h
//  Denning
//
//  Created by Ho Thong Mee on 17/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface StaffOnlineCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *staff;
@property (weak, nonatomic) IBOutlet UIImageView *exeStatus;
@property (weak, nonatomic) IBOutlet UIImageView *webStatus;
@property (weak, nonatomic) IBOutlet UIImageView *appStatus;

- (void) configureCellWithModel:(StaffOnlineModel*) model;

@end
