//
//  FeeTranserModel.h
//  Denning
//
//  Created by Ho Thong Mee on 30/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeeTranserModel : NSObject

@property (strong, nonatomic) NSString* API;
@property (strong, nonatomic) NSString* batchDate;
@property (strong, nonatomic) NSString* batchNo;
@property (strong, nonatomic) NSString* totalAmount;
@property (strong, nonatomic) NSString* totalFile;

+ (FeeTranserModel*) getFeeTranserFromResponse: (NSDictionary*) response;

+ (NSArray*) getFeeTranserArrayFromResponse: (NSArray*) response;
@end
