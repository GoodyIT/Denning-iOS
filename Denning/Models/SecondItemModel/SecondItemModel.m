//
//  SecondItemModel.m
//  Denning
//
//  Created by Ho Thong Mee on 22/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "SecondItemModel.h"

@implementation SecondItemModel


+ (SecondItemModel*) getSecondItemFromResponse:(NSDictionary*) response
{
    SecondItemModel* model = [SecondItemModel new];
    
    model.OR = [response valueForKeyNotNull:@"OR"];
    model.RM = [response valueForKeyNotNull:@"RM"];
    model.api = [response valueForKeyNotNull:@"api"];
    model.deposited = [response valueForKeyNotNull:@"deposited"];
    model.itemId = [response valueForKeyNotNull:@"itemId"];
    model.label = [response valueForKeyNotNull:@"label"];
    model.formName = [response valueForKeyNotNull:@"formName"];
    
    return model;
}

+ (NSArray*) getSecondItemArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in response) {
        [result addObject:[SecondItemModel getSecondItemFromResponse:obj]];
    }
    
    return result;
}

@end
