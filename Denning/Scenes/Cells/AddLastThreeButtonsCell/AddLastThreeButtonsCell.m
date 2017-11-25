
//
//  AddLastThreeButtonsCell.m
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddLastThreeButtonsCell.h"

@implementation AddLastThreeButtonsCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _invoiceBtn.layer.borderColor = [UIColor babyRed].CGColor;
    _receiptBtn.layer.borderColor = [UIColor babyRed].CGColor;
}

- (IBAction)didTapSave:(id)sender {
    self.saveHandler();
}

- (IBAction)didTapView:(id)sender {
    self.viewHandler();
}

- (IBAction)didTapToReceipt:(id)sender {
    _receiptHandler();
}

- (IBAction)didTapConvertToTaxInvoice:(id)sender {
    self.invoiceHandler();
}


@end
