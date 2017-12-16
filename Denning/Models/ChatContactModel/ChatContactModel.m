//
//  ChatContactModel.m
//  Denning
//
//  Created by DenningIT on 05/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ChatContactModel.h"
#import "ChatFirmModel.h"

@implementation ChatContactModel

+ (ChatContactModel*) getChatContactFromResponse: (NSDictionary*) response
{
    ChatContactModel* chatContactModel = [ChatContactModel new];
    
    chatContactModel.dtExpire = [response valueForKeyNotNull:@"dtExpire"];
    chatContactModel.isExpire = [response valueForKeyNotNull:@"isExpire"];
    
    chatContactModel.clientContacts = [ChatFirmModel getChatFirmModelArrayFromResponse:[response objectForKey:@"client"]];
    chatContactModel.staffContacts = [ChatFirmModel getChatFirmModelArrayFromResponse:[response objectForKey:@"staff"]];
    chatContactModel.favClientContacts = [ChatFirmModel getChatFirmModelArrayFromResponse:[response objectForKey:@"favourite_client"]];
    chatContactModel.favStaffContacts = [ChatFirmModel getChatFirmModelArrayFromResponse:[response objectForKey:@"favourite_staff"]];
    
    return chatContactModel;
}

@end
