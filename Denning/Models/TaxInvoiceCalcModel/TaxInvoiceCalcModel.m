//
//  TaxInvoiceCalcModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-23.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TaxInvoiceCalcModel.h"

@implementation TaxInvoiceCalcModel

+ (instancetype) getTaxInvoiceCalcFromResponse:(NSDictionary*) response
{
    TaxInvoiceCalcModel* model = [TaxInvoiceCalcModel new];
    
    model.decDisb = [response valueForKeyNotNull:@"decDisb"];
    model.decDisbGST = [response valueForKeyNotNull:@"decDisbGST"];
    model.decFees = [response valueForKeyNotNull:@"decFees"];
    model.decGST = [response valueForKeyNotNull:@"decGST"];
    model.decTotal = [response valueForKeyNotNull:@"decTotal"];
    
    model.Disb = [TaxInvoiceItemModel getTaxInvoiceItemArrayFromResponse:[response objectForKeyNotNull:@"Disb"]];
    
    model.DisbGST = [TaxInvoiceItemModel getTaxInvoiceItemArrayFromResponse:[response objectForKeyNotNull:@"DisbGST"]];
    model.Fees = [TaxInvoiceItemModel getTaxInvoiceItemArrayFromResponse:[response objectForKeyNotNull:@"Fees"]];
    model.GST = [TaxInvoiceItemModel getTaxInvoiceItemArrayFromResponse:[response objectForKeyNotNull:@"GST"]];
    
    return model;
}

@end
