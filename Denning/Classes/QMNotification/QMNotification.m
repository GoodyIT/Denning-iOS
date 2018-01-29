//
//  QMNotification.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNotification.h"
#import "QMCore.h"
#import "SDWebImageManager.h"

#import "QMStatusStringBuilder.h"
#import "QMMessageNotification.h"

static NSString * const kQMVoipPushNotificationParam = @"ios_voip";

@implementation QMNotification

//MARK: - Message notification

+ (void)showMessageNotificationWithMessage:(QBChatMessage *)chatMessage
                             buttonHandler:(MPGNotificationButtonHandler)buttonHandler
                        hostViewController:(UIViewController *)hvc {
    
    NSParameterAssert(chatMessage.dialogID);
    
    QBChatDialog *chatDialog =
    [QMCore.instance.chatService.dialogsMemoryStorage chatDialogWithID:chatMessage.dialogID];
    
    if (chatDialog == nil) {
        // for some reason chat dialog was not find
        // no reason to show message notification
        return;
    }
    
    NSString *title = nil;
    NSString *imageURLString = nil;
    
    switch (chatDialog.type) {
            
        case QBChatDialogTypePrivate: {
            
            QBUUser *user = [QMCore.instance.usersService.usersMemoryStorage userWithID:chatMessage.senderID];
            imageURLString = user.avatarUrl;
            
            title = user.fullName ?: [NSString stringWithFormat:@"%tu", user.ID];
            
            break;
        }
            
        case QBChatDialogTypeGroup:
        case QBChatDialogTypePublicGroup: {
            
            imageURLString = chatDialog.photo;
            title = chatDialog.name;
            
            break;
        }
    }
    NSString *messageText = chatMessage.text;
    
    if ([chatMessage isNotificationMessage]) {
        
        QMStatusStringBuilder *stringBuilder = [QMStatusStringBuilder new];
        messageText = [stringBuilder messageTextForNotification:chatMessage];
    }
    
    messageNotification().hostViewController = hvc;
    [messageNotification() showNotificationWithTitle:title
                                            subTitle:messageText
                                        iconImageURL:[NSURL URLWithString:imageURLString]
                                       buttonHandler:buttonHandler];
}

+ (void) showMessageNotificationWithTitle:(NSString*)title message: (NSString*) messageText avatarURL:(NSString*)avatarURL buttonHandler:(MPGNotificationButtonHandler)buttonHandler hostViewController:(UIViewController *)hvc
{
//    UIImage *placeholderImage = [UIImage imageNamed:@"default"];
    messageNotification().hostViewController = hvc;
    [messageNotification() showNotificationWithTitle:title
                                            subTitle:messageText
                                        iconImageURL:[NSURL URLWithString:avatarURL]
                                       buttonHandler:buttonHandler];
}

//MARK: - Push notification

+ (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text {
    return [self sendPushNotificationToUsers: [NSString stringWithFormat:@"%tu", user.ID] withText:text extraParams:nil isVoip:NO];
}

+ (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text extraParams:(NSDictionary *)extraParams isVoip:(BOOL)isVoip
{
    return [self sendPushNotificationToUsers: [NSString stringWithFormat:@"%tu", user.ID] withText:text extraParams:extraParams isVoip:NO];
}

+ (BFTask *)sendPushNotificationToUsers:(NSString *)userIDs withText:(NSString *)text extraParams:(NSDictionary *)extraParams isVoip:(BOOL)isVoip {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *message = text;
    QBMEvent *event = [QBMEvent event];
    event.notificationType = QBMNotificationTypePush;
    event.usersIDs = userIDs;
    event.type = QBMEventTypeOneShot;
    // custom params
    NSMutableDictionary *payloadDict = [@{
                                         @"message" : message,
                                         @"ios_badge": @"1",
                                         @"ios_sound": @"default",
                                         } mutableCopy];
    
    if (extraParams.count > 0) {
        [payloadDict addEntriesFromDictionary:extraParams];
    }
    
    if (isVoip) {
        payloadDict[kQMVoipPushNotificationParam] = @"1";
    }
    
    NSError *error = nil;
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:[payloadDict copy] options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    
    event.message = jsonString;
    
    [QBRequest createEvent:event successBlock:^(QBResponse *__unused response, NSArray *__unused events) {
        
        [source setResult:nil];
        
    } errorBlock:^(QBResponse *response) {
        
        [source setError:response.error.error];
    }];
    
    return source.task;
}

//MARK: - Static notifications

QMMessageNotification *messageNotification() {
    
    static QMMessageNotification *messageNotification = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        messageNotification = [[QMMessageNotification alloc] init];
    });
    
    return messageNotification;
}

+ (BFTask *)sendPushMessageToUser:(NSUInteger) userID withUserName:(NSString*)username withMessage:(QBChatMessage *)message
{
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    QBMEvent *event = [QBMEvent event];
    event.notificationType = QBMNotificationTypePush;
    event.usersIDs = [NSString stringWithFormat:@"%zd", userID];
    event.type = QBMEventTypeOneShot;
    
    // custom params
    NSDictionary  *dictPush = @{@"message" : [NSString stringWithFormat:@"%@: %@", username, message.text ],
                                @"ios_badge": @"1",
                                @"ios_sound": @"default",
                                @"dialog_id": message.dialogID, // custom params
                                @"user_id":  event.usersIDs // custom params
                                };
    
    
    NSError *error = nil;
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    
    event.message = jsonString;
    
    [QBRequest createEvent:event successBlock:^(QBResponse *__unused response, NSArray *__unused events) {
        
        [source setResult:nil];
        
    } errorBlock:^(QBResponse *response) {
        
        [source setError:response.error.error];
    }];
    
    return source.task;
}

@end
