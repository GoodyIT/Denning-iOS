//
//  AddPartyCell.m
//  Denning
//
//  Created by Denning IT on 2018-01-07.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import "AddPartyCell.h"

@implementation AddPartyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTapAdd:(id)sender {
    self.addNew(self);
}

@end
