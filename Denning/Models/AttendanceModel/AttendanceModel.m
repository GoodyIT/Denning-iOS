//
//  AttendanceModel.m
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AttendanceModel.h"
#import "AttendanceInfo.h"
#import "AttendanceModel.h"

@implementation AttendanceModel

+(AttendanceModel*) getAttendanceModelFromResponse:(NSDictionary*) response
{
    AttendanceModel* model = [AttendanceModel new];
    
    model.btnLeft = [response valueForKeyNotNull:@"btnLeft"];
    model.btnRight = [response valueForKeyNotNull:@"btnRight"];
    model.clsStaff = [AttendanceInfo getAttendanceInfoFromResonse:[response objectForKeyNotNull:@"clsStaff"]];
    model.dtDate = [response valueForKeyNotNull:@"dtDate"];
    model.theListing = [AttendanceItem getAttendanceItemArrayFromResponse:[response objectForKeyNotNull:@"theListing"]];
    model.totalWorkingHours = [response valueForKeyNotNull:@"totalWorkingHours"];
    
    return model;
}

@end
