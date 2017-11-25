//
//  PaymentModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "PaymentModel.h"

@implementation PaymentModel

+ (instancetype) getPayment:(NSDictionary*) response
{
    PaymentModel *model = [PaymentModel new];
    
    model.bankBranch = [response valueForKeyNotNull:@"bankBranch"];
    model.issuerBank = [response valueForKeyNotNull:@"issuerBank"];
    model.mode = [response valueForKeyNotNull:@"mode"];
    model.referenceNo = [response valueForKeyNotNull:@"referenceNo"];
    model.totalAmount = [response valueForKeyNotNull:@"totalAmount"];
    
    return model;
}

@end
