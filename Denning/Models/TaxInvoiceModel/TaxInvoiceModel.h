//
//  TaxInvoiceModel.h
//  Denning
//
//  Created by Ho Thong Mee on 30/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaxInvoiceModel : NSObject

@property (strong, nonatomic) NSString* APIpdf;
@property (strong, nonatomic) NSString* amount;
@property (strong, nonatomic) NSString* fileName;
@property (strong, nonatomic) NSString* fileNo;
@property (strong, nonatomic) NSString* invoiceNo;
@property (strong, nonatomic) NSString* issueToName;

+ (TaxInvoiceModel*) getTaxInvoiceFromResponse: (NSDictionary*) response;

+ (NSArray*) getTaxInvoiceArrayFromResonse: (NSDictionary*) response;

@end
