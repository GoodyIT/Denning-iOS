//
//  TaxInvoiceCalcModel.h
//  Denning
//
//  Created by Denning IT on 2017-11-23.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaxInvoiceCalcModel : NSObject

@property (strong, nonatomic) NSArray<TaxInvoiceItemModel*>* Disb;
@property (strong, nonatomic) NSArray<TaxInvoiceItemModel*>* DisbGST;
@property (strong, nonatomic) NSArray<TaxInvoiceItemModel*>* Fees;
@property (strong, nonatomic) NSArray<TaxInvoiceItemModel*>* GST;

@property (strong, nonatomic) NSString* decDisb;
@property (strong, nonatomic) NSString* decDisbGST;
@property (strong, nonatomic) NSString* decFees;
@property (strong, nonatomic) NSString* decGST;
@property (strong, nonatomic) NSString* decTotal;

+ (instancetype) getTaxInvoiceCalcFromResponse:(NSDictionary*) response;

@end
