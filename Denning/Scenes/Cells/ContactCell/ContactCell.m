//
//  ContactCell.m
//  Denning
//
//  Created by DenningIT on 26/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ContactCell.h"

@interface ContactCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property (strong, nonatomic) NSString* value;

@end

@implementation ContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.rightBtn.hidden = YES;
    self.titleLabel.copyingEnabled = YES;
    self.contentLabel.copyingEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithContact:(NSString*) title text:(NSString*) text
{
    self.titleLabel.text = title;
    self.contentLabel.text = text.uppercaseString;
    
    self.value = text;
    if (text.length == 0) {
        self.rightBtn.hidden = YES;
    }
}

- (void) configureCellWithContact:(NSString*) title text:(NSString*) text withLower:(BOOL) isLower
{
    self.titleLabel.text = title;
    if (isLower) {
        self.contentLabel.text = text;
    } else {
        self.contentLabel.text = text.uppercaseString;
    }
    
    self.value = text;
}

- (void) setEnableRightBtn: (BOOL) enabled image:(UIImage*)rightImage
{
    self.rightBtn.hidden = !enabled;
    [self.rightBtn setImage:rightImage forState:UIControlStateNormal];
}

- (IBAction)didTapPhone:(id)sender {
    [self.delegate didTapRightBtn:self value:self.value];
}

@end
