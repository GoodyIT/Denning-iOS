//
//  FeeTranserModel.m
//  Denning
//
//  Created by Ho Thong Mee on 30/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FeeTranserModel.h"

@implementation FeeTranserModel
+ (FeeTranserModel*) getFeeTranserFromResponse: (NSDictionary*) response
{
    FeeTranserModel *model = [FeeTranserModel new];
    
    model.API = [response valueForKeyNotNull:@"API"];
    model.batchDate = [response valueForKeyNotNull:@"batchDate"];
    model.batchNo = [response valueForKeyNotNull:@"batchNo"];
    model.totalAmount = [response valueForKeyNotNull:@"totalAmount"];
    model.totalFile = [response valueForKeyNotNull:@"totalFile"];
    
    return model;
}

+ (NSArray*) getFeeTranserArrayFromResponse: (NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in response) {
        [result addObject:[FeeTranserModel getFeeTranserFromResponse:obj]];
    }
    
    return result;
}
@end
