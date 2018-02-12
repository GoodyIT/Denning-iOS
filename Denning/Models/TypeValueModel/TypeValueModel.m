//
//  TypeValueModel.m
//  Denning
//
//  Created by DenningIT on 20/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TypeValueModel.h"

@implementation TypeValueModel

+ (TypeValueModel*) getTypeValueFromResponse: (NSDictionary*) resposne
{
    TypeValueModel *model = [TypeValueModel new];
    model.type = [resposne objectForKeyNotNull:@"type"];
    model.value = [resposne objectForKeyNotNull:@"value"];
    return model;
}

+ (NSArray*) getTypeValueArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray* result = [NSMutableArray new];
    for (id obj in response) {
        [result addObject:[TypeValueModel getTypeValueFromResponse:obj]];
    }
    return result;
}
@end
