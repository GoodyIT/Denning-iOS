//
//  PaymentModeModel.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentModeModel : NSObject

@property (strong, nonatomic) NSString* codeValue;
@property (strong, nonatomic) NSString* strDescription;

+ (instancetype) getPaymentModeDesc:(NSDictionary*) response;
+ (NSArray*) getPaymentModeArray:(NSArray*) response;

@end
