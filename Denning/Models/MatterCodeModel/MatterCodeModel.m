//
//  MatterCodeModel.m
//  Denning
//
//  Created by DenningIT on 12/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MatterCodeModel.h"

@implementation MatterCodeModel

+ (MatterCodeModel*) getMatterCodeFromResponse:(NSDictionary*) response
{
    MatterCodeModel* model = [MatterCodeModel new];
    if (response == nil) {
        model.category = @"";
        model.matterCode = @"";
        model.matterDescription = @"";
        model.department = @"";
        model.formName = @"";
        model.groupName1 = @"";
        model.groupName2 = @"";
        model.groupName3 = @"";
        model.groupName4 = @"";
        model.groupName5 = @"";
        model.isRental = @"";
        model.turnAround = @"";
        return model;
    }
    model.category = [response valueForKeyNotNull:@"category"];
    model.matterCode = [response valueForKeyNotNull:@"code"];
    model.matterDescription = [response valueForKeyNotNull:@"description"];
    model.department = [response valueForKeyNotNull:@"department"];
    model.formName = [response valueForKeyNotNull:@"formName"];
    model.groupName1 = [response valueForKeyNotNull:@"groupName1"];
    model.groupName2 = [response valueForKeyNotNull:@"groupName2"];
    model.groupName3 = [response valueForKeyNotNull:@"groupName3"];
    model.groupName4 = [response valueForKeyNotNull:@"groupName4"];
    model.groupName5 = [response valueForKeyNotNull:@"groupName5"];
    model.isRental = [response valueForKeyNotNull:@"isRental"];
    model.turnAround = [response valueForKeyNotNull:@"turnAround"];
    
    return model;
}

+ (NSArray*) getMatterCodeArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[MatterCodeModel getMatterCodeFromResponse:obj]];
    }
    
    return result;
}
@end
