//
//  QMContactManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/25/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactManager.h"
#import "QMCore.h"
#import "QMNotification.h"
#import "QMMessagesHelper.h"
#import "QMDateUtils.h"

@interface QMContactManager ()

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;

@end

@implementation QMContactManager

@dynamic serviceManager;

//MARK: - Contacts management

- (BFTask *)addUserToContactList:(QBUUser *)user {
    
    // determine whether we have already received contact request from user or not
    QBChatDialog *chatDialog = [self.serviceManager.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
    QBChatMessage *lastMessage = [self.serviceManager.chatService.messagesMemoryStorage lastMessageFromDialogID:chatDialog.ID];
    
    QBContactListItem *contactListItem = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
    
    if (lastMessage.messageType == QMMessageTypeContactRequest
        && lastMessage.senderID != self.serviceManager.currentProfile.userData.ID
        && contactListItem == nil) {
        
        return [self confirmAddContactRequest:user];
    }
    else {
        
        @weakify(self);
        return [[[self.serviceManager.contactListService addUserToContactListRequest:user] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
            
            @strongify(self);
            return [self.serviceManager.chatService createPrivateChatDialogWithOpponent:user];
            
        }] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
            
            @strongify(self);
            QBChatMessage *chatMessage = [QMMessagesHelper contactRequestNotificationForUser:user];
            [self.serviceManager.chatService sendMessage:chatMessage
                                                    type:chatMessage.messageType
                                                toDialog:task.result
                                           saveToHistory:YES
                                           saveToStorage:YES
                                              completion:nil];
            
            NSString *notificationMessage = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_OPPONENT", nil), self.serviceManager.currentProfile.userData.fullName];
            
            [QMNotification sendPushNotificationToUser:user withText:notificationMessage];
            
            return nil;
        }];
    }
}

- (BFTask *)confirmAddContactRequest:(QBUUser *)user {
    
    @weakify(self);
    return [[self.serviceManager.contactListService acceptContactRequest:user.ID] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        @strongify(self);
        return [self.serviceManager.chatService sendMessageAboutAcceptingContactRequest:YES toOpponentID:user.ID];
    }];
}

- (BFTask *)rejectAddContactRequest:(QBUUser *)user {
    
    @weakify(self);
    return [[self.serviceManager.contactListService rejectContactRequest:user.ID] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        @strongify(self);
        return [self.serviceManager.chatService sendMessageAboutAcceptingContactRequest:NO toOpponentID:user.ID];
    }];
}

- (BFTask *)removeUserFromContactList:(QBUUser *)user {
    
    __block QBChatDialog *chatDialog = nil;
    
    @weakify(self);
    return [[[[self.serviceManager.contactListService removeUserFromContactListWithUserID:user.ID] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        
        return [self.serviceManager.chatService createPrivateChatDialogWithOpponent:user];
    }] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
        
        chatDialog = t.result;
        QBChatMessage *notificationMessage = [QMMessagesHelper removeContactNotificationForUser:user];
        
        return [self.serviceManager.chatService sendMessage:notificationMessage
                                                       type:notificationMessage.messageType
                                                   toDialog:chatDialog
                                              saveToHistory:YES
                                              saveToStorage:NO];
        
    }] continueWithBlock:^id _Nullable(BFTask * __unused _Nonnull t) {
        
        return [self.serviceManager.chatService deleteDialogWithID:chatDialog.ID];
    }];
}

//MARK: - Users

- (NSString *)fullNameForUserID:(NSUInteger)userID {
    
    QBUUser *user = [self.serviceManager.usersService.usersMemoryStorage userWithID:userID];
    
    NSString *fullName = user.fullName ?: [NSString stringWithFormat:@"%tu", userID];
    
    return fullName;
}

- (NSArray *)allContacts {
    
    NSArray *ids = [self.serviceManager.contactListService.contactListMemoryStorage userIDsFromContactList];
    NSArray *allContacts = [self.serviceManager.usersService.usersMemoryStorage usersWithIDs:ids];
    
    return allContacts;
}

- (NSArray *)allContactsSortedByFullName {
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@keypath(QBUUser.new, fullName)
                                                           ascending:YES
                                                            selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedUsers = [[self allContacts] sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

- (BOOL) isUserExist:(NSInteger)userID inArray:(NSArray*) users {
    NSArray* IDs = [self idsOfUsers:users];
    if ([IDs containsObject:@(userID)]) {
        return YES;
    }
    
    return NO;
}

- (NSArray*) friendsWithoutDenning {
    NSArray *users = [self.serviceManager.usersService.usersMemoryStorage unsortedUsers];
    NSMutableArray* friends = [NSMutableArray new];
    // Staff Contact
    for (ChatFirmModel *chatFirmModel in [DataManager sharedManager].staffContactsArray) {
        for (QBUUser* chatUserModel in chatFirmModel.users) {
            for (QBUUser* user in users) {
                if ([chatUserModel.email localizedCaseInsensitiveCompare:user.email] == NSOrderedSame && ![self isUserExist:user.ID inArray:friends] && user.ID != [QBSession currentSession].currentUser.ID) {
                    [friends addObject:chatUserModel];
                }
            }
        }
    }
    
    for (ChatFirmModel *chatFirmModel in [DataManager sharedManager].clientContactsArray) {
        for (QBUUser* chatUserModel in chatFirmModel.users) {
            for (QBUUser* user in users) {
                if ([chatUserModel.email localizedCaseInsensitiveCompare: user.email] == NSOrderedSame && ![self isUserExist:user.ID inArray:friends] && user.ID != [QBSession currentSession].currentUser.ID) {
                    [friends addObject:chatUserModel];
                }
            }
        }
    }
    
    return [friends copy];
}

- (NSArray *)friends {
    
    NSArray *users = [self.serviceManager.usersService.usersMemoryStorage unsortedUsers];
    NSMutableArray* friends = [[self friendsWithoutDenning] mutableCopy];
    
    // Denning Contact
    for (ChatFirmModel *chatFirmModel in [DataManager sharedManager].denningContactArray) {
        for (QBUUser* chatUserModel in chatFirmModel.users) {
            for (QBUUser* user in users) {
                if ([chatUserModel.email localizedCaseInsensitiveCompare:user.email] == NSOrderedSame && ![self isUserExist:user.ID inArray:friends] && user.ID != [QBSession currentSession].currentUser.ID) {
                    [friends addObject:chatUserModel];
                }
            }
        }
    }
   
    return [friends copy];
}

- (NSArray*) usersByExcludingDenningUsersWithIDS:(NSArray*) userIDs {
    BOOL isExist = NO;
    NSMutableArray *mutableUsers = [NSMutableArray new];
    
    for (NSNumber* ID in userIDs) {
        for (ChatFirmModel *chatFirmModel in [DataManager sharedManager].denningContactArray) {
            for (QBUUser* user in chatFirmModel.users) {
                if (ID.integerValue == user.ID) {
                    isExist = YES;
                }
            }
        }
        
        if (!isExist) {
            [mutableUsers addObject:ID];
        }
    }
    
    return [mutableUsers copy];
}

- (NSArray *)friendsByExcludingUsersWithIDs:(NSArray *)userIDs {
    
    NSArray *friends = [self friends];
    NSMutableArray *mutableUsers = [friends mutableCopy];
    
    for (QBUUser *user in friends) {
        
        if ([userIDs containsObject:@(user.ID)]) {
            
            [mutableUsers removeObject:user];
        }
    }
    
    return [mutableUsers copy];
}

- (NSArray *)friendsByIDs:(NSArray *)userIDs {
    
    NSArray *friends = [self friends];
    NSMutableArray *mutableUsers = [NSMutableArray new];
    
    for (QBUUser *user in friends) {
        
        if ([userIDs containsObject:@(user.ID)]) {
            
            [mutableUsers addObject:user];
        }
    }
    
    return [mutableUsers copy];
}

- (NSArray *)idsOfUsers:(NSArray *)users {
    
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        
        [ids addObject:@(user.ID)];
    }
    
    return [ids copy];
}

- (NSArray *)occupantsWithoutUser:(NSArray *)occupantIDs user:(QBUUser*) user{
    
    NSMutableArray *occupantsWithoutCurrentUser = [occupantIDs mutableCopy];
    
    [occupantsWithoutCurrentUser removeObject:@(user.ID)];
    
    return [occupantsWithoutCurrentUser copy];
}

- (NSArray *)occupantsWithoutCurrentUser:(NSArray *)occupantIDs {
    
    return [self occupantsWithoutUser:occupantIDs user:self.serviceManager.currentUser];
}

- (NSString *)onlineStatusForUser:(QBUUser *)user {
    
    QBContactListItem *contactListItem =
    [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
    
    NSString *status = nil;
    
    if (user.ID == self.serviceManager.currentProfile.userData.ID || contactListItem.isOnline) {
        status = NSLocalizedString(@"QM_STR_ONLINE", nil);
    }
    else if (!contactListItem.isOnline) {
        
        NSDate *statusDate = user.lastRequestAt;
        if (statusDate == nil) {
            statusDate = user.createdAt;
        }
        
        status = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"QM_STR_LAST_SEEN", nil), [QMDateUtils formattedLastSeenString:statusDate withTimePrefix:NSLocalizedString(@"QM_STR_TIME_PREFIX", nil)]];
        
        if (contactListItem.subscriptionState != QBPresenceSubscriptionStateNone) {
            // requesting update on activity
            [[QBChat instance] lastActivityForUserWithID:contactListItem.userID completion:^(NSUInteger seconds, NSError * _Nullable error) {
                if (error == nil) {
                    if (seconds != (NSUInteger)fabs([user.lastRequestAt timeIntervalSinceNow])) {
                        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)seconds];
                        if ([user.lastRequestAt compare:date] == NSOrderedAscending) {
                            // always should have newest date
                            user.lastRequestAt = date;
                            [self.serviceManager.usersService updateUsers:@[user]];
                        }
                    }
                }
            }];
        }
    }
    
    return status;
}

//MARK: - States

- (BOOL)isFriendWithUserID:(NSUInteger)userID {
    
    if (userID == self.serviceManager.currentProfile.userData.ID) {
        
        return YES;
    }
    
    QBContactListItem *contactListItem = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return contactListItem != nil;
    
//    return contactListItem != nil && contactListItem.subscriptionState != QBPresenceSubscriptionStateNone;
}

- (BOOL)isContactListItemExistentForUserWithID:(NSUInteger)userID {
    
    QBContactListItem *contactListItem = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return contactListItem != nil;
}

- (BOOL)isUserOnlineWithID:(NSUInteger)userID {
    
    QBContactListItem *item = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return item.isOnline;
}

@end
