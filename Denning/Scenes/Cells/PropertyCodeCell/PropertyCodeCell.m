
//
//  PropertyCodeCell.m
//  Denning
//
//  Created by DenningIT on 18/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "PropertyCodeCell.h"

@implementation PropertyCodeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithModel:(FullPropertyModel*) model
{
    self.propertyTitle.text = model.fullTitle;
    self.projectName.text = model.projectName;
    self.address.text = model.address.fullAddress;
    self.parcelNo.text = [NSString stringWithFormat:@"%@ %@", model.spaParcel.type, model.spaParcel.value];
    self.condoName.text = model.spaCondoName;
}

@end
