//
//  ClientContactViewController.m
//  Denning
//
//  Created by DenningIT on 06/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ClientContactViewController.h"
//#import "QMContactsDataSource.h"
//#import "QMContactsSearchDataSource.h"
//#import "QMGlobalSearchDataSource.h"
//#import "QMContactsSearchDataProvider.h"
#import "MessageViewController.h"

#import "QMUserInfoViewController.h"
#import "QMSearchResultsController.h"

#import "QMCore.h"
#import "QMTasks.h"
#import "QMAlert.h"
#import "QMHelpers.h"

#import "QMContactCell.h"
#import "QMNoContactsCell.h"
#import "QMNoResultsCell.h"
#import "ChatContactCell.h"

@interface ClientContactViewController ()
<
UISearchControllerDelegate,
UISearchBarDelegate,

QMContactListServiceDelegate,
QMUsersServiceDelegate,

ChatContactDelegate,
SWTableViewCellDelegate
>
{
    NSMutableArray* originalContacts;
    NSMutableArray* contactsArray;
    NSString* selectedFirmCode;
}

@property (strong, nonatomic) UISearchController *searchController;

/**
 *  Data sources
 */
//@property (strong, nonatomic) QMContactsDataSource *dataSource;

@property (strong, nonatomic) NSString* filter;

@property (weak, nonatomic) BFTask *addUserTask;

@property (weak, nonatomic) BFTask *task;

@end

@implementation ClientContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // search implementation
    [self configureSearch];
    
    // setting up data source
//    [self configureDataSources];
    [self registerNibs];
    
    // filling data source
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateItemsFromContactListWithCompletion:^{
            [navigationController dismissNotificationPanel];
            // registering nibs for current VC and search results VC
            
            
            [self updateFriendList];
        }];
    });
    
    // subscribing for delegates
    [[QMCore instance].contactListService addDelegate:self];
    [[QMCore instance].usersService addDelegate:self];
    
    // adding refresh control task
    if (self.refreshControl) {
        
        self.refreshControl.backgroundColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(updateContactsAndEndRefreshing)
                      forControlEvents:UIControlEventValueChanged];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self qm_smoothlyDeselectRowsForTableView:self.tableView];
    
    if (self.refreshControl.isRefreshing) {
        // fix for freezing refresh control after tab bar switch
        // if it is still active
        CGPoint offset = self.tableView.contentOffset;
        [self.refreshControl endRefreshing];
        [self.refreshControl beginRefreshing];
        self.tableView.contentOffset = offset;
    }
}

- (void) updateFriendList {
    originalContacts = [DataManager sharedManager].clientContactsArray;
    contactsArray = originalContacts;
    [self.tableView reloadData];
}

- (void) configureSearch
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
    
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = self.searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    }
    else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
#else
    self.tableView.tableHeaderView = self.searchController.searchBar;
#endif
    
    self.definesPresentationContext = YES;
}

#pragma mark - UITableView Datasource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return contactsArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ChatFirmModel* chatFirmModel = contactsArray[section];
    return chatFirmModel.users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return contactsArray.count > 0 ? [ChatContactCell height] : CGRectGetHeight(tableView.bounds) - tableView.contentInset.top - tableView.contentInset.bottom;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ChatFirmModel* chatFirmModel = contactsArray[section];
    
    return chatFirmModel.firmName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

#pragma MARK - UITableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (contactsArray.count == 0) {
        QMNoContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoContactsCell cellIdentifier] forIndexPath:indexPath];
        [cell setTitle:NSLocalizedString(@"QM_STR_NO_CONTACTS", nil)];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    ChatContactCell *cell = (ChatContactCell *)[self.tableView dequeueReusableCellWithIdentifier:[ChatContactCell cellIdentifier]
                                                                                  forIndexPath:indexPath];
    cell.leftUtilityButtons = [self leftButtons];
//    cell.rightUtilityButtons = [self rightButtons];
    cell.chatDelegate = self;
    cell.delegate = self;
    
    ChatFirmModel* firmModel = contactsArray[indexPath.section];
    QBUUser *user = firmModel.users[indexPath.row];
    [cell configureCellWithContact:user];
    
    return cell;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    UIFont *font = [UIFont fontWithName:@"SFUIText-Medium" size:17.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    NSAttributedString* callString = [[NSAttributedString alloc] initWithString:@"Call" attributes:attributes];

    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] attributedTitle:callString];
    
    return leftUtilityButtons;
}

#pragma mark - SWTableViewDelegate

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    QBUUser* user = contactsArray[cell.tag];
    switch (index) {
        case 0:
            if (![self callsAllowed:user]) {
                return;
            }
            
            [[QMCore instance].callManager callToUserWithID:user.ID conferenceType:QBRTCConferenceTypeAudio];            break;
            
        default:
            break;
    }
}

- (BOOL)callsAllowed:(QBUUser*) selectedUser {
    
    if (![self connectionExists]) {
        return NO;
    }
    
    if (![[QMCore instance].contactManager isFriendWithUserID:selectedUser.ID]) {
        
        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO inViewController:self];
        return NO;
    }
    
    return YES;
}

- (BOOL)connectionExists {
    
    if (![QMCore.instance isInternetConnected]) {
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning
                                                                              message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil)
                                                                             duration:kQMDefaultNotificationDismissTime];
        return NO;
    }
    
    if (![QBChat instance].isConnected) {
        
        if (QBChat.instance.isConnecting) {
            
            [(QMNavigationController *)self.navigationController shake];
        }
        else {
            
            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil)
                            actionSuccess:NO
                         inViewController:self];
        }
        
        return NO;
    }
    
    return YES;
}

- (void) addContactToFavoriteList:(QBUUser*) user {
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    [[QMNetworkManager sharedManager] addFavoriteContact:user withCompletion:^(NSError * _Nonnull error) {
        
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            [[DataManager sharedManager].favoriteContactsArray addObject:user];
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_FAVORITE_CONTACT object:user];
        } else {
            [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:self];
        }
    }];
}

- (void) removeContactFromFavoriteList:(QBUUser*) user {
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    [[QMNetworkManager sharedManager] removeFavoriteContact:user withCompletion:^(NSError * _Nonnull error) {
        
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            [[DataManager sharedManager].favoriteContactsArray removeObject:user];
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_FAVORITE_CONTACT object:user];
        } else {
            [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:self];
        }
    }];
}

#pragma mark - ContactCellDelegate
- (void) didFavTapped:(ChatContactCell *)cell user:(QBUUser *)user tapType:(NSString *)type
{
    if ([type isEqualToString:@"Add"]) {
        [self addContactToFavoriteList:user];
    } else {
        [self removeContactFromFavoriteList:user];
    }
}

#pragma mark - Search Delegate
- (void)willPresentSearchController:(UISearchController *)searchController
{
    MessageViewController* messageVC = (MessageViewController*)self.parentViewController;
    
    messageVC.navigationController.navigationBarHidden = YES;
}

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    MessageViewController* messageVC = (MessageViewController*)self.parentViewController;
    messageVC.navigationController.navigationBarHidden = NO;
    
    self.filter = @"";
    searchController.searchBar.text = @"";
    [self updateFriendList];
    [self.tableView reloadData];
}

#pragma mark - searchbar delegate
- (void) filterContactList
{
    NSMutableArray* newArray = [NSMutableArray new];
    if (self.filter.length == 0) {
        [self updateFriendList];
    } else {
        for (ChatFirmModel* firmModel in originalContacts) {
            ChatFirmModel* newModel = [ChatFirmModel new];
            newModel.firmName = firmModel.firmName;
            newModel.firmCode = firmModel.firmCode;
            if ([firmModel.firmName localizedCaseInsensitiveContainsString:self.filter]) {
                newModel.users = firmModel.users;
            } else {
                NSMutableArray* userArray = [NSMutableArray new];
                for(QBUUser* user in firmModel.users) {
                    if ([user.fullName localizedCaseInsensitiveContainsString:self.filter]) {
                        [userArray addObject:user];
                    }
                }
                newModel.users = [userArray copy];
            }
            [newArray addObject:newModel];
        }
        contactsArray = [newArray copy];
    }
    
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    self.filter = searchText;
    if (self.filter.length == 0) {
        [self updateFriendList];
    } else {
        [self filterContactList];
    }
}

#pragma mark - Update items

- (void)updateItemsFromContactListWithCompletion:(void(^)(void)) completion {
    [[QMNetworkManager sharedManager] getChatContactsWithCompletion:completion];
}

#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChatFirmModel* firmModel = contactsArray[indexPath.section];
    selectedFirmCode = firmModel.firmCode;
    QBUUser *user = firmModel.users[indexPath.row];
    QBChatDialog *privateChatDialog = [[QMCore instance].chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
    
    if (privateChatDialog) {
        
        [self performSegueWithIdentifier:kQMSceneSegueChat sender:privateChatDialog];
    }
    else {
        
        if (self.task) {
            // task in progress
            return;
        }
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        
        __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
        
        @weakify(self);
        self.task = [[[QMCore instance].chatService createPrivateChatDialogWithOpponentID:user.ID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
            
            @strongify(self);
            [navigationController dismissNotificationPanel];
            if (!task.isFaulted) {
                
                [self performSegueWithIdentifier:kQMSceneSegueChat sender:task.result];
            }
            
            return nil;
        }];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

- (void)updateContactsAndEndRefreshing {
    
    @weakify(self);
    [[QMTasks taskUpdateContacts] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        
        [self.refreshControl endRefreshing];
        
        return nil;
    }];
}

#pragma mark - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUserInfo]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        QMUserInfoViewController *userInfoVC = navigationController.viewControllers.firstObject;
        userInfoVC.user = sender;
    }
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        UINavigationController *navigationController = segue.destinationViewController;
        QMChatVC *chatViewController = [navigationController viewControllers].firstObject;
        chatViewController.chatDialog = sender;
//        chatViewController.firmCode = selectedFirmCode;
    }
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    [self updateItemsFromContactListWithCompletion:^{
        [self updateFriendList];
    }];
    
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    [self updateItemsFromContactListWithCompletion:^{
        [self updateFriendList];
    }];
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused users {
    
    [self updateItemsFromContactListWithCompletion:^{
        [self updateFriendList];
    }];
}

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)__unused users {
    
    [self updateItemsFromContactListWithCompletion:^{
        [self updateFriendList];
    }];
}

#pragma mark - QMSearchProtocol

- (QMSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}

#pragma mark - Nib registration

- (void)registerNibs {
    
    [ChatContactCell registerForReuseInTableView:self.tableView];
    
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
    
    [QMSearchCell registerForReuseInTableView:self.tableView];
    
    [QMNoContactsCell registerForReuseInTableView:self.tableView];
}

#ifdef __IPHONE_11_0
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull __unused context) {
        if (@available(iOS 11.0, *)) {
            self.searchController.active = NO;
        }
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
#endif

@end
