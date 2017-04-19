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
    
    result.firmCode = [response objectForKey:@"firmCode"];
    result.firmName = [response objectForKey:@"firmName"];
    result.users = [ChatUserModel getChatUserModelArrayFromResponse:[response objectForKey:@"users"]];
    
    return result;
}

@end
