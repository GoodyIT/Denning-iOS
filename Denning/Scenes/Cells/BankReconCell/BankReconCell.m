//
//  BankReconCell.m
//  Denning
//
//  Created by Ho Thong Mee on 14/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "BankReconCell.h"

@implementation BankReconCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) configureCellWithModel: (BankReconModel*) model
{
    _firstValue.text = model.accountName;
    _secondValue.text = model.accountNo;
    _thirdValue.text = model.lastMovement;
}

- (void) configureCellForFileLedger:(BankReconModel*) model
{
    _firstValue.text = model.accountNo;
    _secondValue.text = model.accountName;
    if ([model.credit floatValue] != 0.0f) {
        _thirdValue.text = [model.credit stringByAppendingString:@" (CR)"];
    } else {
        _thirdValue.text = [model.debit stringByAppendingString:@" (DR)"];
    }
}

- (void) configureCellForBankBalance:(BankReconModel*) model
{
    _firstValue.text = model.accountName;
    _secondValue.text = model.accountNo;
    if ([model.credit floatValue] != 0.0f) {
        _thirdValue.text = [model.credit stringByAppendingString:@" (CR)"];
    } else {
        _thirdValue.text = model.debit;
    }
}

- (void) configureCellForFeesTransfer: (FeeTranserModel*) model
{
    _firstValue.text = [DIHelpers getDateInShortForm:model.batchDate];
    _secondValue.text = model.batchNo;
    _thirdValue.text = [DIHelpers addThousandsSeparatorWithDecimal:model.totalAmount];
}

@end
