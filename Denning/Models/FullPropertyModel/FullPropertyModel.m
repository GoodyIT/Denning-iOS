//
//  FullPropertyModel.m
//  Denning
//
//  Created by DenningIT on 18/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FullPropertyModel.h"

@implementation FullPropertyModel

+ (FullPropertyModel*) getFullPropertyFromResponse:(NSDictionary*) response
{
    FullPropertyModel* model = [FullPropertyModel new];
    
    model.propertyCode = [response valueForKeyNotNull:@"code"];
    model.fullTitle = [response valueForKeyNotNull:@"fullTitle"];
    model.address = [response valueForKeyNotNull:@"address"];
    model.projectName = [response valueForKeyNotNull:@"projectName"];
    model.spaCondoName = [response valueForKeyNotNull:@"spaCondoName"];
    model.spaParcel = [TypeValueModel getTypeValueFromResponse:[response objectForKeyNotNull:@"spaParcel"]];

    return model;
}

+ (NSArray*) getFullPropertyArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[FullPropertyModel getFullPropertyFromResponse:obj]];
    }
    
    return result;
}

@end
