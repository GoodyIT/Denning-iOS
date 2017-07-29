//
//  DashboardSecondCell.m
//  Denning
//
//  Created by Ho Thong Mee on 26/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DashboardSecondCell.h"

@implementation DashboardSecondCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void) configurecellWithModel:(SecondItemModel*) model
{
    self.label.text = model.label;
    self.RM.text = model.RM;
//    self.OR.text = model.OR;
    self.deposited.text = [NSString stringWithFormat:@"%@ (%@)", model.deposited, model.OR];
}

@end
