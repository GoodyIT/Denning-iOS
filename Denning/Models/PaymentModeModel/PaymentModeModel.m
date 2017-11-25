//
//  PaymentModeModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "PaymentModeModel.h"

@implementation PaymentModeModel

+ (instancetype) getPaymentModeDesc:(NSDictionary*) response
{
    PaymentModeModel* model = [PaymentModeModel new];
    
    model.codeValue = [response valueForKeyNotNull:@"code"];
    model.strDescription = [response valueForKeyNotNull:@"strDescription"];
    
    return model;
}

+ (NSArray*) getPaymentModeArray:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in response) {
        [result addObject:[PaymentModeModel getPaymentModeDesc:obj]];
    }
    
    return result;
}

@end
