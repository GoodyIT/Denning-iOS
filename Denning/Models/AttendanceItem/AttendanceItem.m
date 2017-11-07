//
//  AttendanceItem.m
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AttendanceItem.h"

@implementation AttendanceItem

+(AttendanceItem*) getAttendanceItemFromResponse:(NSDictionary*) response
{
    AttendanceItem* model = [AttendanceItem new];
    
    model.theLocation = [response valueForKeyNotNull:@"theLocation"];
    model.theTime = [response valueForKeyNotNull:@"theTime"];
    model.theType = [response valueForKeyNotNull:@"theType"];
    
    return model;
}

+ (NSArray*) getAttendanceItemArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[AttendanceItem getAttendanceItemFromResponse:obj]];
    }
    
    return result;
}

@end
