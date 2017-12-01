//
//  TaxModel.m
//  Denning
//
//  Created by DenningIT on 19/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TaxModel.h"

@implementation TaxModel

+ (TaxModel*) getTaxFromResponse: (NSDictionary*) response
{
    TaxModel* model = [TaxModel new];
    
    model.aging = [response valueForKeyNotNull:@"aging"];
    model.analysis = [response valueForKeyNotNull:@"analysis"];
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
    model.presetCode = [response valueForKeyNotNull:@"presetCode"];
    model.relatedDocumentNo = [response valueForKeyNotNull:@"relatedDocumentNo"];
    model.rentalMonth = [response valueForKeyNotNull:@"rentalMonth"];
    model.rentalPrice = [response valueForKeyNotNull:@"rentalPrice"];
    model.spaLoan = [response valueForKeyNotNull:@"spaLoan"];
    model.spaPrice = [response valueForKeyNotNull:@"spaPrice"];
    
    return model;
}

+ (NSArray*) getTaxArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[TaxModel getTaxFromResponse:obj]];
    }
    
    return result;
}
@end
