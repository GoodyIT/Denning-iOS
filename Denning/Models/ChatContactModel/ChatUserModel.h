//
//  ChatUserModel.h
//  Denning
//
//  Created by DenningIT on 14/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatUserModel : NSObject

@property (strong, nonatomic) NSString* avatar_url;

@property (strong, nonatomic) NSString* email;

@property (strong, nonatomic) NSString* firm;

@property (strong, nonatomic) NSString* firmCode;

@property (strong, nonatomic) NSString* position;

+ (ChatUserModel*) getChatUserModelFromResponse: (NSDictionary*) response;

+ (NSArray*) getChatUserModelArrayFromResponse: (NSArray*) response;
@end
