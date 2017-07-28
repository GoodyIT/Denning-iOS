//
//  SearchContactCell.m
//  Denning
//
//  Created by Ho Thong Mee on 27/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "SearchContactCell.h"

@interface SearchContactCell() {
    SearchResultModel* _model;
}

@end

@implementation SearchContactCell

- (void) adjustBtn:(UIButton*) btn
{
    btn.titleLabel.minimumScaleFactor = 0.5f;
    btn.titleLabel.numberOfLines = 0;
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
    self.titleLabel.copyingEnabled = YES;
    self.indexData.copyingEnabled = YES;
    self.descriptionLabel.copyingEnabled = YES;
    
    [self adjustBtn:_matterBtn];
    [self adjustBtn:_contactFolderBtn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTapMatter:(id)sender {
    _matterHandler(_model);
}

- (IBAction)didTapUpload:(id)sender {
    _uploadHandler(_model);
}

- (IBAction)didTapContactFolder:(id)sender {
    _contactHandler(_model);
}

- (void) configureCellWithModel:(SearchResultModel*) model
{
    _model = model;
    self.titleLabel.text = model.title;
    self.indexData.text = model.header;
    NSString* str = @"";
    for (NSDictionary *obj in model.Json) {
        if (str.length == 0) {
           str = [NSString stringWithFormat:@"%@: %@", [obj valueForKeyNotNull:@"label"], [obj valueForKeyNotNull:@"value"]];
        } else {
            str = [NSString stringWithFormat:@"%@\n%@: %@", str, [obj valueForKeyNotNull:@"label"], [obj valueForKeyNotNull:@"value"]];
        }
        
    }
    
    self.descriptionLabel.text = str;
}

@end
