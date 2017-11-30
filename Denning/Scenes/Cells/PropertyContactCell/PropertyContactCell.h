//
//  PropertyContactCell.h
//  Denning
//
//  Created by DenningIT on 18/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@class StaffModel;
@interface PropertyContactCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *ID;
@property (weak, nonatomic) IBOutlet UILabel *name;

- (void) configureCellWithStaffModel:(StaffModel*) model;
@end
