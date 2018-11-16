//
//  StaffOnlineHeaderCell.h
//  Denning
//
//  Created by Ho Thong Mee on 17/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface StaffOnlineHeaderCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *exeTitle;
@property (weak, nonatomic) IBOutlet UILabel *staff;
@property (weak, nonatomic) IBOutlet UILabel *webTitle;
@property (weak, nonatomic) IBOutlet UILabel *appTitle;

@end
