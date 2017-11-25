//
//  FloatingTextTwoColumnReversedCell.h
//  Denning
//
//  Created by Ho Thong Mee on 08/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralContactCell.h"

@interface FloatingTextTwoColumnReversedCell : GeneralContactCell
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *leftValue;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *rightType;

@end
