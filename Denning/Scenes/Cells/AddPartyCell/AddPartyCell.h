//
//  AddPartyCell.h
//  Denning
//
//  Created by Denning IT on 2018-01-07.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralContactCell.h"

@interface AddPartyCell : GeneralContactCell

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) void(^addNew)(AddPartyCell* cell);

@end
