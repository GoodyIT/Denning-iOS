//
//  CallViewController.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBRTCSession;
@class UsersDataSource;

@interface CallViewController : UIViewController

@property (strong, nonatomic) QBRTCSession *session;
@property (strong, nonatomic) NSUUID *callUUID;

@end
