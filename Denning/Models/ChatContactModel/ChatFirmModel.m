//
//  ChatFirmModel.m
//  Denning
//
//  Created by DenningIT on 14/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ChatFirmModel.h"
#import "ChatUserModel.h"

@implementation ChatFirmModel


+ (NSArray*) getChatFirmModelArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray* result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[ChatFirmModel getChatFirmModelFromResponse:obj]];
    }
    
    return result;
}

+ (ChatFirmModel*) getChatFirmModelFromResponse: (NSDictionary*) response
{
    ChatFirmModel* result = [ChatFirmModel new];
    
    result.firmCode = [response valueForKeyNotNull:@"firmCode"];
    result.firmName = [response valueForKeyNotNull:@"firmName"];
    result.users = [ChatUserModel getChatUserModelArrayFromResponse:[response objectForKeyNotNull:@"users"]];
    
    return result;
}

@end
