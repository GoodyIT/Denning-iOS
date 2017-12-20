//
//  TwoButtonsCell.h
//  Denning
//
//  Created by Denning IT on 2017-12-19.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

typedef void (^LeftHandler)(void);
typedef void (^RightHandler)(void);
@interface TwoButtonsCell : DIGeneralCell

@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property (strong, nonatomic) LeftHandler leftHandler;
@property (strong, nonatomic) RightHandler rightHandler;

@end
