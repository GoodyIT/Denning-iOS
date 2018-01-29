//
//  QMConstants.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#ifndef QMConstants_h
#define QMConstants_h

#import <CoreLocation/CLLocation.h>

#ifdef DEBUG

#define ILog(...) do { NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]); } while(0)

#else

#define ILog(...) do { } while (0)

#endif

#define qm_keypath(__CLASS__, __KEY__)                      \
({                                                          \
while (1) {                                             \
break;                                              \
[__CLASS__ class];                                  \
__CLASS__ * instance = nil;                         \
[instance __KEY__];                                 \
}                                                       \
NSStringFromSelector(@selector(__KEY__));               \
})


static const float kQMAttachmentCellSize = 180.0f;
static const NSTimeInterval kQMMaxAttachmentDuration = 30.0f;

static NSString* const kDenningPeople = @"denningpeople";
static NSString* const kColleague = @"colleague";
static NSString* const kClient = @"client";
static NSString* const kPublicUser = @"public user";

static NSString *const kQBPassword = @"denningIT";

// Chat Dialog
static NSString* const kRoleDenningTag = @"role_denning";
static NSString* const kRoleAdminTag = @"role_admin";
static NSString* const kRoleReaderTag = @"role_reader";
static NSString* const kRoleStaffTag = @"role_normal";
static NSString* const kRoleClientTag = @"role_client";

static NSString* const kChatColleaguesTag = @"Colleagues";
static NSString* const kChatClientsTag = @"Clients";
static NSString* const kChatMattersTag = @"Matters";
static NSString* const kChatDenningTag = @"Denning";

static NSString* const kGroupPositionTag = @"position";

// storyboards
static NSString *const kQMMainStoryboard = @"Main";
static NSString *const kLicenseSegue = @"LicenseSegue";
static NSString *const kQMChatStoryboard = @"Chat";
static NSString *const kQMSettingsStoryboard = @"Settings";

static NSString *const kQMPushNotificationDialogIDKey = @"dialog_id";
static NSString *const kQMPushNotificationUserIDKey = @"user_id";

static NSString *const kQMDialogsUpdateNotificationMessage = @"Notification message";
static NSString *const kQMContactRequestNotificationMessage = @"Contact request";
static NSString *const kQMLocationNotificationMessage = @"Location";
static NSString *const kQMCallNotificationMessage = @"Call notification";
static NSString *const kQMGroupTypeChangeNotificationMessage = @"Change group type";
static NSString *const kQMGroupMembersChangeNotificationMessage = @"Update the group members";
static NSString *const kQMGroupMemberUPdateUserRoleNotificationMessage = @"Update the user role";

/**
 *  EditDialogTableViewController
 */
static NSString *const kGoToChatSegueIdentifier = @"goToChat";

static const CGFloat kQMBaseAnimationDuration = 0.2f;
static const CGFloat kQMSlashAnimationDuration = 0.1f;
static const CGFloat kQMDefaultNotificationDismissTime = 2.0f;
static const CGFloat kQMShadowViewHeight = 0.5f;

static const CLLocationDegrees MKCoordinateSpanDefaultValue = 250;

//DarwinNotificationCenter

//Extension notifications
//Posted immediately after dialogs' updates in the Share Extension
static NSNotificationName const kQMDidUpdateDialogsNotification = @"com.quickblox.shareextension.didUpdateDialogs.notification";
//Posted immediately after dialog's updates in the Share Extension.
//Full name of the notification should be 'kQMDidUpdateDialogNotificationPrefix:dialogID'
static NSNotificationName const kQMDidUpdateDialogNotificationPrefix = @"com.quickblox.shareextension.didUpdateDialog.notification";

#endif /* QMConstants_h */
