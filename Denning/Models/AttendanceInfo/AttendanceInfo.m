//
//  AttendnaceInfo.m
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AttendanceInfo.h"

@implementation AttendanceInfo

+(AttendanceInfo*) getAttendanceInfoFromResonse:(NSDictionary*) response
{
    AttendanceInfo* model = [AttendanceInfo new];
    
    model.attendanceCode = [response valueForKeyNotNull:@"code"];
    model.strIdNo = [response valueForKeyNotNull:@"strIdNo"];
    model.strInitials = [response valueForKeyNotNull:@"strInitials"];
    model.strName = [response valueForKeyNotNull:@"strName"];
    model.strPositionTitle = [response valueForKeyNotNull:@"strPositionTitle"];
    
    return model;
}

+(NSArray*) getAttendanceInfoArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[AttendanceInfo getAttendanceInfoFromResonse:obj]];
    }
    
    return result;
}

@end
