//
//  MatterSimple.h
//  Denning
//
//  Created by DenningIT on 08/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ClientModel;
@class MatterCodeModel;
@class PartyGroupModel;
@interface MatterSimple : NSObject

@property (strong, nonatomic) NSString* dateOpen;
@property (strong, nonatomic) NSString* manualNo;
@property (strong, nonatomic) MatterCodeModel *matter;
@property (strong, nonatomic) CodeDescription* presetBill;
@property (strong, nonatomic) NSArray<PartyGroupModel*>* partyGroupArray;
@property (strong, nonatomic) ClientModel* primaryClient;
@property (strong, nonatomic) NSString *referenceNo;
@property (strong, nonatomic) NSString* rentalMonth;
@property (strong, nonatomic) NSString* rentalPrice;
@property (strong, nonatomic) NSString* spaLoan;
@property (strong, nonatomic) NSString* spaPrice;
@property (strong, nonatomic) NSString *systemNo;

+ (MatterSimple*) getMatterSimpleFromResponse: (NSDictionary*) response;

+ (NSArray*) getMatterSimpleArrayFromResponse: (NSDictionary*) response;
@end
