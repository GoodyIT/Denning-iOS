//
//  AddLastTwoButtonsCell.h
//  Denning
//
//  Created by DenningIT on 12/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

typedef void (^ViewHandler)(void);
typedef void (^SaveHandler)(void);
typedef void (^ConvertHandler)(void);
@interface AddLastTwoButtonsCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UIButton *lastBtn;

@property (strong, nonatomic) ViewHandler viewHandler;
@property (strong, nonatomic) SaveHandler saveHandler;
@property (strong, nonatomic) ConvertHandler convertHandler;
@end
