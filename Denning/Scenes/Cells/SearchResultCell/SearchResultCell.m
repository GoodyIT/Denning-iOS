//
//  SearchResultCell.m
//  Denning
//
//  Created by DenningIT on 20/01/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "SearchResultCell.h"

@interface SearchResultCell()
{
    SearchResultModel* _model;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *indexData;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *fileFolderBtn;
@property (weak, nonatomic) IBOutlet UIButton *ledgerBtn;

@end

@implementation SearchResultCell

- (void) adjustBtn:(UIButton*) btn
{
    btn.titleLabel.minimumScaleFactor = 0.5f;
    btn.titleLabel.numberOfLines = 0;
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (void) configureCellWithSearchModel: (SearchResultModel*) searchResult
{
    _model = searchResult;
    self.titleLabel.text = searchResult.title;
    NSString* str = @"";
    for (NSDictionary *obj in searchResult.Json) {
        if (str.length == 0) {
            str = [NSString stringWithFormat:@"%@: %@", [obj valueForKeyNotNull:@"label"], [obj valueForKeyNotNull:@"value"]];
        } else {
            str = [NSString stringWithFormat:@"%@\n%@: %@", str, [obj valueForKeyNotNull:@"label"], [obj valueForKeyNotNull:@"value"]];
        }
    }
    self.descriptionLabel.text = str;
}

#pragma mark - SearchDelegate
- (IBAction)relatedMatterTapped:(id)sender {
    [self.delegate didTapMatter:self];
}

- (IBAction)didTapUpload:(id)sender {
    _uploadHandler(_model);
}

- (IBAction)didTapContactFolder:(id)sender {
    _contactHandler(_model);
}

@end
