//
//  QMChatManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatManager.h"
#import "QMCore.h"
#import "QMContent.h"
#import "QMMessagesHelper.h"

@interface QMChatManager ()

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;

@end

@implementation QMChatManager

@dynamic serviceManager;

//MARK: - Chat Connection

- (BFTask *)disconnectFromChat {
    @weakify(self);
    return [[self.serviceManager.chatService disconnect] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        if (self.serviceManager.currentProfile.userData != nil) {
            
//            self.serviceManager.currentProfile.lastDialogsFetchingDate = [NSDate date];
            [[QMCore instance].currentProfile clearLastFetchingDate];
//            self.serviceManager.currentProfile.lastDialogsFetchingDate = nil;
            [self.serviceManager.currentProfile synchronize];
        }
        
        return nil;
    }];
}

- (BFTask *)disconnectFromChatIfNeeded {
    
    BOOL chatNeedDisconnect =  [[QBChat instance] isConnected] || [[QBChat instance] isConnecting];
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground && !self.serviceManager.callManager.hasActiveCall && chatNeedDisconnect) {
        
        return [self disconnectFromChat];
    }
    
    return nil;
}

//MARK: - Notifications

- (BFTask *)addUsers:(NSArray *)users toGroupChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup || chatDialog.type == QBChatDialogTypePublicGroup, @"Chat dialog must be group type!");
    
    NSArray *userIDs = [self.serviceManager.contactManager idsOfUsers:users];
    
    @weakify(self);
    return [[self.serviceManager.chatService joinOccupantsWithIDs:userIDs toChatDialog:chatDialog] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        @strongify(self);
        QBChatDialog *updatedDialog = task.result;
        [[self.serviceManager.chatService sendSystemMessageAboutAddingToDialog:updatedDialog toUsersIDs:userIDs withText:kQMDialogsUpdateNotificationMessage] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused systemNotificationTask) {
            
            return [self.serviceManager.chatService sendNotificationMessageAboutAddingOccupants:userIDs toDialog:updatedDialog withNotificationText:kQMDialogsUpdateNotificationMessage];
        }];
        
        return nil;
    }];
}

- (BFTask *)changeAvatar:(UIImage *)avatar forGroupChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup || chatDialog.type == QBChatDialogTypePublicGroup, @"Chat dialog must be group type!");
    
    @weakify(self);
    return [[[QMContent uploadPNGImage:avatar progress:nil] continueWithSuccessBlock:^id _Nullable(BFTask<QBCBlob *> * _Nonnull task) {
        
        @strongify(self);
        NSString *url = task.result.isPublic ? [task.result publicUrl] : [task.result privateUrl];
        return [self.serviceManager.chatService changeDialogAvatar:url forChatDialog:chatDialog];
        
    }] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        @strongify(self);
        [self.serviceManager.chatService sendNotificationMessageAboutChangingDialogPhoto:task.result withNotificationText:kQMDialogsUpdateNotificationMessage];
        return nil;
    }];
}

- (BFTask *)changeName:(NSString *)name forGroupChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup || chatDialog.type == QBChatDialogTypePublicGroup, @"Chat dialog must be group type!");
    
    @weakify(self);
    return [[self.serviceManager.chatService changeDialogName:name forChatDialog:chatDialog] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        @strongify(self);
        
        return [self.serviceManager.chatService sendNotificationMessageAboutChangingDialogName:task.result withNotificationText:kQMDialogsUpdateNotificationMessage];
    }];
}

- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup || chatDialog.type == QBChatDialogTypePublicGroup, @"Chat dialog must be group type!");
    
    @weakify(self);
    
    return [[self.serviceManager.chatService sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:kQMDialogsUpdateNotificationMessage] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        return [self.serviceManager.chatService deleteDialogWithID:chatDialog.ID];
    }];
}

- (BFTask *)sendBackgroundMessageWithText:(NSString *)text toDialogWithID:(NSString *)chatDialogID {
    
    NSUInteger currentUserID = QMCore.instance.currentProfile.userData.ID;
    
    QBChatMessage *message = [QMMessagesHelper chatMessageWithText:text
                                                          senderID:currentUserID
                                                      chatDialogID:chatDialogID
                                                          dateSent:[NSDate date]];
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    [QBRequest sendMessage:message successBlock:^(QBResponse * __unused response, QBChatMessage *createdMessage) {
        
        [source setResult:createdMessage];
        
    } errorBlock:^(QBResponse *response) {
        
        [source setError:response.error.error];
    }];
    
    return source.task;
}

// Customization for Group chat tag
- (BFTask*) changeTag:(NSString*) tag forGroupChatDialog :(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup || chatDialog.type == QBChatDialogTypePublicGroup, @"Chat dialog must be group type!");
    
    NSDictionary* tagData = @{@"tag": tag};
    @weakify(self);
    return [[self changeCustomData:tagData forGroupChatDialog:chatDialog] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        @strongify(self);
        
        return [self sendNotificationMessageAboutDialogUpdateWithText:kQMGroupTypeChangeNotificationMessage forChatDialog:task.result];
    }];
}

- (NSMutableArray*) updateRoleIDs:(NSMutableArray*) IDArray withRole:(NSString*)role comparedRole:(NSString*)kRole forID:(NSInteger) userID {
     if ([role isEqualToString:kRole]) {
         if (IDArray != nil) {
             if (![IDArray containsObject:@(userID)]) {
                 [IDArray addObject:@(userID)];
             }
         } else {
             IDArray = [NSMutableArray new];
             [IDArray addObject:@(userID)];
         }
     } else {
         if (IDArray != nil) {
             [IDArray removeObject:@(userID)];
         } else {
             IDArray = [NSMutableArray new];
         }
     }
    return IDArray;
}

- (BFTask*) changeUserWithID:(NSInteger) userID toRole:(NSString*)role forGroupChatDialog :(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup || chatDialog.type == QBChatDialogTypePublicGroup, @"Chat dialog must be group type!");
    
    NSMutableArray* originAdminIDs = [chatDialog.data objectForKeyNotNull:kRoleAdminTag];
    NSMutableArray* originReaderIDs = [chatDialog.data objectForKeyNotNull:kRoleReaderTag];
    NSMutableArray* originNormalIDs = [chatDialog.data objectForKeyNotNull:kRoleNormalTag];
    
    originAdminIDs = [self updateRoleIDs:originAdminIDs withRole:role comparedRole:kRoleAdminTag forID:userID];
    originReaderIDs = [self updateRoleIDs:originReaderIDs withRole:role comparedRole:kRoleReaderTag forID:userID];
    originNormalIDs = [self updateRoleIDs:originNormalIDs withRole:role comparedRole:kRoleNormalTag forID:userID];
    
    NSDictionary* roleData = @{kRoleAdminTag: originAdminIDs, kRoleReaderTag: originReaderIDs, kRoleNormalTag:originNormalIDs};
    return [self changeCustomData:roleData forGroupChatDialog:chatDialog];
}

- (BFTask*) sendNotificationMessageAboutDialogUpdateWithText:(NSString*) notificationText forChatDialog:(QBChatDialog*) chatDialog{
    
    return make_task(^(BFTaskCompletionSource *source) {
        QBChatMessage *notificationMessage = [QBChatMessage message];
        notificationMessage.senderID = self.serviceManager.currentUser.ID;
        notificationMessage.text = notificationText;
        notificationMessage.dialogUpdateType = QMDialogUpdateTypeType;
        notificationMessage.dialogUpdatedAt = chatDialog.updatedAt;
        notificationMessage.dialogName = chatDialog.name;
        
        [self.serviceManager.chatService sendMessage:notificationMessage
                     type:QMMessageTypeUpdateGroupDialog
                 toDialog:chatDialog
            saveToHistory:YES
            saveToStorage:YES
                                          completion:^(NSError * _Nullable error) {
                                              if (error == nil) {
                                                  [source setResult:nil];
                                              }
                                              else {
                                                  [source setError:error];
                                              }
                                          }];
    });
}

- (BFTask*) changeCustomData:(NSDictionary*) data forGroupChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup || chatDialog.type == QBChatDialogTypePublicGroup, @"Chat dialog must be group type!");
    NSMutableDictionary* customData = [@{@"class_name":@"dialog_data"} mutableCopy];
    [customData addEntriesFromDictionary:data];
    chatDialog.data = [customData copy];
    return make_task(^(BFTaskCompletionSource *source) {
        @weakify(self);
        [QBRequest updateDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *updatedDialog) {
            
            @strongify(self)
            [self.serviceManager.chatService.dialogsMemoryStorage addChatDialog:updatedDialog
                                                                        andJoin:YES
                                                                     completion:^(QBChatDialog *addedDialog, NSError *error)
             {
                 [QMCore.instance.chatService.dialogsMemoryStorage addChatDialog:updatedDialog
                                                      andJoin:YES
                                                   completion:^(QBChatDialog *addedDialog, NSError *error)
                  {
                      [source setResult:updatedDialog];
                  }];
                 
             }];
            
        } errorBlock:^(QBResponse *response) {
            
            [self.serviceManager handleErrorResponse:response];
            
            [source setError:response.error.error];
        }];
    });
}

@end
