//
//  LedgerDetailModel.h
//  Denning
//
//  Created by DenningIT on 28/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LedgerDetailModel : NSObject

@property (strong, nonatomic) NSString* ChequeNo;
@property (strong, nonatomic) NSString* bankAcc;
@property (strong, nonatomic) NSString* amountCR;
@property (strong, nonatomic) NSString* amountDR;
@property (strong, nonatomic) NSString* amount;
@property (strong, nonatomic) NSString* ledgerCode;
@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSString* fileNo;
@property (strong, nonatomic) NSString* fileName;
@property (strong, nonatomic) NSString* ledgerDescription;
@property (strong, nonatomic) NSString* displayAmount;
@property (strong, nonatomic) NSString* documentNo;
@property (strong, nonatomic) NSString* drORcr;
@property (strong, nonatomic) NSString* recdPaid;
@property (strong, nonatomic) NSString* issuedBy;
@property (strong, nonatomic) NSString* updatedBy;
@property (strong, nonatomic) NSString* paymentMode;
@property (strong, nonatomic) NSString* taxInvoice;
@property (strong, nonatomic) NSString* isDebit;

+ (LedgerDetailModel*) getLedgerDetailFromResponse: (NSDictionary*) response;

+ (NSArray*) getLedgerDetailArrayFromResponse: (NSDictionary*) response;

@end
