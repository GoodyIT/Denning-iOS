//
//  BillModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "BillModel.h"

@implementation BillModel

+ (instancetype) getBill:(NSDictionary*) response
{
    BillModel* model = [BillModel new];
    
    model.aging = [response valueForKeyNotNull:@"aging"];
    model.documentNo = [response valueForKeyNotNull:@"documentNo"];
    model.fileNo = [response valueForKeyNotNull:@"fileNo"];
    model.isRental = [response valueForKeyNotNull:@"isRental"];
    model.issueBy = [response valueForKeyNotNull:@"issueBy"];
    model.issueDate = [response valueForKeyNotNull:@"issueDate"];
    model.issueToName = [response valueForKeyNotNull:@"issueToName"];
    model.issueTo1stCode = [StaffModel getStaffFromResponse:[response objectForKeyNotNull:@"issueTo1stCode"]];
    model.primaryClient = [response valueForKeyNotNull:@"primaryClient"];
    model.propertyTitle = [response valueForKeyNotNull:@"propertyTitle"];
    model.relatedDocumentNo = [response valueForKeyNotNull:@"relatedDocumentNo"];
    model.rentalMonth = [response valueForKeyNotNull:@"rentalMonth"];
    model.rentalPrice = [response valueForKeyNotNull:@"rentalPrice"];
    model.spaAdj = [response valueForKeyNotNull:@"spaAdj"];
    model.spaLoan = [response valueForKeyNotNull:@"spaLoan"];
    model.spaPrice = [response valueForKeyNotNull:@"spaPrice"];
    model.matter = [MatterCodeModel getMatterCodeFromResponse:[response objectForKeyNotNull:@"matter"]];
    model.analysis = [TaxInvoiceCalcModel getTaxInvoiceCalcFromResponse:[response objectForKeyNotNull:@"analysis"]];
    model.presetCode = [PresetBillModel getPresetBillFromResponse: [response objectForKeyNotNull:@"presetCode"]];
    
    
    return model;
}

@end
