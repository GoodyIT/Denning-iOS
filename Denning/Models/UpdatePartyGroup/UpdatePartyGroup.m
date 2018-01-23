//
//  UpdatePartyGroup.m
//  Denning
//
//  Created by Denning IT on 2018-01-17.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import "UpdatePartyGroup.h"

@implementation UpdatePartyGroup

+ (instancetype) updatePartyGroup:(PartyGroupModel*) partyGroup
{
    UpdatePartyGroup *model = [UpdatePartyGroup new];
    
    model.groupName = partyGroup.partyGroupName;
    model.partys = [NameCode getNameCodeArray:partyGroup.partyArray];
    
    return model;
}

@end
