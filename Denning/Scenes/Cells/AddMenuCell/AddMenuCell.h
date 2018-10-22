//
//  AddMenuCell.h
//  Denning
//
//  Created by Denning IT on 2018-10-20.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddMenuCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *menuTitle;

@end

NS_ASSUME_NONNULL_END
