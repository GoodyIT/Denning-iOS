//
//  TwoColumnCell.h
//  Denning
//
//  Created by DenningIT on 18/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface TwoColumnCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

- (void) configureCellWithCodeValue:(NSString*)codeValue  descValue:(NSString*) descValue;
@end
