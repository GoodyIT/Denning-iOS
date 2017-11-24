//
//  ApprovalRecordCell.m
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ApprovalRecordCell.h"

@implementation ApprovalRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCell:(LeaveRecordModel*) model
{
    _staff.text = model.clsStaff.strName;
    _PYL.text = model.intPYL;
    _AL.text = model.intAL;
    _Taken.text = model.intTaken;
}

@end

