//
//  PendingApprovalCell.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface PendingApprovalCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *staff;
@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UILabel *type;

- (void) configureCell:(LeaveRecordModel*) model;

@end
