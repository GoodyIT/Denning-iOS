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
#import "QMDateUtils.h"
#import "QBChatDialog+OpponentID.h"
#import "MessageViewController.h"
#import "QMDialogsDataSource.h"
#import "QMUserInfoViewController.h"
#import "QMGroupInfoViewController.h"


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
{
    NSInteger selectedIndex;
}
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;

/**
 *  Data sources
 */
@property (weak, nonatomic) BFTask *addUserTask;
@property (strong, nonatomic) id observerWillEnterForeground;

@property (strong, nonatomic) NSMutableArray* items, *originItems;
@property (strong, nonatomic) IBOutlet UISegmentedControl *userTypeSegment;
@property (strong, nonatomic) NSString* filter;
@end

@implementation QMDialogsViewController

//MARK: - Life cycle

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observerWillEnterForeground];
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    selectedIndex = 0;
    
    // Subscribing delegates
    [QMCore.instance.chatService addDelegate:self];
    [QMCore.instance.usersService addDelegate:self];
    
    // Data sources init
    // search implementation
    [self configureSearch];
    
    [self hideFilter];
    
    // registering nibs for current VC and search results VC
    [self registerNibs];
    
    [self performAutoLoginAndFetchData];
    
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
         
         [self hideFilter];
     }];
}

- (void) hideFilter {
    CGRect rectForFilter = CGRectMake(0, 0, self.view.frame.size.width, _searchController.searchBar.frame.size.height + 38);
    _userTypeSegment.hidden = NO;
    if (![DataManager sharedManager].isStaff && ![DataManager sharedManager].isDenningUser) {
        rectForFilter = CGRectMake(0, 0, self.view.frame.size.width, _searchController.searchBar.frame.size.height-8);
        _userTypeSegment.hidden = YES;
    }
    
    [self.tableView.tableHeaderView setFrame:rectForFilter];
}

- (void) updateDialogSource {
    [self updateDataSourceByScope:selectedIndex];
    [self performSearch];
}

- (IBAction)didChangeUserType:(UISegmentedControl *)sender {
    [self updateDataSourceByScope:sender.selectedSegmentIndex];
    [self performSearch];
}

-(NSArray*) filterDialogInArray:(NSMutableArray*) groupDialogs
{
    NSMutableArray* clientDialgs = [NSMutableArray new];
    NSMutableArray* staffDialgs = [NSMutableArray new];
    NSMutableArray* matterDialgs = [NSMutableArray new];
    for (QBChatDialog* dialog in groupDialogs) {
        if (dialog.type == QBChatDialogTypeGroup) {
            if ([[DIHelpers getTag:dialog] isEqualToString:kChatColleaguesTag]) {
                [staffDialgs addObject:dialog];
            } else if ([[DIHelpers getTag:dialog] isEqualToString:kChatClientsTag]) {
                [clientDialgs addObject:dialog];
            } else if ([[DIHelpers getTag:dialog] isEqualToString:kChatMattersTag]){
                [matterDialgs addObject:dialog];
            }
        } else if (dialog.type == QBChatDialogTypePrivate) {
            QBUUser* user = [[QMCore instance].usersService.usersMemoryStorage userWithID:dialog.opponentID];
            if ([user.tags containsObject:kColleague]) {
                [staffDialgs addObject:dialog];
            } else if ([user.tags containsObject:kClient]) {
                [clientDialgs addObject:dialog];
            }
        }
    }
    
    return @[staffDialgs, clientDialgs, matterDialgs];
}

- (void) updateDataSourceByScope:(NSInteger) index {
    selectedIndex = index;
    _items = _originItems = [[QMCore.instance.chatService.dialogsMemoryStorage dialogsSortByLastMessageDateWithAscending:NO] mutableCopy];
    NSArray* filteredArray = [self filterDialogInArray:_originItems];
    switch (index) {
        case 0:
            // same as above
            break;
        case 1:
            _items = _originItems = filteredArray[0];
            break;
        case 2:
            _items = _originItems = filteredArray[1];
            break;
        case 3:
            // Denning support
            _items = _originItems = filteredArray[2];
            break;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    _userTypeSegment.selectedSegmentIndex = selectedIndex = 0;
    [self updateDialogSource];
    
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
    
    [(MessageViewController*)self.parentViewController updateBadge];
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
                /*|| (errorCode == kBFMultipleErrorsError
                    && ([task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][0] code] == kQMUnauthorizedErrorCode
                        || [task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][1] code] == kQMUnauthorizedErrorCode))*/) {
                        
                        return [QMCore.instance logout];
                    }
        }
        
        [self updateDataAndEndRefreshing];
        
        [self updateDialogSource];
        
        return [BFTask cancelledTask];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (!task.isCancelled) {
            [self performSegueWithIdentifier:kAuthSegue sender:nil];
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
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _searchController.searchBar.frame.size.height + 38)];
    [containerView addSubview:_searchController.searchBar];
    [containerView addSubview:_userTypeSegment];
    
    self.tableView.tableHeaderView =  containerView;
    
    [_userTypeSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_searchController.searchBar.mas_bottom); //with is an optional semantic filler
        make.centerX.equalTo(containerView.mas_centerX);
        make.bottom.equalTo(containerView.mas_bottom).offset(-8);
    }];
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
        
        [cell setPosition:[DIHelpers getUserPosition:recipient.email]];
    } else {
        [cell setPosition:[DIHelpers getGroupPosition:chatDialog]];
        [cell setTitle:chatDialog.name avatarUrl:chatDialog.photo];
    }
    
    cell.didTapAvatar = ^(QMTableViewCell *cell) {
        
    };
    
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
    QBChatDialog *chatDialog = self.items[indexPath.row];
    if (![DIHelpers canLeaveChatforDialog:chatDialog]) {
        return NO;
    }
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

//MARK: - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    _filter = searchController.searchBar.text;
    [self performSearch];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    _filter = searchText;
    [self performSearch];
}

- (void)performSearch {
    
    if (_filter.length == 0) {
        
        _items = _originItems;
        [self.tableView reloadData];
        return;
    }

    NSMutableArray *dialogsSearchResult = [NSMutableArray new];
    for (QBChatDialog* dialog in _originItems) {
        if ([dialog.name localizedCaseInsensitiveContainsString:_filter]) {
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
    searchController.searchBar.text = _filter = @"";
    
    [self performSearch];
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
 
    [(MessageViewController*)self.parentViewController updateBadge];
    [self updateDialogSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didAddChatDialogToMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    [self updateDialogSource];
    [self.tableView reloadData];
    
    [(MessageViewController*)self.parentViewController updateBadge];
}

- (void)chatService:(QMChatService *)__unused chatService
didAddMessagesToMemoryStorage:(NSArray<QBChatMessage *> *)__unused messages
        forDialogID:(NSString *)__unused dialogID {
    
    [(MessageViewController*)self.parentViewController updateBadge];
    [self updateDialogSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didAddMessageToMemoryStorage:(QBChatMessage *)__unused message
        forDialogID:(NSString *)__unused dialogID {
    
    [(MessageViewController*)self.parentViewController updateBadge];
    [self updateDialogSource];
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
    
    [(MessageViewController*)self.parentViewController updateBadge];
    [self updateDialogSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didReceiveNotificationMessage:(QBChatMessage *)message
       createDialog:(QBChatDialog *)__unused dialog {
    
    if (message.addedOccupantsIDs.count > 0) {
        
        [QMCore.instance.usersService getUsersWithIDs:message.addedOccupantsIDs];
    }
    
    [(MessageViewController*)self.parentViewController updateBadge];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    [(MessageViewController*)self.parentViewController updateBadge];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)__unused dialogs {
    
    [(MessageViewController*)self.parentViewController updateBadge];
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
    
   [self.tableView reloadData];
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
                                    [[QMCore.instance.chatService deleteDialogWithID:chatDialog.ID] continueWithSuccessBlock:completionBlock];
//                                    if (chatDialog.type == QBChatDialogTypeGroup) {
//
//                                        chatDialog.occupantIDs = [QMCore.instance.contactManager occupantsWithoutCurrentUser:chatDialog.occupantIDs];
//                                        [[QMCore.instance.chatManager leaveChatDialog:chatDialog] continueWithSuccessBlock:completionBlock];
//                                    }
//                                    else {
//                                        // private and public group chats
//
//                                    }
                                    
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
         [self.tableView reloadData];
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
