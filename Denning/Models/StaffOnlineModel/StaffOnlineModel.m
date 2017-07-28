//
//  StaffOnlineModel.m
//  Denning
//
//  Created by Ho Thong Mee on 17/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "StaffOnlineModel.h"

@implementation StaffOnlineModel

+ (StaffOnlineModel*) getStaffOnlineFromResponse:(NSDictionary*) response
{
    StaffOnlineModel* model = [StaffOnlineModel new];
    
    model.API = [response valueForKeyNotNull:@"API"];
    model.device = [response valueForKeyNotNull:@"device"];
    model.inTime = [response valueForKeyNotNull:@"inTime"];
    model.name = [response valueForKeyNotNull:@"name"];
    model.totalHour = [response valueForKeyNotNull:@"totalHour"];
    model.outTime = [response valueForKeyNotNull:@"outTime"];
    model.status = [response valueForKeyNotNull:@"status"];
    
    return model;
}

+ (NSArray*) getStaffOnlineArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[StaffOnlineModel getStaffOnlineFromResponse:obj]];
    }
    
    return result;

}

@end
