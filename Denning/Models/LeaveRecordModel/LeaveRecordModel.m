//
//  LeaveRecordModel.m
//  Denning
//
//  Created by Ho Thong Mee on 15/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LeaveRecordModel.h"

@implementation LeaveRecordModel

+(instancetype) getLeaveRecordFromResponse: (NSDictionary*) response
{
    LeaveRecordModel *model = [LeaveRecordModel new];
    
    model.leaveCode = [response valueForKeyNotNull:@"code"];
    model.dtEndDate = [DIHelpers getDateInShortForm:[response valueForKeyNotNull:@"dtEndDate"]];
    model.dtStartDate = [DIHelpers getDateInShortForm:[response valueForKeyNotNull:@"dtStartDate"]];
    model.clsLeaveLength = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"strLeaveLength"]];
    model.intAL = [response valueForKeyNotNull:@"intAL"];
    model.intPYL = [response valueForKeyNotNull:@"intPYL"];
    model.intTaken = [response valueForKeyNotNull:@"intTaken"];
    model.clsLeaveStatus = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"clsLeaveStatus"]];
    model.clsStaff = [AttendanceInfo getAttendanceInfoFromResonse:[response objectForKeyNotNull:@"clsStaff"]];
    model.clsTypeOfLeave = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"clsTypeOfLeave"]];
    return model;
}

+ (NSArray*) getLEaveRecordArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[LeaveRecordModel getLeaveRecordFromResponse:obj]];
    }
    
    return result;
}
@end
