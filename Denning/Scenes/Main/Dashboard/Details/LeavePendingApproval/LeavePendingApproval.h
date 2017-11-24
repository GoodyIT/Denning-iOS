//
//  LeavePendingApproval.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeavePendingApproval : UIViewController

@property (strong, nonatomic) NSString* submittedBy, *submittedByCode;
@property (strong, nonatomic) StaffLeaveModel* model;

@end
