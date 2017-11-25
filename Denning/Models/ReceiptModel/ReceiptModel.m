//
//  ReceiptModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ReceiptModel.h"

@implementation ReceiptModel

+ (instancetype) getReeipt:(NSDictionary*) response
{
    ReceiptModel *model = [ReceiptModel new];
    
    model.accountType = [AccountTypeModel getAccountTypeFromResponse:[response objectForKeyNotNull:@"accountType"]];
    model.amount = [response valueForKeyNotNull:@""];
    model.descriptionValue = [response valueForKeyNotNull:@"description"];
    model.payment = [PaymentModel getPayment:[response objectForKeyNotNull:@"payment"]];
    model.documentNo = [response valueForKeyNotNull:@"documentNo"];
    model.fileNo = [response valueForKeyNotNull:@"fileNo"];
    model.invoiceNo = [response valueForKeyNotNull:@"invoiceNo"];
    model.receivedFrom = [response valueForKeyNotNull:@"receivedFrom"];
    model.receivedFromName = [response valueForKeyNotNull:@"receivedFromName"];
    model.remarks = [response valueForKeyNotNull:@"remarks"];
    
    return model;
}

@end
