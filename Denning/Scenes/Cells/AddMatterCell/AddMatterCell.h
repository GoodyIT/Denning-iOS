//
//  AddMatterCell.h
//  Denning
//
//  Created by DenningIT on 19/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"
#import "GeneralContactCell.h"

@interface AddMatterCell : GeneralContactCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastLabel;

@property (strong, nonatomic) void(^addNew)(AddMatterCell* cell);

@end
