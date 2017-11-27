//
//  MatterNewLastCell.m
//  Denning
//
//  Created by Denning IT on 2017-11-27.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MatterNewLastCell.h"

@implementation MatterNewLastCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.paymentRecordBtn.titleLabel.minimumScaleFactor = 0.5f;
    self.paymentRecordBtn.titleLabel.numberOfLines = 0;
    self.paymentRecordBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)tapPaymentRecord:(id)sender {
    [self.matterNewLastCellDelegate didTapPaymentRecord:self];
}


- (IBAction)tempateTapped:(id)sender {
    [self.matterNewLastCellDelegate didTapTemplate:self withModel:_model];
}

- (IBAction)uploadTapped:(id)sender {
    [self.matterNewLastCellDelegate didTapUpload:self fileNo:_model.systemNo];
}

- (void) configureCellWithModfel: (RelatedMatterModel*) model
{
    _model = model;
}

@end
