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

static const NSInteger kQMUnAuthorizedErrorCode = -1011;

@interface MainTabBarController ()
<QMChatServiceDelegate,
QMChatConnectionDelegate>
@property (nonatomic, strong) NSArray *menuItems;


@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[QMCore instance].chatService addDelegate:self];
    
    [self performAutoLoginAndFetchData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[QMCore instance].chatService removeDelegate:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)performAutoLoginAndFetchData {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [[[[QMCore instance] login] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (task.isFaulted) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if (task.error.code == kQMUnAuthorizedErrorCode
                || (task.error.code == kBFMultipleErrorsError
                    && ([task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][0] code] == kQMUnAuthorizedErrorCode
                        || [task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][1] code] == kQMUnAuthorizedErrorCode))) {
                        
                        return [[QMCore instance] logout];
                    }
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
          
          [RWDropdownMenuItem itemWithText:@"Chat" image:[UIImage imageNamed:@"icon_message"] action:^{
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

#pragma mark - Notification

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
                
                UINavigationController *navigationController = self.viewControllers.firstObject;
                UIViewController *dialogsVC = navigationController.viewControllers.firstObject;
                [dialogsVC performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
            }
        };
    }
    
    [QMNotification showMessageNotificationWithMessage:chatMessage buttonHandler:buttonHandler hostViewController:hvc];
}


#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if (message.messageType == QMMessageTypeContactRequest) {
        
        QBChatDialog *chatDialog = [chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
        [[[QMCore instance].usersService getUserWithID:[chatDialog opponentID]] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
            
            [self showNotificationForMessage:message];
            
            return nil;
        }];
    }
    else {
        
        [self showNotificationForMessage:message];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
