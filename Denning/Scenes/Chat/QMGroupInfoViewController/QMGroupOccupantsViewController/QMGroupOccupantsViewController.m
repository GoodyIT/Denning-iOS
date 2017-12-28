//
//  QMGroupOccupantsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupOccupantsViewController.h"
#import "QMGroupOccupantsDataSource.h"
#import "QMGroupAddUsersViewController.h"
#import "QMTableSectionHeaderView.h"
#import "QMContactCell.h"
#import "GroupInfoContactCell.h"
#import "QMColors.h"
#import "QMCore.h"
#import "QMAlert.h"
#import "QMNavigationController.h"
#import "QMUserInfoViewController.h"
#import "NSArray+Intersection.h"
#import "SVProgressHUD.h"
#import "QMSplitViewController.h"

static const CGFloat kQMSectionHeaderHeight = 32.0f;

@interface QMGroupOccupantsViewController ()

<
QMChatServiceDelegate,
QMChatConnectionDelegate,
QMContactListServiceDelegate,
QMUsersServiceDelegate
>

@property (strong, nonatomic) QMGroupOccupantsDataSource *dataSource;

@property (weak, nonatomic) BFTask *leaveTask;
@property (weak, nonatomic) BFTask *addUserTask;
@property (weak, nonatomic) BFTask *updateRoleTask;

@end

@implementation QMGroupOccupantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    
    // Set tableview background color
    self.tableView.backgroundColor = QMTableViewBackgroundColor();
    
    // configure data sources
    [self configureDataSource];
  
    // subscribe for delegates
    [QMCore.instance.chatService addDelegate:self];
    [QMCore.instance.contactListService addDelegate:self];
    [QMCore.instance.usersService addDelegate:self];
    
    // configure data
    [self updateOccupants];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // smooth rows deselection
    [self qm_smoothlyDeselectRowsForTableView:self.tableView];
}

- (void) updateUserRole:(NSString*) role userID:(NSInteger) userID inIndexPath:(NSIndexPath*) indexPath{
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    self.updateRoleTask = [[[QMCore instance].chatManager changeUserWithID:userID toRole:role forGroupChatDialog:self.chatDialog] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        [SVProgressHUD dismiss];
        
        if (!t.isFaulted) {
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            
            if (![QBChat instance].isConnected) {
                
                [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) actionSuccess:NO inViewController:self];
            }
        }
        return nil;
    }];
}

- (void)configureDataSource {
    
    self.dataSource = [[QMGroupOccupantsDataSource alloc] init];
    self.tableView.dataSource = self.dataSource;
    
    self.dataSource.chatDialog = _chatDialog;
    @weakify(self);
    self.dataSource.didAddUserBlock = ^(UITableViewCell *cell) {

        @strongify(self);
        if (self.addUserTask) {
            // task in progress
            return;
        }

        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSUInteger userIndex = [self.dataSource userIndexForIndexPath:indexPath];
        QBUUser *user = self.dataSource.items[userIndex];

        self.addUserTask = [[QMCore.instance.contactManager addUserToContactList:user] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {

            [SVProgressHUD dismiss];

            if (!task.isFaulted) {

                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {

                if (![QBChat instance].isConnected) {

                    [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) actionSuccess:NO inViewController:self];
                }
            }

            return nil;
        }];
    };
    
    self.dataSource.updateRoleBlock = ^(UITableViewCell *cell) {
        @strongify(self);
        if (self.updateRoleTask) {
            // task in progress
            return;
        }
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSUInteger userIndex = [self.dataSource userIndexForIndexPath:indexPath];
        QBUUser *user = self.dataSource.items[userIndex];
        
        NSString* role = [DIHelpers getCurrentUserRole:user.ID fromChatDialog:self.chatDialog];
        
        if (!([role isEqualToString:kRoleAdminTag]) || [DataManager sharedManager].isDenningUser) {
            // Only Denning Staff & Admin can assign the role.
            return;
        }
        
        UIAlertController *customActionSheet = [UIAlertController alertControllerWithTitle:@"User Role" message:@"Please select role to assign." preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *firstButton = [UIAlertAction actionWithTitle:@"Admin" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self updateUserRole:kRoleAdminTag userID:user.ID inIndexPath:indexPath];
        }];
        [firstButton setValue:[UIColor babyRed] forKey:@"titleTextColor"];
        [firstButton setValue:@(role == kRoleAdminTag) forKey:@"checked"];
        
        UIAlertAction *secondButton = [UIAlertAction actionWithTitle:@"Normal" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self updateUserRole:kRoleNormalTag userID:user.ID inIndexPath:indexPath];
        }];
        [secondButton setValue:[UIColor babyBlue] forKey:@"titleTextColor"];
        [secondButton setValue:@(role == kRoleNormalTag) forKey:@"checked"];
        
        UIAlertAction *thirdButton = [UIAlertAction actionWithTitle:@"Reader" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
           [self updateUserRole:kRoleReaderTag userID:user.ID inIndexPath:indexPath];
        }];
        [thirdButton setValue:[UIColor babyGreen] forKey:@"titleTextColor"];
        [thirdButton setValue:@(role == kRoleReaderTag) forKey:@"checked"];
        
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            //cancel
        }];
        [cancelButton setValue:[UIColor darkGrayColor] forKey:@"titleTextColor"];
        
        [customActionSheet addAction:firstButton];
        [customActionSheet addAction:secondButton];
        [customActionSheet addAction:thirdButton];
        [customActionSheet addAction:cancelButton];
        
        [self presentViewController:customActionSheet animated:YES completion:nil];
    };
}

//MARK: - Methods

- (NSMutableArray*) filterItems:(NSArray*) items {
    NSMutableArray* newItems = [NSMutableArray new];
    
    if ([DIHelpers isSupportChat:self.chatDialog]) {
        NSArray* users = [QMCore.instance.usersService.usersMemoryStorage usersWithIDs:_chatDialog.occupantIDs];
        for (QBUUser* user in users) {
            for (ChatFirmModel* firmModel in [DataManager sharedManager].denningContactArray) {
                NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.email CONTAINS[cd] %@", user.email];
                NSArray *filteredUsers = [firmModel.users filteredArrayUsingPredicate:usersSearchPredicate];
                if (filteredUsers.count == 0 && ![user.email isEqualToString:[QBSession currentSession].currentUser.email]) {
                    [newItems addObject:user];
                }
            }
        }
        
    } else {
        newItems = [items mutableCopy];
    }
    
    return [newItems mutableCopy];
}

- (void)updateOccupants {
    
    [[QMCore.instance.usersService getUsersWithIDs:self.chatDialog.occupantIDs] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull t) {
        if (t.result) {
            
            NSArray* items = [[t.result sortedArrayUsingComparator:^NSComparisonResult(QBUUser *u1, QBUUser *u2) {
                return [u1.fullName caseInsensitiveCompare:u2.fullName];
            }] mutableCopy];
            
            self.dataSource.items = [self filterItems:items];
            [self.tableView reloadData];
        }
        
        return nil;
    }];
}

//MARK: - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUserInfo]) {
        
        QMUserInfoViewController *userInfoVC = segue.destinationViewController;
        userInfoVC.user = sender;
    }
    else if ([segue.identifier isEqualToString:kQMSceneSegueGroupAddUsers]) {
        
        QMGroupAddUsersViewController *addUsersVC = segue.destinationViewController;
        addUsersVC.chatDialog = sender;
    }
}

- (void)updateNotificationsSettingsForDialog:(NSString *)dialogID enabled:(BOOL)enabled {
    
    NSURLSessionConfiguration *configuration =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:configuration];
    
    NSString *path = [NSString stringWithFormat:@"https://api.quickblox.com/chat/Dialog/%@/notifications.json", dialogID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:QBSession.currentSession.sessionDetails.token forHTTPHeaderField:@"QB-Token"];
    
    NSString *data = [NSString stringWithFormat:@"{\"enabled\":\"%tu\"}", enabled ? 1 : 0];
    
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *dataTask =
    [defaultSession dataTaskWithRequest:request
                      completionHandler:^(NSData* data, NSURLResponse *response, NSError *error)
    {
        
        if (!error) {
            NSError *serializationError = nil;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&serializationError];
            NSNumber* enable = [[json objectForKeyNotNull:@"notifications"] valueForKeyNotNull:@"enabled"];
            [QMCore.instance.chatManager changeCustomData:@{@"notifications":enable} forGroupChatDialog:_chatDialog];
        }
    }];
    
    [dataTask resume];
}

- (IBAction)notificationSetting:(UISwitch *)sender {
    [self updateNotificationsSettingsForDialog:_chatDialog.ID enabled:sender.on];
}

//MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == self.dataSource.addMemberCellIndex) {
        if ([DIHelpers isSupportChat:self.chatDialog]) {
           NSString* role = [DIHelpers getCurrentUserRole:[QBSession currentSession].currentUser.ID fromChatDialog:self.chatDialog];
            if  ([DataManager sharedManager].isDenningUser || [role isEqualToString:kRoleAdminTag]) {
                [self performSegueWithIdentifier:kQMSceneSegueGroupAddUsers sender:self.chatDialog];
            }
        } else {
            [self performSegueWithIdentifier:kQMSceneSegueGroupAddUsers sender:self.chatDialog];
        }
    }
    else if (indexPath.row == self.dataSource.leaveChatCellIndex) {
       
        if (self.leaveTask) {
            // task in progress
            return;
        }
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:nil
                                              message:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_LEAVE", nil), self.chatDialog.name]
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull __unused action) {
                                                              
                                                          }]];
        
        __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LEAVE", nil)
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull __unused action) {
                                                              
                                                              [(QMNavigationController *)navigationController showNotificationWithType:QMNotificationPanelTypeLoading
                                                                                                                               message:NSLocalizedString(@"QM_STR_LOADING", nil)
                                                                                                                              duration:0];
                                                              
                                                              self.leaveTask = [[QMCore.instance.chatManager leaveChatDialog:self.chatDialog] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                                                                  
                                                                  [(QMNavigationController *)navigationController dismissNotificationPanel];
                                                                  
                                                                  if (!task.isFaulted) {
                                                                      
                                                                      if (self.splitViewController.isCollapsed) {
                                                                          
                                                                          [navigationController popToRootViewControllerAnimated:YES];
                                                                      }
                                                                      else {
                                                                          
                                                                          [(QMSplitViewController *)self.splitViewController showPlaceholderDetailViewController];
                                                                      }
                                                                  }
                                                                  
                                                                  return nil;
                                                              }];
                                                          }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        
        NSUInteger userIndex = [self.dataSource userIndexForIndexPath:indexPath];
        QBUUser *user = self.dataSource.items[userIndex];
        
        if (user.ID == QMCore.instance.currentProfile.userData.ID) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
        [self performSegueWithIdentifier:kQMSceneSegueUserInfo sender:user];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)__unused section {
    
    QMTableSectionHeaderView *headerView = [[QMTableSectionHeaderView alloc] initWithFrame:CGRectMake(0,
                                                                                                      0,
                                                                                                      CGRectGetWidth(tableView.frame),
                                                                                                      kQMSectionHeaderHeight)];
    
    headerView.title = [NSString stringWithFormat:@"%tu %@", self.dataSource.items.count, NSLocalizedString(@"QM_STR_MEMBERS", nil)];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)__unused section {
    
    return kQMSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource heightForRowAtIndexPath:indexPath];
}

// MARK: - Overrides

- (void)setAdditionalNavigationBarHeight:(CGFloat)__unused additionalNavigationBarHeight {
    // do not set for this controller
}

//MARK: - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if ([chatDialog isEqual:self.chatDialog]) {
        
        [self updateOccupants];
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)dialogs {
    
    if ([dialogs containsObject:self.chatDialog]) {
        
        [self updateOccupants];
    }
}

//MARK: - QMContactListService

- (void)contactListServiceDidLoadCache {
    
    [self updateOccupants];
}

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    [self updateOccupants];
}

//MARK: - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    [self updateOccupants];
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)user {
    
    NSArray *idsOfUsers = [user valueForKeyPath:@keypath(QBUUser.new, ID)];
    
    if ([self.chatDialog.occupantIDs qm_containsObjectFromArray:idsOfUsers]) {
        
        [self updateOccupants];
    }
}

// MARK: QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)users {
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:users.count];
    for (QBUUser *user in users) {
        NSIndexPath *indexPath = [self.dataSource indexPathForObject:user];
        if (indexPath != nil) {
            [indexPaths addObject:indexPath];
        }
    }
    if (indexPaths.count > 0) {
        [self.tableView reloadRowsAtIndexPaths:[indexPaths copy] withRowAnimation:UITableViewRowAnimationNone];
    }
}

//MARK: - register nibs

- (void)registerNibs {
    
//    [QMContactCell registerForReuseInTableView:self.tableView];
    [GroupInfoContactCell registerForReuseInTableView:self.tableView];
}

@end
