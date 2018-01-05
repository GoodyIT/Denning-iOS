//
//  FileSearchCell.m
//  Denning
//
//  Created by Denning IT on 2017-12-16.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileSearchCell.h"
#import "SearchResultModel.h"
#import "NSDictionary+NotNull.h"
#import <QuartzCore/QuartzCore.h>

static UIImage *selectedCheckImage() {
    
    static UIImage *image = nil;
    
    if (image == nil) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            image = [UIImage imageNamed:@"checkmark_selected"];
        });
    }
    
    return image;
}

static UIImage *deselectedCheckImage() {
    
    static UIImage *image = nil;
    
    if (image == nil) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            image = [UIImage imageNamed:@"checkmark_deselected"];
        });
    }
    
    return image;
}

@interface FileSearchCell()

@end

@implementation FileSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.checkmarkImageView.image = deselectedCheckImage();
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setChecked:(BOOL)checked {
    
    if (_checked != checked) {
        
        _checked = checked;
        self.checkmarkImageView.image = checked ? selectedCheckImage() : deselectedCheckImage();
    }
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated {
    
    if (_checked != checked) {
        
        self.checked = checked;
        
        if (animated) {
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.2f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            
            [self.checkmarkImageView.layer addAnimation:transition forKey:nil];
        }
    }
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
