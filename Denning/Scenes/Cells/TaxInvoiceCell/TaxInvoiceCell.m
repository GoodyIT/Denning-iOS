//
//  TaxInvoiceCell.m
//  Denning
//
//  Created by Ho Thong Mee on 15/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TaxInvoiceCell.h"

@implementation TaxInvoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithModel:(TaxInvoiceModel*) model
{
    _taxInvoiceNo.text = model.invoiceNo;
    _fileNo.text = model.fileNo;
    _fileName.text = model.fileName;
    _amount.text = model.amount;
    _invoiceTo.text = model.issueToName;
}

@end
