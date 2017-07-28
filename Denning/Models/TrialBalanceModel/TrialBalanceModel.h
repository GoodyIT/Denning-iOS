//
//  TrialBalanceModel.h
//  Denning
//
//  Created by Ho Thong Mee on 15/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrialBalanceModel : NSObject

@property (strong, nonatomic) NSString* APIcredit;
@property (strong, nonatomic) NSString* APIdebit;
@property (strong, nonatomic) NSString* accountName;
@property (strong, nonatomic) NSString* accountType;
@property (strong, nonatomic) NSString* credit;
@property (strong, nonatomic) NSString* debit;
@property (strong, nonatomic) NSString* isBalance;

+ (TrialBalanceModel*) getTrialBalanceFromResponse:(NSDictionary*) response;

+ (NSArray*) getTrialBalanceArrayFromResponse:(NSArray*) response;

@end
