//
//  FeeUntransferModel.h
//  Denning
//
//  Created by Ho Thong Mee on 25/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeeUntransferModel : NSObject

@property (strong, nonatomic) NSString* GSTDisb;
@property (strong, nonatomic) NSString* GSTfee;
@property (strong, nonatomic) NSString* fee;
@property (strong, nonatomic) NSString* fileName;
@property (strong, nonatomic) NSString* fileNo;
@property (strong, nonatomic) NSString* invoiceDate;
@property (strong, nonatomic) NSString* invoiceNo;
@property (strong, nonatomic) NSString* transactionDoc;
@property (strong, nonatomic) NSString* transactionID;

+ (FeeUntransferModel*) getFeeUntransferFromResponse:(NSDictionary*) response;

+ (NSArray*) getFeeUntransferArrayFromResponse:(NSArray*) response;
@end
