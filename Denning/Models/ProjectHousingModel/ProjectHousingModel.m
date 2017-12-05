//
//  ProjectHousingModel.m
//  Denning
//
//  Created by DenningIT on 17/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ProjectHousingModel.h"

@implementation ProjectHousingModel

+ (ProjectHousingModel*) getProjectHousingFromResponse: (NSDictionary*) response
{
    ProjectHousingModel* model = [ProjectHousingModel new];
    
    model.housingCode = [response valueForKeyNotNull:@"code"];
    model.developer = [StaffModel getStaffFromResponse:[response objectForKeyNotNull:@"developer"]];
    model.licenseNo = [response valueForKeyNotNull:@"licenseNo"];
    model.masterTitle = [response valueForKeyNotNull:@"masterTitle"];
    model.name = [response valueForKeyNotNull:@"name"];
    model.phase = [response valueForKeyNotNull:@"phase"];
    model.proprietor = [StaffModel getStaffFromResponse:[response objectForKeyNotNull:@"proprietor"]];
    
    return model;
}

+ (NSArray*) getProjectHousingArrayFromResponse:(NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[ProjectHousingModel getProjectHousingFromResponse:obj]];
    }
    
    return result;
}

@end
