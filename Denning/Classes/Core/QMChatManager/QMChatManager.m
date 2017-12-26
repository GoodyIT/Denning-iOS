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
    return [self changeCustomData:tagData forGroupChatDialog:chatDialog];
}

- (BFTask*) changeUserRoleToAdmin:(NSInteger) userID forGroupChatDialog :(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup || chatDialog.type == QBChatDialogTypePublicGroup, @"Chat dialog must be group type!");
    
    NSMutableArray* originAdminIDs = [chatDialog.data objectForKey:@"role_admin"];
    NSMutableArray* originReaderIDs = [chatDialog.data objectForKey:@"role"];
    
    if (originReaderIDs != nil) {
        [originReaderIDs removeObject:@(userID)];
    }
    
    if (originAdminIDs != nil) {
        if (![originAdminIDs containsObject:@(userID)]) {
            [originAdminIDs addObject:@(userID)];
        }
    }
    
    NSDictionary* roleData = @{@"role_admin": originAdminIDs, @"role": originReaderIDs};
    return [self changeCustomData:roleData forGroupChatDialog:chatDialog];
}

- (BFTask*) changeUserRoleToReader:(NSInteger) userID forGroupChatDialog :(QBChatDialog *)chatDialog {
     NSAssert(chatDialog.type == QBChatDialogTypeGroup || chatDialog.type == QBChatDialogTypePublicGroup, @"Chat dialog must be group type!");
    NSMutableArray* originAdminIDs = [chatDialog.data objectForKey:@"role_admin"];
    NSMutableArray* originReaderIDs = [chatDialog.data objectForKey:@"role"];
    if (originAdminIDs != nil) {
        [originAdminIDs removeObject:@(userID)];
    }
    if (originReaderIDs != nil) {
        if (![originReaderIDs containsObject:@(userID)]) {
            [originReaderIDs addObject:@(userID)];
        }
    }
    
    NSDictionary* roleData = @{@"role_admin": originAdminIDs, @"role": originReaderIDs};
    return [self changeCustomData:roleData forGroupChatDialog:chatDialog];
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
