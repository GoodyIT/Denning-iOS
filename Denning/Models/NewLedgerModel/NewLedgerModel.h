//
//  NewLedgerModel.h
//  Denning
//
//  Created by DenningIT on 19/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewLedgerModel : NSObject

@property (strong, nonatomic) NSArray<LedgerModel*>* ledgerModelArray;
@property (strong, nonatomic) NSString* fileName;
@property (strong, nonatomic) NSString* fileNo;

+ (NewLedgerModel*) getNewLedgerModelFromResponse: (NSDictionary*) response;
@end
