//
//  FloatingTextTwoColumnCell.h
//  Denning
//
//  Created by DenningIT on 11/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralContactCell.h"

typedef void (^UpdateTypeHandler)(void);

typedef void (^UpdateValueHandler)(void);

@interface FloatingTextTwoColumnCell : GeneralContactCell
@property (weak, nonatomic) IBOutlet UIImageView *rightDetailDisclosure;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *leftFloatingText;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *rightFloatingText;

@property (strong, nonatomic) UpdateTypeHandler updateTypeHandler;
@property (strong, nonatomic) UpdateTypeHandler updateValueHandler;
@end
