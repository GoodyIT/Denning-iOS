//
//  BillModel.h
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TaxInvoiceCalcModel;
@class PresetBillModel;
@class StaffModel;

@interface BillModel : NSObject

@property (strong, nonatomic) NSString* aging;
@property (strong, nonatomic) TaxInvoiceCalcModel* analysis;
@property (strong, nonatomic) NSString* documentNo;
@property (strong, nonatomic) NSString* fileNo;
@property (strong, nonatomic) NSString* isRental;
@property (strong, nonatomic) NSString* issueBy;
@property (strong, nonatomic) NSString* issueDate;
@property (strong, nonatomic) NSString* issueToName;
@property (strong, nonatomic) StaffModel* issueTo1stCode;
@property (strong, nonatomic) PresetBillModel* presetCode;
@property (strong, nonatomic) MatterCodeModel* matter;
@property (strong, nonatomic) NSString* primaryClient;
@property (strong, nonatomic) NSString* propertyTitle;
@property (strong, nonatomic) NSString* relatedDocumentNo;
@property (strong, nonatomic) NSString* rentalMonth;
@property (strong, nonatomic) NSString* rentalPrice;
@property (strong, nonatomic) NSString* spaAdj;
@property (strong, nonatomic) NSString* spaLoan;
@property (strong, nonatomic) NSString* spaPrice;

+ (instancetype) getBill:(NSDictionary*) response;

@end
