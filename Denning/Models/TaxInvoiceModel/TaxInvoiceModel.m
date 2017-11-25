//
//  TaxInvoiceModel.m
//  Denning
//
//  Created by Ho Thong Mee on 30/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TaxInvoiceModel.h"

@implementation TaxInvoiceModel

+ (TaxInvoiceModel*) getTaxInvoiceFromResponse: (NSDictionary*) response
{
    TaxInvoiceModel *model = [TaxInvoiceModel new];
    
    model.APIpdf = [response valueForKeyNotNull:@"APIpdf"];
    model.amount = [response valueForKeyNotNull:@"amount"];
    model.fileName = [response valueForKeyNotNull:@"fileName"];
    model.fileNo = [response valueForKeyNotNull:@"fileNo"];
    model.invoiceNo = [response valueForKeyNotNull:@"invoiceNo"];
    model.issueToName = [response valueForKeyNotNull:@"issueToName"];
    
    return model;
}

+ (NSArray*) getTaxInvoiceArrayFromResonse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in response) {
        [result addObject:[TaxInvoiceModel getTaxInvoiceFromResponse:obj]];
    }
    
    return result;
}
@end
