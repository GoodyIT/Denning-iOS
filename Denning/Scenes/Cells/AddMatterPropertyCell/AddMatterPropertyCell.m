//
//  AddMatterPropertyCell.m
//  Denning
//
//  Created by Ho Thong Mee on 30/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddMatterPropertyCell.h"

@implementation AddMatterPropertyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithFullTitle: (NSString*) fullTitle withAddress:(NSString*) address inNumber:(NSInteger) number
{
    self.propertyNumber.text = [NSString stringWithFormat:@"%ld", number];
    self.fullTitle.text = [DIHelpers capitalizedString:fullTitle];
    self.address.text = [DIHelpers capitalizedString:address];
}

@end
