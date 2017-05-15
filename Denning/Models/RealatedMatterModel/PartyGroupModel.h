//
//  PartyGroupModel.h
//  Denning
//
//  Created by DenningIT on 27/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PartyGroupModel : NSObject
@property (strong, nonatomic) NSString* partyGroupName;
@property (strong, nonatomic) NSArray* partyArray;

+(NSArray*) getPartyGroupArrayFromResponse: (NSArray*) response;
@end
