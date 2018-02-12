//
//  CoramModel.m
//  Denning
//
//  Created by DenningIT on 08/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CoramModel.h"

@implementation CoramModel

+ (CoramModel*) getCoramFromResponse: (NSDictionary*) response
{
    CoramModel *coram = [CoramModel new];
    if (response) {
        coram.coramCode = [response valueForKeyNotNull:@"code"];
        coram.courtType = [response valueForKeyNotNull:@"courtType"];
        coram.position = [response valueForKeyNotNull:@"position"];
        coram.name = [response valueForKeyNotNull:@"name"];
    } else {
        coram.coramCode = @"";
        coram.courtType = @"";
        coram.name = @"";
        coram.position = @"";
    }
    
    return coram;
}

+ (NSArray*) getCoramArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[CoramModel getCoramFromResponse:obj]];
    }
    
    return result;
}

@end
