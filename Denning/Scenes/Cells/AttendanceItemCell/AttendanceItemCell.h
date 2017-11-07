//
//  AttendanceItemCell.h
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface AttendanceItemCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void) configureCellWithModel:(AttendanceItem*) model;
@end
