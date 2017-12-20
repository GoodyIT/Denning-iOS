//
//  ChatContactModel.h
//  Denning
//
//  Created by DenningIT on 05/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatFirmModel;

@interface ChatContactModel : NSObject

@property (strong, nonatomic) NSString* dtExpire;
@property (strong, nonatomic) NSNumber* isExpire;

@property (strong, nonatomic) NSArray<ChatFirmModel*>* staffContacts;

@property (strong, nonatomic) NSArray<ChatFirmModel*>* clientContacts;

@property (strong, nonatomic) NSArray<ChatFirmModel*>* denningContacts;

@property (strong, nonatomic) NSArray<ChatFirmModel*>* favStaffContacts;

@property (strong, nonatomic) NSArray<ChatFirmModel*>* favClientContacts;

+ (ChatContactModel*) getChatContactFromResponse: (NSDictionary*) response;

@end
