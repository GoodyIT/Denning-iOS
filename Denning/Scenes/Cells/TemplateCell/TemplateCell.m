//
//  TemplateCell.m
//  Denning
//
//  Created by Ho Thong Mee on 24/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TemplateCell.h"

@implementation TemplateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithModel: (TemplateModel*) model
{
    _templateName.text = model.strDescription;
    _versionNo.text = model.intVersionID;
    _date.text = [NSString stringWithFormat:@"(%@)", [DIHelpers getDateInShortForm:model.dtCreatedDate]];
    _user.text = model.strSource;
}

@end
