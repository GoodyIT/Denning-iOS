//
//  MatterLitigationCell.m
//  Denning
//
//  Created by Ho Thong Mee on 23/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MatterLitigationCell.h"

@implementation MatterLitigationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.systemNo.copyingEnabled = YES;
    self.courtCaseNo.copyingEnabled = YES;
    self.courtCaseName.copyingEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithModel: (MatterLitigationModel*) model
{
    self.systemNo.text = model.systemNo;
    self.courtCaseNo.text = model.courtInfo.caseNo;
    self.courtCaseName.text = model.courtInfo.caseName;
}

@end
