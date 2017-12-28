//
//  ChatFirmModel.h
//  Denning
//
//  Created by DenningIT on 14/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatUserModel;
@interface ChatFirmModel : NSObject

@property (strong, nonatomic) NSString* firmCode;

@property (strong, nonatomic) NSString* firmName;

@property (strong, nonatomic) NSArray* users;

+ (NSArray*) getChatFirmModelArrayFromResponse: (NSDictionary*) response;

+ (ChatFirmModel*) getChatFirmModelFromResponse: (NSArray*) response;

@end
