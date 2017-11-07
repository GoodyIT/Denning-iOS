//
//  TwoColumnCell.m
//  Denning
//
//  Created by DenningIT on 18/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TwoColumnCell.h"

@implementation TwoColumnCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithCodeValue:(NSString*)codeValue  descValue:(NSString*) descValue
{
    self.codeLabel.text = codeValue;
    self.descLabel.text = descValue;
}

@end
