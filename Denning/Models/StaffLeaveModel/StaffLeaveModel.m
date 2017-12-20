//
//  StaffLeaveModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "StaffLeaveModel.h"

@implementation StaffLeaveModel

+ (instancetype) getStaffLeaveFromResponse:(NSDictionary*) response
{
    StaffLeaveModel* model = [StaffLeaveModel new];
    
    model.clsApprovedBy = [AttendanceInfo getAttendanceInfoFromResonse:[response objectForKeyNotNull:@"clsApprovedBy"]];
    model.clsEnteredBy = [AttendanceInfo getAttendanceInfoFromResonse:[response objectForKeyNotNull:@"clsEnteredBy"]];
    model.clsLeaveStatus = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"clsLeaveStatus"]];
    model.clsStaff = [AttendanceInfo getAttendanceInfoFromResonse:[response objectForKeyNotNull:@"clsStaff"]];
    model.clsTypeOfLeave = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"clsTypeOfLeave"]];
    model.clsUpdatedBy = [AttendanceInfo getAttendanceInfoFromResonse:[response objectForKeyNotNull:@"clsUpdatedBy"]];
    
    model.codeValue = [response valueForKeyNotNull:@"code"];
    model.dtDateApproved = [response valueForKeyNotNull:@"dtDateApproved"];
    model.dtDateEntered = [response valueForKeyNotNull:@"dtDateEntered"];
    model.dtDateSubmitted = [response valueForKeyNotNull:@"dtDateSubmitted"];
    model.dtDateUpdated = [response valueForKeyNotNull:@"dtDateUpdated"];
    model.dtEndDate = [response valueForKeyNotNull:@"dtEndDate"];
    model.dtStartDate = [response valueForKeyNotNull:@"dtStartDate"];
    model.decLeaveLength = [response valueForKeyNotNull:@"decLeaveLength"];
    model.strLogBalancedLeave = [response valueForKeyNotNull:@"strLogBalancedLeave"];
    model.strLogEntitlement = [response valueForKeyNotNull:@"strLogEntitlement"];
    model.strLogUsedToDate = [response valueForKeyNotNull:@"strLogUsedToDate"];
    model.strManagerRemarks = [response valueForKeyNotNull:@"strManagerRemarks"];
    model.strRemarks = [response valueForKeyNotNull:@"strRemarks"];
    model.strStaffRemarks = [response valueForKeyNotNull:@"strStaffRemarks"];
    
    return model;
}

@end
