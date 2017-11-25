//
//  ReceiptModel.h
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiptModel : NSObject

@property (strong, nonatomic) AccountTypeModel* accountType;
@property (strong, nonatomic) NSString* amount;
@property (strong, nonatomic) NSString* descriptionValue;
@property (strong, nonatomic) NSString* documentNo;
@property (strong, nonatomic) NSString* fileNo;
@property (strong, nonatomic) NSString* invoiceNo;
@property (strong, nonatomic) PaymentModel* payment;
@property (strong, nonatomic) NSString* receivedFrom;
@property (strong, nonatomic) NSString* receivedFromName;
@property (strong, nonatomic) NSString* remarks;

+ (instancetype) getReeipt:(NSDictionary*) response;

@end
