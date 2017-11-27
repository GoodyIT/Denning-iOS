//
//  MatterLastCell.m
//  Denning
//
//  Created by DenningIT on 21/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MatterLastCell.h"


@implementation MatterLastCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.fileFolderBtn.titleLabel.minimumScaleFactor = 0.5f;
    self.fileFolderBtn.titleLabel.numberOfLines = 0;
    self.fileFolderBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tapFileFolder:(id)sender {
    [self.matterLastCellDelegate didTapFileFolder:self];
}

- (IBAction)tapAccounts:(id)sender {
    [self.matterLastCellDelegate didTapAccounts:self];
}

- (IBAction)tapFileNote:(id)sender {
    [self.matterLastCellDelegate  didTapFileNote:self];
}

- (void) configureCellWithModfel: (RelatedMatterModel*) model
{
    _model = model;
}
@end
