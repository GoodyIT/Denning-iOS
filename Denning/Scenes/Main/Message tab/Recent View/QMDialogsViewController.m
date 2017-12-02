//
//  QMDialogsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDialogsViewController.h"
#import "QMSearchResultsController.h"
#import "QMDialogCell.h"
#import "QMNoResultsCell.h"
#import "QMChatVC.h"
#import "QMTasks.h"
#import <QMDateUtils.h>
#import "QBChatDialog+OpponentID.h"
#import "MessageViewController.h"
#import "QMDialogsDataSource.h"

// category
//#import "UINavigationController+QMNotification.h"

static const NSInteger kQMNotAuthorizedInRest = -1000;
static const NSInteger kQMUnauthorizedErrorCode = -1011;
static NSString *const kQMDialogsSearchDescriptorKey = @"name";


@interface QMDialogsViewController ()

<
QMUsersServiceDelegate,
QMChatServiceDelegate,
QMChatConnectionDelegate,

UITableViewDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating,

UISearchBarDelegate,

QMPushNotificationManagerDelegate,

QMSearchResultsControllerDelegate,

UIGestureRecognizerDelegate
>
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;

/**
 *  Data sources
 */
@property (weak, nonatomic) BFTask *addUserTask;
@property (strong, nonatomic) id observerWillEnterForeground;

@property (strong, nonatomic) NSMutableArray* items, *originItems;

@end

@implementation QMDialogsViewController

//MARK: - Life cycle

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observerWillEnterForeground];
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Subscribing delegates
    [QMCore.instance.chatService addDelegate:self];
    [QMCore.instance.usersService addDelegate:self];
    
    // Data sources init
    // search implementation
    [self configureSearch];
    
    // registering nibs for current VC and search results VC
    [self registerNibs];
    
//    [self performAutoLoginAndFetchData];
    
    // adding refresh control task
    if (self.refreshControl) {
        
        self.refreshControl.backgroundColor = [UIColor clearColor];
        [self.refreshControl addTarget:self
                                action:@selector(updateDataAndEndRefreshing)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    @weakify(self);
    // adding notification for showing chat connection
    self.observerWillEnterForeground =
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull __unused note)
     {
         @strongify(self);
         if (![QBChat instance].isConnected) {
             [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading
                                                                                   message:NSLocalizedString(@"QM_STR_CONNECTING", nil)
                                                                                  duration:0];
         }
     }];
}

- (void) updateDialogSource {
    _items = _originItems = [[QMCore.instance.chatService.dialogsMemoryStorage dialogsSortByLastMessageDateWithAscending:NO] mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.searchController.isActive) {
        
        self.tabBarController.tabBar.hidden = YES;
        // smooth rows deselection
        [self qm_smoothlyDeselectRowsForTableView:self.searchResultsController.tableView];
    }
    else {
        
        // smooth rows deselection
        [self qm_smoothlyDeselectRowsForTableView:self.tableView];
    }
    
    if (self.refreshControl.isRefreshing) {
        // fix for freezing refresh control after tab bar switch
        // if it is still active
        CGPoint offset = self.tableView.contentOffset;
        [self.refreshControl endRefreshing];
        [self.refreshControl beginRefreshing];
        self.tableView.contentOffset = offset;
    }
    
    [self performAutoLoginAndFetchData];
    [self updateDialogSource];
    [self.tableView reloadData];
}

- (void)performAutoLoginAndFetchData {
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading
                                                                          message:NSLocalizedString(@"QM_STR_CONNECTING", nil)
                                                                         duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    
    [[[QMCore.instance login] continueWithBlock:^id(BFTask *task) {
        
        [(QMNavigationController *)navigationController dismissNotificationPanel];
        if (task.isFaulted) {
            
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

//MARK: - Init methods

- (void)configureSearch {
    
    self.searchResultsController = [[QMSearchResultsController alloc] init];
    self.searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

//MARK: - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatDialog *chatDialog = self.items[indexPath.row];
    if (![chatDialog.ID isEqualToString:QMCore.instance.activeDialogID]) {
        [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return [QMDialogCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * identifier = @"QMDialogCell";
    
    QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    QBChatDialog *chatDialog = self.items[indexPath.row];
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *recipient = [QMCore.instance.usersService.usersMemoryStorage userWithID:[chatDialog opponentID]];
        
        if (recipient.fullName != nil) {
            
            [cell setTitle:recipient.fullName avatarUrl:recipient.avatarUrl];
        }
        else {
            
            [cell setTitle:NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil) avatarUrl:nil];
        }
        //        [cell configureCellWithUser:recipient];
    } else {
        
        [cell setTitle:chatDialog.name avatarUrl:chatDialog.photo];
        //        [cell configureCellWithChatDialog:chatDialog];
    }
    
    // there was a time when updated at didn't exist
    // in order to support old dialogs, showing their date as last message date
    NSDate *date = chatDialog.updatedAt ?: chatDialog.lastMessageDate;
    
    NSString *time = [QMDateUtils formattedShortDateString:date];
    [cell setTime:time];
    [cell setBody:chatDialog.lastMessageText];
    [cell setBadgeNumber:chatDialog.unreadMessagesCount];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)__unused tableView canEditRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)__unused tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        QBChatDialog *chatDialog = self.items[indexPath.row];
        [self dialogsDataSource:nil commitDeleteDialog:chatDialog];
    }
}

- (NSString *)tableView:(UITableView *)__unused tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatDialog *chatDialog = self.items[indexPath.row];
    
    return chatDialog.type == QBChatDialogTypePrivate ?
    NSLocalizedString(@"QM_STR_DELETE", nil) : NSLocalizedString(@"QM_STR_LEAVE", nil);
}

//MARK: - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMNavigationController *chatNavigationController = segue.destinationViewController;
        chatNavigationController.currentAdditionalNavigationBarHeight =
        [(QMNavigationController *)self.navigationController currentAdditionalNavigationBarHeight];
        
        QMChatVC *chatViewController = (QMChatVC *)chatNavigationController.topViewController;
        chatViewController.chatDialog = sender;
    }
}

// MARK: - Overrides

- (void)setAdditionalNavigationBarHeight:(CGFloat)additionalNavigationBarHeight {
    if (!self.searchController.isActive) {
        [super setAdditionalNavigationBarHeight:additionalNavigationBarHeight];
    }
}

//MARK: - UISearchControllerDelegate


//MARK: - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    [self performSearch:searchController.searchBar.text];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    [self performSearch:searchText];
}


- (void)performSearch:(NSString *)searchText {
    
    if (searchText.length == 0) {
        
        _items = _originItems;
        [self.tableView reloadData];
        return;
    }
    
    // dialogs local search
//    NSSortDescriptor *dialogsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kQMDialogsSearchDescriptorKey ascending:NO];
//    NSArray *dialogs = [QMCore.instance.chatService.dialogsMemoryStorage dialogsWithSortDescriptors:@[dialogsSortDescriptor]];
//
//    NSPredicate *dialogsSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", searchText];
    NSMutableArray *dialogsSearchResult = [NSMutableArray new];
    for (QBChatDialog* dialog in _originItems) {
        if ([dialog.name containsString:searchText.lowercaseString]) {
            [dialogsSearchResult addObject:dialog];
        }
    }
    
    _items = [dialogsSearchResult copy];
    
     [self.tableView reloadData];
}

//MARK: - QMSearchResultsControllerDelegate


- (void)willPresentSearchController:(UISearchController *)__unused searchController {
    
    MessageViewController* messageVC = (MessageViewController*)self.parentViewController;
    messageVC.navigationController.navigationBarHidden = YES;
    
    self.additionalNavigationBarHeight = 0;
    self.tabBarController.tabBar.hidden = YES;
}

- (void)willDismissSearchController:(UISearchController *)__unused searchController {
    
    MessageViewController* messageVC = (MessageViewController*)self.parentViewController;
    messageVC.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    searchController.searchBar.text = @"";
}

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController
         willBeginScrollResults:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController
                didSelectObject:(id)object {
    
    [self performSegueWithIdentifier:kQMSceneSegueChat sender:object];
}

//MARK: - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService
didAddChatDialogsToMemoryStorage:(NSArray *)__unused chatDialogs {
 
    [self updateDialogSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didAddChatDialogToMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    [self updateDialogSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didAddMessagesToMemoryStorage:(NSArray<QBChatMessage *> *)__unused messages
        forDialogID:(NSString *)__unused dialogID {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didAddMessageToMemoryStorage:(QBChatMessage *)__unused message
        forDialogID:(NSString *)__unused dialogID {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)__unused chatDialogID {
    
    if (self.items.count == 0) {
    
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            self.navigationItem.searchController = nil;
        }
        else {
            self.tableView.tableHeaderView = nil;
        }
#else
        self.tableView.tableHeaderView = nil;
#endif
        
    }
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didReceiveNotificationMessage:(QBChatMessage *)message
       createDialog:(QBChatDialog *)__unused dialog {
    
    if (message.addedOccupantsIDs.count > 0) {
        
        [QMCore.instance.usersService getUsersWithIDs:message.addedOccupantsIDs];
    }
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)__unused dialogs {
    
    [self.tableView reloadData];
}

//MARK: - QMPushNotificationManagerDelegate

- (void)pushNotificationManager:(QMPushNotificationManager *)__unused pushNotificationManager
       didSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
}

//MARK: - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)__unused chatService {
    
    [QMTasks taskFetchAllData];
    [QMTasks taskUpdateContacts];
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeSuccess
                                                                          message:NSLocalizedString(@"QM_STR_CHAT_CONNECTED", nil)
                                                                         duration:kQMDefaultNotificationDismissTime];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)__unused chatService {
    
    [QMTasks taskFetchAllData];
    [QMTasks taskUpdateContacts];
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeSuccess
                                                                          message:NSLocalizedString(@"QM_STR_CHAT_RECONNECTED", nil)
                                                                         duration:kQMDefaultNotificationDismissTime];
}
/*
 - (void)chatService:(QMChatService *)__unused chatService
 chatDidNotConnectWithError:(NSError *)error {
 
 [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CHAT_FAILED_TO_CONNECT_WITH_ERROR", nil), error.localizedDescription]];
 }
 */

//MARK: - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService
didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    if (!_searchController.isActive) {
        
        [self.tableView reloadData];
    }
}

- (void)usersService:(QMUsersService *)__unused usersService
         didAddUsers:(NSArray<QBUUser *> *)__unused user {
    
    [self.tableView reloadData];
}

- (void)usersService:(QMUsersService *)__unused usersService
      didUpdateUsers:(NSArray<QBUUser *> *)__unused users {
    
    [self.tableView reloadData];
}

//MARK: - QMDialogsDataSourceDelegate

- (void)dialogsDataSource:(QMDialogsDataSource *)__unused dialogsDataSource
       commitDeleteDialog:(QBChatDialog *)chatDialog {
    
    NSString *dialogName = chatDialog.name;
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *user = [QMCore.instance.usersService.usersMemoryStorage userWithID:[chatDialog opponentID]];
        dialogName = user.fullName;
    }
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_DELETE_DIALOG", nil), dialogName]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    
                                    [self.tableView setEditing:NO animated:YES];
                                }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    
                                    BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull __unused task) {
                                        
                                        if ([QMCore.instance.activeDialogID isEqualToString:chatDialog.ID]) {
                                            
//                                            [(QMSplitViewController *)self.splitViewController showPlaceholderDetailViewController];
                                        }
                                        
                                        [SVProgressHUD dismiss];
                                        return nil;
                                    };
                                    
                                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                                    if (chatDialog.type == QBChatDialogTypeGroup) {
                                        
                                        chatDialog.occupantIDs = [QMCore.instance.contactManager occupantsWithoutCurrentUser:chatDialog.occupantIDs];
                                        [[QMCore.instance.chatManager leaveChatDialog:chatDialog] continueWithSuccessBlock:completionBlock];
                                    }
                                    else {
                                        // private and public group chats
                                        [[QMCore.instance.chatService deleteDialogWithID:chatDialog.ID] continueWithSuccessBlock:completionBlock];
                                    }
                                }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateDataAndEndRefreshing {
    
    @weakify(self);
    
    BFTask *fetchAllDataTask = [QMTasks taskFetchAllData];
    BFTask *fetchContactsTask = [QMTasks taskUpdateContacts];
    [[BFTask taskForCompletionOfAllTasks:@[fetchAllDataTask, fetchContactsTask]]
     continueWithBlock:^id (BFTask * __unused t) {
         @strongify(self);
         
         [self.refreshControl endRefreshing];
         
         return nil;
     }];
}

//MARK: - Register nibs

- (void)registerNibs {
    
    [QMDialogCell registerForReuseInTableView:self.tableView];
    [QMDialogCell registerForReuseInTableView:self.searchResultsController.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.searchResultsController.tableView];
}

@end
