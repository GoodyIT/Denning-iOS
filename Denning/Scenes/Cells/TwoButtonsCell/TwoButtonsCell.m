//
//  TwoButtonsCell.m
//  Denning
//
//  Created by Denning IT on 2017-12-19.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TwoButtonsCell.h"

@implementation TwoButtonsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)didTapLeft:(id)sender {
    _leftHandler();
}

- (IBAction)didTapRight:(id)sender {
    _rightHandler();
}


@end
