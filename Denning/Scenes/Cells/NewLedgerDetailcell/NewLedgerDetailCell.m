//
//  NewLedgerDetailCell.m
//  Denning
//
//  Created by DenningIT on 19/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "NewLedgerDetailCell.h"

@interface NewLedgerDetailCell()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *documentNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *receivedPaid;

@end

@implementation NewLedgerDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.amountLabel.copyingEnabled = YES;
    self.documentNoLabel.copyingEnabled = YES;
    self.descriptionLabel.copyingEnabled = YES;
    self.dateLabel.copyingEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithLedgerDetailModel:(LedgerDetailModel*) ledgerDetail
{
    self.dateLabel.text = [DIHelpers getDateInShortForm:ledgerDetail.date];
    self.documentNoLabel.text = ledgerDetail.documentNo;
    self.descriptionLabel.text = ledgerDetail.ledgerDescription;
    self.amountLabel.text = ledgerDetail.displayAmount;
    self.receivedPaid.text = ledgerDetail.recdPaid;
}

@end
