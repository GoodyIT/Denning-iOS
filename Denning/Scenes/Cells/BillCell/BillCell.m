//
//  BillCell.m
//  Denning
//
//  Created by DenningIT on 18/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "BillCell.h"

@implementation BillCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.quotationNo.copyingEnabled = YES;
    self.issueBy.copyingEnabled = YES;
    self.issueTo.copyingEnabled = YES;
    self.primaryClient.copyingEnabled = YES;
    self.titleLabel.copyingEnabled = YES;
    self.fileNo.copyingEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithMatterSimple:(QuotationModel*) model
{
    self.quotationNo.text = model.documentNo;
    self.fileNo.text = model.fileNo;
    self.issueTo.text = model.issueToName;
    self.issueBy.text = model.issueBy;
    self.primaryClient.text = model.primaryClient;
    self.titleLabel.text = model.propertyTitle;
    self.fees.text = model.analysis.decFees;
    self.disb.text = model.analysis.decDisb;
    self.disbGST.text = model.analysis.decDisbGST;
    self.GST.text = model.analysis.decGST;
    self.total.text = model.analysis.decTotal;
}

- (void) configureCellWithModel:(TaxModel*) model
{
    self.quotationNo.text = model.documentNo;
    self.fileNo.text = model.fileNo;
    self.issueTo.text = model.issueToName;
    self.issueBy.text = model.issueBy;
    self.primaryClient.text = model.primaryClient;
    self.titleLabel.text = model.propertyTitle;
}

@end
