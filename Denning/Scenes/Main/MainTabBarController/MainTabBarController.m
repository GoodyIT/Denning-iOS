//
//  MainTabBarController.m
//  Denning
//
//  Created by DenningIT on 02/02/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MainTabBarController.h"
#import "QMNotification.h"
#import "QMCore.h"
#import "QMChatVC.h"
#import "QMSoundManager.h"
#import "QBChatDialog+OpponentID.h"
#import "QMHelpers.h"
#import "MessageViewController.h"
#import "DashboardViewController.h"
#import "MainContactViewController.h"

static const NSInteger kQMNotAuthorizedInRest = -1000;
static const NSInteger kQMUnauthorizedErrorCode = -1011;

@interface MainTabBarController ()
<QMChatServiceDelegate,
QMChatConnectionDelegate,
QMPushNotificationManagerDelegate>
@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[QMCore instance].chatService addDelegate:self];
//    [self performAutoLoginAndFetchData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[QMCore instance].chatService removeDelegate:self];
}

- (void)performAutoLoginAndFetchData {
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading
                                                                          message:NSLocalizedString(@"QM_STR_CONNECTING", nil)
                                                                         duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    
    [[[QMCore.instance login] continueWithBlock:^id(BFTask *task) {
        
        if (task.isFaulted) {
            
            [(QMNavigationController *)navigationController dismissNotificationPanel];
            
            NSInteger errorCode = task.error.code;
            if (errorCode == kQMNotAuthorizedInRest
                || errorCode == kQMUnauthorizedErrorCode
                || (errorCode == kBFMultipleErrorsError
                    && ([task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][0] code] == kQMUnauthorizedErrorCode
                        || [task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][1] code] == kQMUnauthorizedErrorCode))) {
                        
                        return [QMCore.instance logout];
                    }
        }
        
        if (QMCore.instance.pushNotificationManager.pushNotification != nil) {
            [QMCore.instance.pushNotificationManager handlePushNotificationWithDelegate:self];
        }
        
        if (QMCore.instance.currentProfile.pushNotificationsEnabled) {
            [QMCore.instance.pushNotificationManager registerAndSubscribeForPushNotifications];
        }
        
        return [BFTask cancelledTask];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (!task.isCancelled) {
            [self performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
        }
        
        return nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabbarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController.childViewControllers[0] isKindOfClass:[MessageViewController class]] || [viewController.childViewControllers[0] isKindOfClass:[DashboardViewController class]] || [viewController.childViewControllers[0] isKindOfClass:[MainContactViewController class]]) {
        if ([DataManager sharedManager].user.username.length == 0 || [QBSession currentSession].currentUser.email.length == 0) {
            [QMAlert showAlertWithMessage:@"Please login first to use this function" actionSuccess:NO inViewController:self];
            self.tabBarController.selectedIndex = 0;
            return NO;
        }
    }
    
    
    return YES;
}

- (BOOL) checkPublicUser {
    if ([DataManager sharedManager].user.userType.length == 0) {
        [QMAlert showAlertWithMessage:@"You are not allow for this. Please subscribe the denning." actionSuccess:NO inViewController:self];
        return YES;
    }
    
    return NO;
}

- (NSArray *)menuItems
{
    if (!_menuItems)
    {
        NSString* userInfo = [DataManager sharedManager].user.username;
        if (userInfo.length == 0) {
            userInfo = @"Login";
        }
        
        _menuItems =
        @[
          [RWDropdownMenuItem itemWithText:userInfo image:[UIImage imageNamed:@"menu_user"] action:^{
              [self tapLogin:nil];
          }],
          
          [RWDropdownMenuItem itemWithText:@"Home" image:[UIImage imageNamed:@"menu_home"] action:^{
              self.selectedViewController = self.viewControllers[0];
          }],
          
          [RWDropdownMenuItem itemWithText:@"Add" image:[UIImage imageNamed:@"menu_add"] action:^{
              if ([self checkPublicUser] != YES) {
                  self.selectedViewController = self.viewControllers[1];
              }
          }],
          
          [RWDropdownMenuItem itemWithText:@"Overview" image:[UIImage imageNamed:@"menu_overview"] action:^{
              if (![self checkPublicUser]) {
                  self.selectedViewController = self.viewControllers[2];
              }
          }],
          
          [RWDropdownMenuItem itemWithText:@"Chats" image:[UIImage imageNamed:@"icon_message"] action:^{
              if (![self checkPublicUser]) {
                  self.selectedViewController = self.viewControllers[3];
              }
          }],
          
          [RWDropdownMenuItem itemWithText:@"Our Products" image:[UIImage imageNamed:@"menu_our_product"] action:^{
            
          }],
          
          [RWDropdownMenuItem itemWithText:@"Help" image:[UIImage imageNamed:@"menu_help"] action:^{
              
          }],
          
          [RWDropdownMenuItem itemWithText:@"Settings" image:[UIImage imageNamed:@"menu_settings"] action:^{
              
          }],
          
          [RWDropdownMenuItem itemWithText:@"Contact Us" image:[UIImage imageNamed:@"menu_contact_us"] action:^{
              
          }],
          
          [RWDropdownMenuItem itemWithText:@"Terms of Uses" image:[UIImage imageNamed:@"menu_terms_of_uses"] action:^{
              [self tapLicense];
          }],
          
          [RWDropdownMenuItem itemWithText:@"Log out" image:[UIImage imageNamed:@"menu_logout"] action:^{
              
          }],
        ];
    }
    return _menuItems;
}


- (IBAction)tapMenu:(id)sender {
    [RWDropdownMenu presentFromViewController:self withItems:self.menuItems align:RWDropdownMenuCellAlignmentRight style:RWDropdownMenuStyleBlackGradient navBarImage:[(UIBarItem*)sender image] completion:nil];
}

- (IBAction)tapLogin:(id)sender {
    [self performSegueWithIdentifier:kAuthSegue sender:nil];
}

- (void) tapLicense {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMNetworkManager sharedManager] setPublicHTTPHeader];
    [[QMNetworkManager sharedManager] sendGetWithURL:kDIAgreementUrl completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [QMLicenseAgreement presentUserAgreementInViewController:self contents:[result valueForKeyNotNull:@"strItemDescription"] completion:^(BOOL success) {
                if (success) {
                    [self performSegueWithIdentifier:kQMMainStoryboard sender:nil];
                }
            }];
        }
    }];
}

#pragma mark - Notification

- (void)pushNotificationManager:(QMPushNotificationManager *)__unused pushNotificationManager
       didSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
//    [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
}

- (void)showNotificationForMessage:(QBChatMessage *)chatMessage {
    
    if (chatMessage.senderID == [QMCore instance].currentProfile.userData.ID) {
        // no need to handle notification for self message
        return;
    }
    
    if (chatMessage.dialogID == nil) {
        // message missing dialog ID
        NSAssert(nil, @"Message should contain dialog ID.");
        return;
    }
    
    if ([[QMCore instance].activeDialogID isEqualToString:chatMessage.dialogID]) {
        // dialog is already on screen
        return;
    }
    
    QBChatDialog *chatDialog = [[QMCore instance].chatService.dialogsMemoryStorage chatDialogWithID:chatMessage.dialogID];
    
    if (chatMessage.delayed && chatDialog.type == QBChatDialogTypePrivate) {
        // no reason to display private delayed messages
        // group chat messages are always considered delayed
        return;
    }
    
    [QMSoundManager playMessageReceivedSound];
    
    MPGNotificationButtonHandler buttonHandler = nil;
    UIViewController *hvc = nil;
    
    BOOL hasActiveCall = [QMCore instance].callManager.hasActiveCall;
    BOOL isiOS8 = iosMajorVersion() < 9;
    
    if (hasActiveCall
        || isiOS8) {
        
        // using hvc if active call or visible keyboard on ios8 devices
        // due to notification triggering window to be hidden
        hvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    if (!hasActiveCall) {
        // not showing reply button in active call
        buttonHandler = ^void(MPGNotification * __unused notification, NSInteger buttonIndex) {
            
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
                UINavigationController *navigationController = self.viewControllers.firstObject;
                UIViewController *dialogsVC = navigationController.viewControllers.firstObject;
                [dialogsVC performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
            }
        };
    }
    
    [QMNotification showMessageNotificationWithMessage:chatMessage buttonHandler:buttonHandler hostViewController:hvc];
}

//MARK: - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService
didAddMessageToMemoryStorage:(QBChatMessage *)message
        forDialogID:(NSString *)dialogID {
    
    if (message.messageType == QMMessageTypeContactRequest) {
        
        QBChatDialog *chatDialog = [chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
        [[[QMCore instance].usersService getUserWithID:[chatDialog opponentID] forceLoad:YES]
         continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
             
             [self showNotificationForMessage:message];
             
             return nil;
         }];
    }
    else {
        
        [self showNotificationForMessage:message];
    }
}
@end
