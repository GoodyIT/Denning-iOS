//
//  FeeUntransferModel.m
//  Denning
//
//  Created by Ho Thong Mee on 25/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FeeUntransferModel.h"

@implementation FeeUntransferModel

+ (FeeUntransferModel*) getFeeUntransferFromResponse:(NSDictionary*) response
{
    FeeUntransferModel* model = [FeeUntransferModel new];
    
    model.GSTDisb = [response valueForKeyNotNull:@"GSTDisb"];
    model.GSTfee = [response valueForKeyNotNull:@"GSTfee"];
    model.fee = [response valueForKeyNotNull:@"fee"];
    model.fileName = [response valueForKeyNotNull:@"fileName"];
    model.fileNo = [response valueForKeyNotNull:@"fileNo"];
    model.invoiceNo = [response valueForKeyNotNull:@"invoiceNo"];
    model.invoiceDate = [response valueForKeyNotNull:@"invoiceDate"];
    model.transactionID = [response valueForKeyNotNull:@"transactionID"];
    model.transactionDoc = [response valueForKeyNotNull:@"transactionDoc"];
    
    return model;
}

+ (NSArray*) getFeeUntransferArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[FeeUntransferModel getFeeUntransferFromResponse:obj]];
    }
    
    return result;
}

@end
