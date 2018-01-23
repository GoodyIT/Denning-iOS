//
//  UpdatePartyGroup.h
//  Denning
//
//  Created by Denning IT on 2018-01-17.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdatePartyGroup : NSObject

@property (strong, nonatomic) NSString* groupName;
@property (strong, nonatomic) NSMutableArray<NameCode*>* partys;

+ (instancetype) updatePartyGroup:(PartyGroupModel*) partyGroup;

@end
