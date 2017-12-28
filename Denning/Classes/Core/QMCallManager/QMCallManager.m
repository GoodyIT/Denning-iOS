//
//  QMCallManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCallManager.h"
#import "QMCore.h"
#import "QMCallViewController.h"
#import "QMSoundManager.h"
#import "QMPermissions.h"
#import "QMNotification.h"
#import "SessionSettingsViewController.h"
#import "CallViewController.h"
#import "IncomingCallViewController.h"
#import "CallKitManager.h"

static const NSTimeInterval kQMAnswerTimeInterval = 60.0f;
static const NSTimeInterval kQMDialingTimeInterval = 5.0f;
static const NSTimeInterval kQMCallViewControllerEndScreenDelay = 1.0f;

const NSUInteger kQBPageSize = 50;
static NSString * const kAps = @"aps";
static NSString * const kAlert = @"alert";
static NSString * const kVoipEvent = @"VOIPCall";

@interface QMCallManager ()

<
QBRTCClientDelegate,
IncomingCallViewControllerDelegate,
PKPushRegistryDelegate
>

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;
@property (strong, nonatomic) QBMulticastDelegate <QMCallManagerDelegate> *multicastDelegate;

@property (strong, nonatomic, readwrite) QBRTCSession *session;
@property (assign, nonatomic, readwrite) BOOL hasActiveCall;
@property (strong, nonatomic) NSTimer *soundTimer;

@property (strong, nonatomic) UIWindow *callWindow;

@property (strong, nonatomic) PKPushRegistry *voipRegistry;
@property (strong, nonatomic) NSUUID *callUUID;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTask;


@end

@implementation QMCallManager

@dynamic serviceManager;

- (void)serviceWillStart {
    
    [QBRTCConfig setAnswerTimeInterval:kQMAnswerTimeInterval];
    [QBRTCConfig setDialingTimeInterval:kQMDialingTimeInterval];
    
    _multicastDelegate = (id<QMCallManagerDelegate>)[[QBMulticastDelegate alloc] init];
    
    [[QBRTCClient instance] addDelegate:self];
    
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    self.voipRegistry.delegate = self;
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

//MARK: - Call managing

// Group call

 - (void)callToUserWithIDs:(NSMutableArray *)opponentsIDs conferenceType:(QBRTCConferenceType)conferenceType
{
    NSInteger myID = [QBSession currentSession].currentUser.ID;
    if ([opponentsIDs containsObject:@(myID)]) {
        [opponentsIDs removeObject:@(myID)];
    }
    
    @weakify(self);
    [self checkPermissionsWithConferenceType:conferenceType completion:^(BOOL granted) {
        
        @strongify(self);
        
        if (!granted) {
            // no permissions
            return;
        }
        
        if (self.session != nil) {
            // session in progress
            return;
        }
        
        self.session = [[QBRTCClient instance] createNewSessionWithOpponents:opponentsIDs
                                                          withConferenceType:conferenceType];
        
        if (self.session == nil) {
            // failed to create session
            return;
        }
        
        NSUUID *uuid = nil;
        if (CallKitManager.isCallKitAvailable) {
            uuid = [NSUUID UUID];
            [CallKitManager.instance startCallWithUserIDs:opponentsIDs session:self.session uuid:uuid];
        }
        
        CallViewController *callViewController = [[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
        callViewController.session = self.session;
        callViewController.callUUID = uuid;
        
        [self prepareCallWindow];
        
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.callWindow.rootViewController = nav;

        NSDictionary *payload = @{
                                  @"message"  : [NSString stringWithFormat:@"%@ is calling you.", [QBSession currentSession].currentUser.fullName],
                                  @"ios_voip" : @"1",
                                  kVoipEvent  : @"1",
                                  };
        NSData *data =
        [NSJSONSerialization dataWithJSONObject:payload
                                        options:NSJSONWritingPrettyPrinted
                                          error:nil];
        NSString *message =
        [[NSString alloc] initWithData:data
                              encoding:NSUTF8StringEncoding];
        
        QBMEvent *event = [QBMEvent event];
        event.notificationType = QBMNotificationTypePush;
        event.usersIDs = [opponentsIDs componentsJoinedByString:@","];
        event.type = QBMEventTypeOneShot;
        event.message = message;
        
        [QBRequest createEvent:event
                  successBlock:^(QBResponse *response, NSArray<QBMEvent *> *events) {
                      NSLog(@"Send voip push - Success");
                  } errorBlock:^(QBResponse * _Nonnull response) {
                      NSLog(@"Send voip push - Error");
                  }];
        
        self.hasActiveCall = YES;
    }];
}

// Private call

- (void)callToUserWithID:(NSUInteger)userID conferenceType:(QBRTCConferenceType)conferenceType {
    [self callToUserWithIDs:[@[@(userID)] mutableCopy] conferenceType:conferenceType];

}

- (void)prepareCallWindow {
    
    // hiding keyboard
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    self.callWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // displaying window under status bar
    self.callWindow.windowLevel = UIWindowLevelStatusBar - 1;
    [self.callWindow makeKeyAndVisible];
}

//MARK: - Setters

- (void)setHasActiveCall:(BOOL)hasActiveCall {
    
    if (_hasActiveCall != hasActiveCall) {
        
        [self.multicastDelegate callManager:self willChangeActiveCallState:hasActiveCall];
        
        _hasActiveCall = hasActiveCall;
        
        if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
            [UIDevice currentDevice].proximityMonitoringEnabled = hasActiveCall;
        }
        
        if (!hasActiveCall) {
            [self.serviceManager.chatManager disconnectFromChatIfNeeded];
        }
    }
}

//MARK: - Getters

- (NSArray*)opponentUsers {
    
    if (self.session == nil) {
        // no active session
        return nil;
    }
    
    NSArray* opponentID;
    
    NSUInteger initiatorID = self.session.initiatorID.unsignedIntegerValue;
    if (initiatorID == self.serviceManager.currentProfile.userData.ID) {
        
        opponentID = [self.session.opponentsIDs copy];
    }
    else {
        
        opponentID = @[@(initiatorID)];
    }
    
    NSArray<QBUUser *> *opponentUsers = [self.serviceManager.usersService.usersMemoryStorage usersWithIDs:opponentID];
    
    return opponentUsers;
}

//MARK: - QBRTCClientDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)__unused userInfo {
    
    if (self.session != nil) {
        // session in progress
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    
    if (session.initiatorID.unsignedIntegerValue == self.serviceManager.currentProfile.userData.ID) {
        // skipping call from ourselves
        return;
    }
    
    self.session = session;
    self.hasActiveCall = YES;
    
    [self startPlayingRingtoneSound];
    
//    // initializing controller
//    QMCallState callState = session.conferenceType == QBRTCConferenceTypeVideo ? QMCallStateIncomingVideoCall : QMCallStateIncomingAudioCall;
    
    [self prepareCallWindow];
//    self.callWindow.rootViewController = [QMCallViewController callControllerWithState:callState];
    
    if (CallKitManager.isCallKitAvailable) {
        self.callUUID = [NSUUID UUID];
        NSMutableArray *opponentIDs = [@[session.initiatorID] mutableCopy];
        for (NSNumber *userID in session.opponentsIDs) {
            if ([userID integerValue] != [QMCore instance].currentUser.ID) {
                [opponentIDs addObject:userID];
            }
        }
        __weak __typeof(self)weakSelf = self;
        [CallKitManager.instance reportIncomingCallWithUserIDs:[opponentIDs copy] session:session uuid:self.callUUID onAcceptAction:^{
            __typeof(weakSelf)strongSelf = weakSelf;
            CallViewController *callViewController =
            [[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];;
            
            callViewController.session = session;
            callViewController.callUUID = strongSelf.callUUID;
            UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
            nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            strongSelf.callWindow.rootViewController = nav;
            
        } completion:nil];
    }
    else {
        
        IncomingCallViewController *incomingViewController =
        [[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"IncomingCallViewController"];
        incomingViewController.delegate = self;
        incomingViewController.session = session;
        
    }
}

- (void)session:(QBRTCSession *)__unused session updatedStatsReport:(QBRTCStatsReport *)__unused report forUserID:(NSNumber *)__unused userID {
    
    ILog(@"Stats report for userID: %@\n%@", userID, [report statsString]);
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)__unused userID {
    
    if (self.session == session) {
        // stopping calling sounds
        [self stopAllSounds];
    }
}

- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (self.session != session) {
        // may be we rejected some one else call
        // while talking with another person
        return;
    }
    
    self.hasActiveCall = NO;
    
    if (_backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
        _backgroundTask = UIBackgroundTaskInvalid;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground
            && _backgroundTask == UIBackgroundTaskInvalid) {
            // dispatching chat disconnect in 1 second so message about call end
            // from webrtc does not cut mid sending
            // checking for background task being invalid though, to avoid disconnecting
            // from chat when another call has already being received in background
            [QBChat.instance disconnectWithCompletionBlock:nil];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kQMCallViewControllerEndScreenDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [QMSoundManager playEndOfCallSound];
        
        [self.multicastDelegate callManager:self willCloseCurrentSession:session];
        
        self.callWindow.rootViewController = nil;
        self.callWindow = nil;
        self.session = nil;
        
        if (CallKitManager.isCallKitAvailable) {
            [CallKitManager.instance endCallWithUUID:self.callUUID completion:nil];
            self.callUUID = nil;
        }
       
    });
}

- (void)incomingCallViewController:(IncomingCallViewController *)vc didAcceptSession:(QBRTCSession *)session {
    
    CallViewController *callViewController =
    [[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
    
    callViewController.session = session;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.callWindow.rootViewController = nav;
}

- (void)incomingCallViewController:(IncomingCallViewController *)vc didRejectSession:(QBRTCSession *)session {
    
    [session rejectCall:nil];
    [QMCore.instance.callManager sendCallNotificationMessageWithState:QMCallNotificationStateMissedNoAnswer duration:0];
}

// MARK: - PKPushRegistryDelegate protocol

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    
    //  New way, only for updated backend
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNSVOIP;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = [self.voipRegistry pushTokenForType:PKPushTypeVoIP];
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        NSLog(@"Create Subscription request - Success");
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Create Subscription request - Error");
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"Unregister Subscription request - Success");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"Unregister Subscription request - Error");
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    if (CallKitManager.isCallKitAvailable) {
        if ([payload.dictionaryPayload objectForKey:kVoipEvent] != nil) {
            UIApplication *application = [UIApplication sharedApplication];
            if (application.applicationState == UIApplicationStateBackground
                && _backgroundTask == UIBackgroundTaskInvalid) {
                _backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
                    [application endBackgroundTask:_backgroundTask];
                    _backgroundTask = UIBackgroundTaskInvalid;
                }];
            }
            if (![QBChat instance].isConnected) {
                [[QMCore instance] login];
            }
        }
    }
}


//MARK: - Multicast delegate

- (void)addDelegate:(id<QMCallManagerDelegate>)delegate {
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id<QMCallManagerDelegate>)delegate {
    [self.multicastDelegate removeDelegate:delegate];
}

//MARK: - Sound management

- (void)startPlayingCallingSound {
    
    [self stopAllSounds];
    [QMSoundManager playCallingSound];
    self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                                       target:[QMSoundManager class]
                                                     selector:@selector(playCallingSound)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)startPlayingRingtoneSound {
    
    [self stopAllSounds];
    
    [QMSoundManager playRingtoneSound];
    self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                                       target:[QMSoundManager class]
                                                     selector:@selector(playRingtoneSound)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopAllSounds {
    
    if (self.soundTimer != nil) {
        
        [self.soundTimer invalidate];
        self.soundTimer = nil;
    }
    
    [[QMSoundManager instance] stopAllSounds];
}

//MARK: - Permissions check

- (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType completion:(PermissionBlock)completion {
    
    @weakify(self);
    [QMPermissions requestPermissionToMicrophoneWithCompletion:^(BOOL granted) {
        
        @strongify(self);
        if (granted) {
            
            switch (conferenceType) {
                    
                case QBRTCConferenceTypeAudio:
                    
                    if (completion) {
                        
                        completion(granted);
                    }
                    
                    break;
                    
                case QBRTCConferenceTypeVideo: {
                    
                    [QMPermissions requestPermissionToCameraWithCompletion:^(BOOL videoGranted) {
                        
                        if (!videoGranted) {
                            
                            // showing error alert with a suggestion
                            // to go to the settings
                            [self showAlertWithTitle:NSLocalizedString(@"QM_STR_CAMERA_ERROR", nil)
                                             message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_CAMERA", nil)];
                        }
                        
                        if (completion) {
                            
                            completion(videoGranted);
                        }
                    }];
                    
                    break;
                }
            }
        }
        else {
            
            // showing error alert with a suggestion
            // to go to the settings
            [self showAlertWithTitle:NSLocalizedString(@"QM_STR_MICROPHONE_ERROR", nil)
                             message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_MICROPHONE", nil)];
            
            if (completion) {
                
                completion(granted);
            }
        }
    }];
}

//MARK: - Call notifications

- (QBChatMessage *)_callNotificationMessageForSession:(QBRTCSession *)session
                                                state:(QMCallNotificationState)state {
    
    NSUInteger senderID = self.serviceManager.currentProfile.userData.ID;
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = kQMCallNotificationMessage;
    message.senderID = senderID;
    message.markable = YES;
    message.dateSent = [NSDate date];
    message.callNotificationType = session.conferenceType == QBRTCConferenceTypeAudio ? QMCallNotificationTypeAudio : QMCallNotificationTypeVideo;
    message.callNotificationState = state;
    
    NSUInteger initiatorID = session.initiatorID.unsignedIntegerValue;
    NSUInteger opponentID = [session.opponentsIDs.firstObject unsignedIntegerValue];
    NSUInteger calleeID = initiatorID == senderID ? opponentID : initiatorID;
    
    message.callerUserID = initiatorID;
    message.calleeUserIDs = [NSIndexSet indexSetWithIndex:calleeID];
    
    message.recipientID = calleeID;
    
    return message;
}

- (void)_sendNotificationMessage:(QBChatMessage *)message {
    
    QBChatDialog *chatDialog = [self.serviceManager.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:message.recipientID];
    
    if (chatDialog != nil) {
        
        message.dialogID = chatDialog.ID;
        [self.serviceManager.chatService sendMessage:message
                                            toDialog:chatDialog
                                       saveToHistory:YES
                                       saveToStorage:YES];
    }
    else {
        
        [[self.serviceManager.chatService createPrivateChatDialogWithOpponentID:message.recipientID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
            
            message.dialogID = t.result.ID;
            [self.serviceManager.chatService sendMessage:message
                                                toDialog:t.result
                                           saveToHistory:YES
                                           saveToStorage:YES];
            
            return nil;
        }];
    }
}

- (void)sendCallNotificationMessageWithState:(QMCallNotificationState)state duration:(NSTimeInterval)duration {
    
    QBChatMessage *message = [self _callNotificationMessageForSession:self.session state:state];
    
    if (duration > 0) {
        
        message.callDuration = duration;
    }
    
    [self _sendNotificationMessage:message];
}

//MARK: - Helpers

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_SETTINGS", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                      }]];
    
    UIViewController *viewController = [[[(UISplitViewController *)[UIApplication sharedApplication].keyWindow.rootViewController viewControllers] firstObject] selectedViewController];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

@end
