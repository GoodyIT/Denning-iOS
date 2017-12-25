//
//  AddLastOneButtonCell.h
//  Denning
//
//  Created by DenningIT on 12/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

typedef void (^CalculateHandler)(void);

@interface AddLastOneButtonCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UIButton *calculateBtn;
@property (strong, nonatomic) CalculateHandler calculateHandler;

@end
