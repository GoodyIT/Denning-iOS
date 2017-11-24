//
//  MatterSimple.m
//  Denning
//
//  Created by DenningIT on 08/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MatterSimple.h"
#import "ClientModel.h"

@implementation MatterSimple

+ (MatterSimple*) getMatterSimpleFromResponse: (NSDictionary*) response
{
    MatterSimple* matterSimple = [MatterSimple new];
    
    matterSimple.systemNo = [response valueForKeyNotNull:@"systemNo"];
    matterSimple.referenceNo = [response valueForKeyNotNull:@"referenceNo"];
    matterSimple.dateOpen = [response valueForKeyNotNull:@"dateOpen"];
    matterSimple.manualNo = [response valueForKeyNotNull:@"manualNo"];
    matterSimple.matter = [MatterCodeModel getMatterCodeFromResponse: [response objectForKeyNotNull:@"matter"]];
    matterSimple.presetBill = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"presetBill"]];
    matterSimple.partyGroupArray = [PartyGroupModel getPartyGroupArrayFromResponse: [response objectForKeyNotNull:@"partyGroup"]];
    matterSimple.primaryClient = [ClientModel getClientFromResponse:[response objectForKeyNotNull:@"primaryClient"]];
    matterSimple.rentalMonth = [response valueForKeyNotNull:@"rentalMonth"];
    matterSimple.rentalPrice = [response valueForKeyNotNull:@"rentalPrice"];
    matterSimple.spaLoan = [response valueForKeyNotNull:@"spaLoan"];
    matterSimple.spaPrice = [response valueForKeyNotNull:@"spaPrice"];
    
    return matterSimple;
}

+ (NSArray*) getMatterSimpleArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[MatterSimple getMatterSimpleFromResponse:obj]];
    }
    
    return result;
}

@end
