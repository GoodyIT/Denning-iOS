//
//  QuotationModel.h
//  Denning
//
//  Created by DenningIT on 16/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TaxInvoiceCalcModel;

@interface QuotationModel : NSObject

@property (strong, nonatomic) TaxInvoiceCalcModel* analysis;
@property (strong, nonatomic) NSString* documentNo;
@property (strong, nonatomic) NSString* fileNo;
@property (strong, nonatomic) NSString* isRental;
@property (strong, nonatomic) NSString* issueDate;
@property (strong, nonatomic) NSString* issueTo1stCode;
@property (strong, nonatomic) NSString* issueToName;
@property (strong, nonatomic) NSString* issueBy;
@property (strong, nonatomic) NSString* propertyTitle;
@property (strong, nonatomic) NSString* primaryClient;
@property (strong, nonatomic) NSString* matter;
@property (strong, nonatomic) NSString* presetCode;
@property (strong, nonatomic) NSString* relatedDocumentNo;
@property (strong, nonatomic) NSString* rentalMonth;
@property (strong, nonatomic) NSString* rentalPrice;
@property (strong, nonatomic) NSString* spaLoan;
@property (strong, nonatomic) NSString* spaPrice;


+ (QuotationModel*) getQuotationFromResponse: (NSDictionary*) response;

+ (NSArray*) getQuotationArrayFromResponse: (NSDictionary*) response;
@end
