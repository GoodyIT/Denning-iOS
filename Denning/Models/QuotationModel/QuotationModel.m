//
//  QuotationModel.m
//  Denning
//
//  Created by DenningIT on 16/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "QuotationModel.h"

@implementation QuotationModel

+ (QuotationModel*) getQuotationFromResponse: (NSDictionary*) response
{
    QuotationModel* model = [QuotationModel new];
    
    model.analysis = [TaxInvoiceCalcModel getTaxInvoiceCalcFromResponse:[response objectForKeyNotNull:@"analysis"]];
    model.documentNo = [response valueForKeyNotNull:@"documentNo"];
    model.fileNo = [response valueForKeyNotNull:@"fileNo"];
    model.isRental = [response valueForKeyNotNull:@"isRental"];
    model.issueDate = [response valueForKeyNotNull:@"issueDate"];
    model.issueTo1stCode = [response valueForKeyNotNull:@"issueTo1stCode"];
    model.issueToName = [response valueForKeyNotNull:@"issueToName"];
    model.issueBy = [response valueForKeyNotNull:@"issueBy"];
    model.primaryClient = [response valueForKeyNotNull:@"primaryClient"];
    model.propertyTitle = [response valueForKeyNotNull:@"propertyTitle"];
    model.matter = [MatterCodeModel getMatterCodeFromResponse:[response objectForKeyNotNull:@"matter"]];
    model.presetCode = [PresetCodeModel getPresetCode:[response objectForKeyNotNull:@"presetCode"]];
    model.relatedDocumentNo = [response valueForKeyNotNull:@"relatedDocumentNo"];
    model.rentalMonth = [response valueForKeyNotNull:@"rentalMonth"];
    model.rentalPrice = [response valueForKeyNotNull:@"rentalPrice"];
    model.spaLoan = [response valueForKeyNotNull:@"spaLoan"];
    model.spaPrice = [response valueForKeyNotNull:@"spaPrice"];
    
    return model;
}

+ (NSArray*) getQuotationArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[QuotationModel getQuotationFromResponse:obj]];
    }
    
    return result;
}

@end
