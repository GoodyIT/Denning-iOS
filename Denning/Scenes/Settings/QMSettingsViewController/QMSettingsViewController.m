//
//  QMSettingsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSettingsViewController.h"
#import "QMTableSectionHeaderView.h"
#import "QMColors.h"
#import "QMUpdateUserViewController.h"
#import "QMImagePicker.h"
#import "QMTasks.h"
#import "QMCore.h"
#import "QMProfile.h"
#import "QMImageView.h"
#import "QMNavigationController.h"
#import "QMSettingsFooterView.h"

#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import "QMPhoto.h"
#import "QMImagePreview.h"

static const CGFloat kQMDefaultSectionHeaderHeight = 24.0f;
static const CGFloat kQMStatusSectionHeaderHeight = 40.0f;

typedef NS_ENUM(NSUInteger, QMSettingsSection) {
    
    QMSettingsSectionFullName,
    QMSettingsSectionUserInfo,
    QMSettingsSectionExtra,
    QMSettingsSectionLogout
};

typedef NS_ENUM(NSUInteger, QMUserInfoSection) {
    QMUserInfoSectionUserName,
    QMUserInfoSectionPhone,
    QMUserInfoSectionEmail,
    QMUserInfoSectionChangePassword
};

typedef NS_ENUM(NSUInteger, QMSocialSection) {
    
    QMSocialSectionTellFriend,
    QMSocialSectionGiveFeedback
};

@interface QMSettingsViewController ()

<
QMProfileDelegate,
QMImageViewDelegate,
QMImagePickerResultHandler,
QMUsersServiceListenerProtocol,

NYTPhotosViewControllerDelegate
>

@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) BFTask *subscribeTask;
@property (weak, nonatomic) BFTask *logoutTask;

@property (strong, nonatomic) NSMutableIndexSet *hiddenUserInfoCells;

@end

@implementation QMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    QMCore *core = [QMCore instance];
    [[QMCore instance].usersService addListener:self forUser:core.currentProfile.userData];
    
    self.hiddenUserInfoCells = [NSMutableIndexSet indexSet];
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
    
    // Set tableview background color
    self.tableView.backgroundColor = QMTableViewBackgroundColor();
    
    // configure user data
    [self configureUserData:[DataManager sharedManager].user];
     
    if ([[QBChat instance] isConnected]) {
        self.pushNotificationSwitch.on = core.currentProfile.pushNotificationsEnabled;
    } else {
        self.pushNotificationSwitch.enabled = NO;
    }
    
    // determine account type
//    if (core.currentProfile.accountType != QMAccountTypeEmail) {
//
//        [self.hiddenUserInfoCells addIndex:QMUserInfoSectionEmail];
//        [self.hiddenUserInfoCells addIndex:QMUserInfoSectionChangePassword];
//    }
    
    // subscribe to delegates
    core.currentProfile.delegate = self;
    self.avatarImageView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // smooth rows deselection
    [self qm_smoothlyDeselectRowsForTableView:self.tableView];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)configureUserData:(UserModel*)userData {
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:userData.avatarUrl]
                                    title:userData.username
                           completedBlock:nil];
    
    self.fullNameLabel.text = userData.username;
    
    self.phoneLabel.text = userData.phoneNumber;
    
    self.emailLabel.text = userData.email.length > 0 ? userData.email : NSLocalizedString(@"QM_STR_NONE", nil);
    
//    BOOL hasStatus = userData.status.length > 0;
//
//    self.statusLabel.text =
//    hasStatus ? userData.status : NSLocalizedString(@"QM_STR_NO_STATUS_MESSAGE", nil);
//
//    self.statusLabel.textColor =
//    hasStatus ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
//
}

//MARK: - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUpdateUser]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        QMUpdateUserViewController *updateUserVC = navigationController.viewControllers.firstObject;
        updateUserVC.updateUserField = [sender unsignedIntegerValue];
    }
}

- (IBAction)pushNotificationSwitchPressed:(UISwitch *)sender {
    
    if (self.subscribeTask) {
        // task is in progress
        return;
    }
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    
    BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull __unused task) {
        if (task.faulted) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:task.result duration:3];
        }
        else {
            [QMCore instance].currentProfile.pushNotificationsEnabled ^= YES;
            [QMCore.instance.currentProfile synchronize];
        }
        
        self.pushNotificationSwitch.on = [QMCore instance].currentProfile.pushNotificationsEnabled;
        [navigationController dismissNotificationPanel];
       
        return nil;
    };
    
    if (sender.isOn) {
        self.subscribeTask = [[QMCore.instance.pushNotificationManager registerAndSubscribeForPushNotifications] continueWithBlock:completionBlock];
    }
    else {
        self.subscribeTask = [[QMCore.instance.pushNotificationManager unregisterFromPushNotificationsAndUnsubscribe:NO] continueWithBlock:completionBlock];
    }
}


//MARK: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMSettingsSectionUserInfo
        && [self.hiddenUserInfoCells containsIndex:indexPath.row]) {
        
        return CGFLOAT_MIN;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
            
        case QMSettingsSectionFullName:
            
            break;
            
        case QMSettingsSectionUserInfo:
            
            switch (indexPath.row) {
                case QMUserInfoSectionUserName:
                    [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldUserName)];
                    break;
//                case QMUserInfoSectionPhone:
//                    [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUserInfoSectionPhone)];
//                    break;
//
//                case QMUserInfoSectionEmail:
//                    [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldEmail)];
//                    break;
                    
                case QMUserInfoSectionChangePassword:
                    [self performSegueWithIdentifier:kQMSceneSeguePassword sender:nil];
                    break;
            }
            
            break;
            
        case QMSettingsSectionExtra:
            break;
            
        case QMSettingsSectionLogout:
           
            [DIHelpers logout:self];
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
//    if (section == QMSettingsSectionStatus) {
//
//        QMTableSectionHeaderView *headerView = [[QMTableSectionHeaderView alloc]
//                                                initWithFrame:CGRectMake(0,
//                                                                         0,
//                                                                         CGRectGetWidth(tableView.frame),
//                                                                         kQMStatusSectionHeaderHeight)];
//        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        headerView.title = [NSLocalizedString(@"QM_STR_STATUS", nil) uppercaseString];
//
//        return headerView;
//    }
//
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)section {
    
    if (![self shouldShowHeaderForSection:section]) {
        
        return CGFLOAT_MIN;
    }
//
//    if (section == QMSettingsSectionStatus) {
//
//        return kQMStatusSectionHeaderHeight;
//    }
    
    return kQMDefaultSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == QMSettingsSectionLogout) {
        
        QMSettingsFooterView *footerView = [[QMSettingsFooterView alloc]
                                            initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     CGRectGetWidth(tableView.frame),
                                                                     [QMSettingsFooterView preferredHeight])];
        
        return footerView;
    }
    
    return [super tableView:tableView viewForFooterInSection:section];
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == QMSettingsSectionLogout) {
        
        return [QMSettingsFooterView preferredHeight];
    }
    
    return CGFLOAT_MIN;
}

//MARK: - QMProfileDelegate

- (void)profile:(QMProfile *)__unused currentProfile didUpdateUserData:(QBUUser *)userData {
    [self changeAvatar:userData.avatarUrl];
 
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:userData.avatarUrl]
                                    title:userData.fullName
                           completedBlock:nil];
    self.fullNameLabel.text = userData.fullName;
}

// MARK: - QMUsersServiceListenerProtocol

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUser:(QBUUser *)user {
    
    user.password = QMCore.instance.currentProfile.userData.password;
    [QMCore.instance.currentProfile synchronizeWithUserData:user];
}

//MARK: - QMImageViewDelegate

- (void)imageViewDidTap:(QMImageView *)imageView {
    if (![[QBChat instance] isConnected]) {
        [QMAlert showInformationWithMessage:@"Please subscribe denning chat" inViewController:self];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker takePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker choosePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    NSString *avatarURL = QMCore.instance.currentProfile.userData.avatarUrl;
    if (avatarURL.length > 0) {
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_OPEN_IMAGE", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull __unused action)
                                    {
                                        
                                        [QMImagePreview previewImageWithURL:[NSURL URLWithString:avatarURL] inViewController:self];
                                    }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = imageView;
        alertController.popoverPresentationController.sourceRect = imageView.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) changeAvatar:(NSString*) avatar_url {
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    NSDictionary* params = @{@"email":[DataManager sharedManager].user.email, @"avatar_url":avatar_url};
    
    [[QMNetworkManager sharedManager] setPublicHTTPHeader];
    @weakify(self)
    [[QMNetworkManager sharedManager] sendPutWithURL:CHANGE_AVATAR_URL params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        @strongify(self)
        [(QMNavigationController *)self.navigationController dismissNotificationPanel];
        if (error != nil) {
            [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:kQMDefaultNotificationDismissTime];
        } else {
            [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:kQMDefaultNotificationDismissTime];
        }
    }];
}

//MARK: - QMImagePickerResultHandler

- (void)imagePicker:(QMImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    if (![QMCore.instance isInternetConnected]) {
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
        return;
    }
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak __typeof(self)weakSelf = self;
    [[QMTasks taskUpdateCurrentUserImage:photo progress:nil]
     continueWithBlock:^id(BFTask<QBUUser *> * task __unused) {
         
         [(QMNavigationController *)weakSelf.navigationController dismissNotificationPanel];
         return nil;
     }];
}

//MARK: - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    
    return self.avatarImageView;
}

//MARK: - Share View Controller

- (void)showShareControllerInCell:(UITableViewCell *)cell {
    
    NSArray *items = @[NSLocalizedString(@"QM_STR_SHARE_TEXT", nil)];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard];
    
    if (activityViewController.popoverPresentationController) {
        // iPad support
        activityViewController.popoverPresentationController.sourceView = cell;
        activityViewController.popoverPresentationController.sourceRect = cell.bounds;
    }
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

//MARK: - Helpers

- (BOOL)shouldShowHeaderForSection:(NSInteger)section {
    
    if (section == QMSettingsSectionFullName) {
        
        return NO;
    }
    
    if (section == QMSettingsSectionUserInfo
        && [self.hiddenUserInfoCells containsIndex:QMUserInfoSectionPhone]
        && [self.hiddenUserInfoCells containsIndex:QMUserInfoSectionEmail]) {
        
        return NO;
    }
    
    return YES;
}

@end
