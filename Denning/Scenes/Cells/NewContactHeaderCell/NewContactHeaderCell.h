//
//  NewContactHeaderCell.h
//  Denning
//
//  Created by DenningIT on 25/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@class NewContactHeaderCell;
@protocol NewContactHeaderCellDelegate <NSObject>

@optional

- (void) didTapMessage: (NewContactHeaderCell*) cell;

- (void) didTapEdit: (NewContactHeaderCell*) cell;

@end

@interface NewContactHeaderCell : DIGeneralCell

@property (weak, nonatomic) id<NewContactHeaderCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNumberLable;
@property (weak, nonatomic) IBOutlet UILabel *oldICLabel;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UILabel *chatLabel;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UILabel *editLabel;

- (void) configureCellWithInfo:(NSString*) name number:(NSString*) number image:(UIImage*) image;

@end
