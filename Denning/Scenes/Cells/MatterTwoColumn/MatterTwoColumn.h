//
//  MatterTwoColumn.h
//  Denning
//
//  Created by Ho Thong Mee on 26/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface MatterTwoColumn : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *firstValue;
@property (weak, nonatomic) IBOutlet UILabel *secondValue;

@end
