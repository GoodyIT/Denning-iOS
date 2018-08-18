//
//  MaterTitleModel.m
//  Denning
//
//  Created by Ho Thong Mee on 26/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MasterTitleModel.h"

@implementation MasterTitleModel

+ (MasterTitleModel*) getMasterTitleFromResponse:(NSDictionary*) response
{
    MasterTitleModel* model = [MasterTitleModel new];
    
    if (response == nil) {
        model.address = model.masterCode = model.fullTitle = @"";
    } else {
        model.address = [response valueForKeyNotNull:@"address"];
        model.masterCode = [response valueForKeyNotNull:@"code"];
        model.fullTitle = [response valueForKeyNotNull:@"fullTitle"];
    }
    
    return model;
}

+ (NSArray*) getMasterTitleArrayFromResponse: (NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in response) {
        [result addObject:[MasterTitleModel getMasterTitleFromResponse:obj]];
    }
    
    return result;
}

@end
