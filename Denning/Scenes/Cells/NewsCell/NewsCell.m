//
//  NewsCell.m
//  Denning
//
//  Created by DenningIT on 01/02/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "NewsCell.h"

@interface NewsCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortDestriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet QMImageView *newsImageView;

@end

@implementation NewsCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithNews:(NewsModel*) news
{
    self.titleLabel.text = news.title;
    self.shortDestriptionLabel.text = news.shortDescription;
    self.dateLabel.text = [DIHelpers getDateInShortForm:news.theDateTime];
    
    NSURL *URL = [NSURL URLWithString:
                  [NSString stringWithFormat:@"data:application/octet-stream;base64,%@",
                   news.imageData]];
    NSData* imageData = [NSData dataWithContentsOfURL:URL];
    if (imageData != nil) {
        self.newsImageView.image = [UIImage imageWithData:imageData];
    } else {
        self.newsImageView.image = [UIImage imageNamed:@"law-firm.jpg"];
    }
}

@end
