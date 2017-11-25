//
//  PaymentModel.h
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentModel : NSObject

@property (strong, nonatomic) NSString* bankBranch;
@property (strong, nonatomic) NSString* issuerBank;
@property (strong, nonatomic) NSString* mode;
@property (strong, nonatomic) NSString* referenceNo;
@property (strong, nonatomic) NSString* totalAmount;

+ (instancetype) getPayment:(NSDictionary*) response;

@end
