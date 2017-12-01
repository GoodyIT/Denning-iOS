//
//  TaxModel.h
//  Denning
//
//  Created by DenningIT on 19/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaxModel : NSObject

@property (strong, nonatomic) NSString* aging;
@property (strong, nonatomic) NSString* analysis;
@property (strong, nonatomic) NSString* documentNo;
@property (strong, nonatomic) NSString* fileNo;
@property (strong, nonatomic) NSString* isRental;
@property (strong, nonatomic) NSString* issueDate;
@property (strong, nonatomic) NSString* issueTo1stCode;
@property (strong, nonatomic) NSString* issueToName;
@property (strong, nonatomic) NSString* issueBy;
@property (strong, nonatomic) NSString* propertyTitle;
@property (strong, nonatomic) NSString* primaryClient;
@property (strong, nonatomic) MatterCodeModel* matter;
@property (strong, nonatomic) NSString* presetCode;
@property (strong, nonatomic) NSString* relatedDocumentNo;
@property (strong, nonatomic) NSString* rentalMonth;
@property (strong, nonatomic) NSString* rentalPrice;
@property (strong, nonatomic) NSString* spaLoan;
@property (strong, nonatomic) NSString* spaPrice;


+ (TaxModel*) getTaxFromResponse: (NSDictionary*) response;

+ (NSArray*) getTaxArrayFromResponse: (NSDictionary*) response;

@end
