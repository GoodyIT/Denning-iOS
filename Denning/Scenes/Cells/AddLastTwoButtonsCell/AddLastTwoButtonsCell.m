//
//  AddLastTwoButtonsCell.m
//  Denning
//
//  Created by DenningIT on 12/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddLastTwoButtonsCell.h"

@implementation AddLastTwoButtonsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _lastBtn.layer.borderColor = [UIColor babyRed].CGColor ;
}

- (IBAction)didTapSave:(id)sender {
    self.saveHandler();
}

- (IBAction)didTapView:(id)sender {
    self.viewHandler();
}

- (IBAction)didTapConvertToTaxInvoice:(id)sender {
    self.convertHandler();
}


@end
