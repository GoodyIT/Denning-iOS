//
//  LeaveRecordCell.m
//  Denning
//
//  Created by Ho Thong Mee on 15/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LeaveRecordCell.h"

@implementation LeaveRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void) configureCellWithModel:(LeaveRecordModel*) model
{
    _startDate.text =model.dtStartDate;
    _endDate.text = model.dtEndDate;
    _no.text = model.strLeaveLength;
    _type.text = model.clsTypeOfLeave.descriptionValue;
    _status.text = model.clsLeaveStatus.descriptionValue;
}

@end
