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
    _thirdValue.textAlignment = NSTextAlignmentRight;
    _firstValue.text = [DIHelpers getDateInShortForm:model.batchDate];
    _secondValue.text = model.batchNo;
    _thirdValue.text = [DIHelpers addThousandsSeparatorWithDecimal:model.totalAmount];
}

- (void) configureCellWithDict:(NSDictionary*) dict{
    _firstValue.text = [dict valueForKeyNotNull:@"timeIn"];
    _secondValue.text = [dict valueForKeyNotNull:@"timeOut"];
    _thirdValue.text = [dict valueForKeyNotNull:@"hours"];
}

@end
