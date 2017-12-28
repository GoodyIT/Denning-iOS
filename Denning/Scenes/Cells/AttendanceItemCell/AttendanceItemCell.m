//
//  AttendanceItemCell.m
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AttendanceItemCell.h"

@implementation AttendanceItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithModel:(AttendanceItem*) model
{
    NSString* imageName = @"blue_circle";
    UIColor* typeColor;
    if ([model.theType isEqualToString:@"Clock-in"]) {
        imageName = @"blue_circle";
        typeColor = [UIColor babyBlue];
    } else if ([model.theType isEqualToString:@"Clock-out"]){
        imageName = @"red_circle";
        typeColor = [UIColor redColor];
    } else {
        imageName = @"yellow_circle";
        typeColor = [UIColor babyOrange];
    }
    self.imageView.image = [UIImage imageNamed:imageName];
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : typeColor };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:model.theType attributes:attrs];

    self.type.attributedText = attrStr;
    self.location.text = model.theLocation;
    self.time.text = model.theTime;
}

@end
