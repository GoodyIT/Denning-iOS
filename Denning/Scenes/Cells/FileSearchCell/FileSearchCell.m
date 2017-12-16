//
//  FileSearchCell.m
//  Denning
//
//  Created by Denning IT on 2017-12-16.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileSearchCell.h"

@implementation FileSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCell:(SearchResultModel*) model
{
    self.titleLabel.text = model.title;
    NSString* str = @"";
    for (NSDictionary *obj in model.Json) {
        if (str.length == 0) {
            str = [NSString stringWithFormat:@"%@: %@", [obj valueForKeyNotNull:@"label"], [obj valueForKeyNotNull:@"value"]];
        } else {
            str = [NSString stringWithFormat:@"%@\n%@: %@", str, [obj valueForKeyNotNull:@"label"], [obj valueForKeyNotNull:@"value"]];
        }
        
    }
    
    self.descLabel.text = str;
}

@end
