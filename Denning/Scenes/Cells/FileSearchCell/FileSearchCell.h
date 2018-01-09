//
//  FileSearchCell.h
//  Denning
//
//  Created by Denning IT on 2017-12-16.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@class SearchResultModel;
@class FirmURLModel;
@interface FileSearchCell : DIGeneralCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@property (assign, nonatomic) BOOL checked;

- (void)setChecked:(BOOL)checked animated:(BOOL)animated;
- (void) configureCell:(SearchResultModel*) model;
- (void) configureCellWithFirm:(FirmURLModel*) model;

@end
