//
//  TaxInvoiceItemModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-23.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TaxInvoiceItemModel.h"

@implementation TaxInvoiceItemModel

+ (NSArray*) getTaxInvoiceItemArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        TaxInvoiceItemModel* model = [TaxInvoiceItemModel new];
        
        model.codeValue = [obj valueForKeyNotNull:@"code"];
        model.descriptionValue = [obj valueForKeyNotNull:@"description"];
        model.amount = [obj valueForKeyNotNull:@"amount"];
        model.rank = [obj valueForKeyNotNull:@"rank"];
        model.itemID = [obj valueForKeyNotNull:@"itemID"];
        
        [result addObject:model];
    }
    
    return result;
}

@end
