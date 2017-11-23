//
//  TaxInvoiceItemModel.h
//  Denning
//
//  Created by Denning IT on 2017-11-23.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaxInvoiceItemModel : NSObject

@property (strong, nonatomic) NSString* amount;

@property (strong, nonatomic) NSString* codeValue;

@property (strong, nonatomic) NSString* descriptionValue;

@property (strong, nonatomic) NSString* itemID;

@property (strong, nonatomic) NSString* rank;

+ (NSArray*) getTaxInvoiceItemArrayFromResponse:(NSArray*) response;

@end
