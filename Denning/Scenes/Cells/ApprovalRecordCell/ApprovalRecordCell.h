//
//  ApprovalRecordCell.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface ApprovalRecordCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *staff;
@property (weak, nonatomic) IBOutlet UILabel *PYL;
@property (weak, nonatomic) IBOutlet UILabel *AL;
@property (weak, nonatomic) IBOutlet UILabel *Taken;

- (void) configureCell:(LeaveRecordModel*) model;

@end
