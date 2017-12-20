//
//  StaffLeaveModel.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StaffLeaveModel : NSObject

@property (strong, nonatomic) AttendanceInfo* clsApprovedBy;
@property (strong, nonatomic) AttendanceInfo* clsEnteredBy;
@property (strong, nonatomic) CodeDescription* clsLeaveStatus;
@property (strong, nonatomic) AttendanceInfo* clsStaff;
@property (strong, nonatomic) CodeDescription* clsTypeOfLeave;
@property (strong, nonatomic) AttendanceInfo* clsUpdatedBy;

@property (strong, nonatomic) NSString* codeValue;
@property (strong, nonatomic) NSString* dtDateApproved;
@property (strong, nonatomic) NSString* dtDateEntered;
@property (strong, nonatomic) NSString* dtDateSubmitted;
@property (strong, nonatomic) NSString* dtDateUpdated;
@property (strong, nonatomic) NSString* dtEndDate;
@property (strong, nonatomic) NSString* dtStartDate;
@property (strong, nonatomic) NSString* decLeaveLength;
@property (strong, nonatomic) NSString* strLogBalancedLeave;
@property (strong, nonatomic) NSString* strLogEntitlement;
@property (strong, nonatomic) NSString* strLogUsedToDate;
@property (strong, nonatomic) NSString* strManagerRemarks;
@property (strong, nonatomic) NSString* strRemarks;
@property (strong, nonatomic) NSString* strStaffRemarks;

+ (instancetype) getStaffLeaveFromResponse:(NSDictionary*) response;

@end
