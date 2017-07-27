//
//  LedgerDetailModel.m
//  Denning
//
//  Created by DenningIT on 28/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LedgerDetailModel.h"

@implementation LedgerDetailModel

+ (LedgerDetailModel*) getLedgerDetailFromResponse: (NSDictionary*) response
{
    LedgerDetailModel* ledgerDetailModel = [LedgerDetailModel new];
    
    ledgerDetailModel.ChequeNo = [response valueForKeyNotNull:@"ChequeNo"];
    ledgerDetailModel.bankAcc = [response valueForKeyNotNull:@"bankAcc"];
    ledgerDetailModel.amountCR = [response valueForKeyNotNull:@"amountCR"];
    ledgerDetailModel.amount = [[[response valueForKeyNotNull:@"amount"] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
    ledgerDetailModel.amountDR = [response valueForKeyNotNull:@"amountDR"];
    ledgerDetailModel.ledgerCode = [response valueForKeyNotNull:@"code"];
    ledgerDetailModel.date = [response valueForKeyNotNull:@"date"];
    ledgerDetailModel.ledgerDescription = [response valueForKeyNotNull:@"description"];
    ledgerDetailModel.documentNo = [response valueForKeyNotNull:@"documentNo"];
    ledgerDetailModel.displayAmount = [response valueForKeyNotNull:@"displayAmount"];
    ledgerDetailModel.drORcr = [response valueForKeyNotNull:@"drORcr"];
    ledgerDetailModel.fileNo = [response valueForKeyNotNull:@"fileNo"];
    ledgerDetailModel.fileName = [response valueForKeyNotNull:@"fileName"];
    ledgerDetailModel.issuedBy = [response valueForKeyNotNull:@"issuedBy"];
    ledgerDetailModel.recdPaid = [response valueForKeyNotNull:@"recdPaid"];
    ledgerDetailModel.paymentMode = [response valueForKeyNotNull:@"paymentMode"];
    ledgerDetailModel.taxInvoice = [response valueForKeyNotNull:@"taxInvoice"];
    ledgerDetailModel.updatedBy = [response valueForKeyNotNull:@"updatedBy"];
    ledgerDetailModel.isDebit = [response valueForKeyNotNull:@"isDebit"];

    return ledgerDetailModel;
}

+ (NSArray*) getLedgerDetailArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id model in response) {
        [result addObject:[LedgerDetailModel getLedgerDetailFromResponse:model]];
    }
    
    return [result copy];
}
@end
