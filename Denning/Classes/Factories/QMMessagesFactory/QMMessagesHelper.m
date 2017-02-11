//
//  QMMessagesHelper.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMessagesHelper.h"

@implementation QMMessagesHelper

#pragma mark - Instances

+ (QBChatMessage *)chatMessageWithText:(NSString *)text senderID:(NSUInteger)senderID chatDialogID:(NSString *)chatDialogID dateSent:(NSDate *)dateSent {
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderID;
    message.markable = YES;
    message.deliveredIDs = @[@(senderID)];
    message.readIDs = @[@(senderID)];
    message.dialogID = chatDialogID;
    message.dateSent = dateSent;
    
    return message;
}

+ (QBChatMessage *)contactRequestNotificationForUser:(QBUUser *)user {
    
    QBChatMessage *notification = notificationForUser(user);
    notification.messageType = QMMessageTypeContactRequest;
    
    return notification;
}

+ (QBChatMessage *)removeContactNotificationForUser:(QBUUser *)user {
    
    QBChatMessage *notification = notificationForUser(user);
    notification.messageType = QMMessageTypeDeleteContactRequest;
    
    return notification;
}

+ (BOOL)isContactRequestMessage:(QBChatMessage *)message {
    
    return message.messageType == QMMessageTypeDeleteContactRequest
    || message.messageType == QMMessageTypeAcceptContactRequest
    || message.messageType == QMMessageTypeRejectContactRequest;
}

#pragma mark - Helpers

static inline QBChatMessage *notificationForUser(QBUUser *user) {
    
    QBChatMessage *notification = [QBChatMessage message];
    notification.recipientID = user.ID;
    notification.text = kQMContactRequestNotificationMessage;
    notification.dateSent = [NSDate date];
    
    return notification;
}

@end
