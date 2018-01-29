//
//  QMNotification.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPGNotification.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMNotification class interface.
 *  Used as overall main notification handling class.
 */
@interface QMNotification : NSObject

/**
 *  Show message notification for message.
 *
 *  @param chatMessage          chat message
 *  @param buttonHandler        button handler blocks
 *  @param hvc   host view controller for notification view
 */
+ (void)showMessageNotificationWithMessage:(QBChatMessage *)chatMessage buttonHandler:(MPGNotificationButtonHandler)buttonHandler hostViewController:(UIViewController *)hvc;

/**
 * Show message notification for News Feed
 *
 */

+ (void) showMessageNotificationWithTitle:(NSString*)title message: (NSString*) messageText avatarURL:(NSString*)avatarURL buttonHandler:(MPGNotificationButtonHandler)buttonHandler hostViewController:(UIViewController *)hvc;


/**
 *  Send push notification for user with text.
 *
 *  @param user user to send push notification to
 *  @param text text for push notification
 *
 *  @return BFTask with completion
 */
+ (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text;

+ (BFTask *)sendPushMessageToUser:(NSUInteger) userID withUserName:(NSString*)username withMessage:(QBChatMessage *)message;

/**
 *  Send push notification for user with text, extra params and possibly VOIP.
 *
 *  @param user user to send push notification to
 *  @param text text for push notification
 *  @param extraParams additional parameters to send in payload
 *  @param isVoip determines whether push should be voip if possible
 *
 *  @return BFTask with completion
 */
+ (BFTask *)sendPushNotificationToUsers:(NSString *)userIDs withText:(NSString *)text extraParams:(NSDictionary *)extraParams isVoip:(BOOL)isVoip;

+ (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text extraParams:(NSDictionary *)extraParams isVoip:(BOOL)isVoip;

@end

NS_ASSUME_NONNULL_END
