//
//  QMContactsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "FavContactViewController.h"
//#import "QMContactsDataSource.h"
//#import "QMContactsSearchDataSource.h"
//#import "QMGlobalSearchDataSource.h"
//#import "QMContactsSearchDataProvider.h"
#import "MessageViewController.h"

#import "QMUserInfoViewController.h"

#import "QMCore.h"
#import "QMTasks.h"

#import "QMContactCell.h"
#import "QMNoContactsCell.h"
#import "QMNoResultsCell.h"
#import "FavContactCell.h"
@interface FavContactViewController ()
<
UISearchControllerDelegate,
UISearchBarDelegate,

QMContactListServiceDelegate,
QMUsersServiceDelegate,

SWTableViewCellDelegate
>
{
    NSMutableArray* originalContacts;
    NSMutableArray<ChatFirmModel*>* contactsArray;
    NSString* selectedFirmCode;
    NSInteger selectedIndex;
}

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) IBOutlet UISegmentedControl *userTypeSegment;

/**
 *  Data sources
 */
//@property (strong, nonatomic) QMContactsDataSource *dataSource;

@property (strong, nonatomic) NSString* filter;

@property (weak, nonatomic) BFTask *addUserTask;

@property (weak, nonatomic) BFTask *task;

@end

@implementation FavContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedIndex = 0;
    
    // search implementation
    [self configureSearch];
    
    // filling data source
    [self updateFriendList];
    
    [self registerNibs];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactsAndEndRefreshing) name:CHANGE_FAVORITE_CONTACT object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeFromParentViewController];
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
    
    [self updateContactsAndEndRefreshing];
}

- (void) updateDataSourceByScope:(NSInteger) index {
    selectedIndex = index;
    switch (index) {
        case 0:
            originalContacts = [[[DataManager sharedManager].favStaffContactsArray arrayByAddingObjectsFromArray:[DataManager sharedManager].favClientContactsArray] mutableCopy];
            break;
        case 1:
            originalContacts = [[DataManager sharedManager].favStaffContactsArray copy];
            break;
        case 2:
            originalContacts = [[DataManager sharedManager].favClientContactsArray copy];
            break;

        default:
            // Denning support
            originalContacts = [NSMutableArray new];
            break;
    }
    contactsArray = originalContacts;
//    [self.tableView reloadData];
}

- (void) updateFriendList {
    [self updateDataSourceByScope:selectedIndex];
    [self filterContactList];
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
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _searchController.searchBar.frame.size.height + 35)];
    [containerView addSubview:_searchController.searchBar];
    [containerView addSubview:_userTypeSegment];
    
     self.tableView.tableHeaderView =  containerView;
    
    [_userTypeSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_searchController.searchBar.mas_bottom).offset(-5); //with is an optional semantic filler
        make.centerX.equalTo(containerView.mas_centerX);
        make.bottom.equalTo(containerView.mas_bottom).offset(-8);
    }];
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
    
    return contactsArray.count > 0 ? [FavContactCell height] : CGRectGetHeight(tableView.bounds) - tableView.contentInset.top - tableView.contentInset.bottom;
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

#pragma MARK - UITableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (contactsArray.count == 0) {
        QMNoContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoContactsCell cellIdentifier] forIndexPath:indexPath];
        [cell setTitle:NSLocalizedString(@"QM_STR_NO_CONTACTS", nil)];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    FavContactCell *cell = (FavContactCell *)[self.tableView dequeueReusableCellWithIdentifier:[FavContactCell cellIdentifier]
                                                                                  forIndexPath:indexPath];
    cell.leftUtilityButtons = [self leftButtons];
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    cell.tag = indexPath.section * 1000 + indexPath.row;
    ChatFirmModel* firmModel = contactsArray[indexPath.section];
    QBUUser *user = firmModel.users[indexPath.row];
    [cell configureCellWithContact:user];
    
    return cell;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    UIFont *font = [UIFont fontWithName:@"SFUIText-Medium" size:17.0f];
    NSAttributedString* callString = [[NSAttributedString alloc] initWithString:@"Call" attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName:[UIColor whiteColor]}];

    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] attributedTitle:callString];
    
    return leftUtilityButtons;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    UIFont *font = [UIFont fontWithName:@"SFUIText-Medium" size:17.0f];
    NSAttributedString* delteString = [[NSAttributedString alloc] initWithString:@"Delete" attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                      attributedTitle:delteString];
    
    return rightUtilityButtons;
}

#pragma mark - SWTableViewDelegate

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    NSInteger section = cell.tag / 1000;
    NSInteger row = cell.tag  - section * 1000;
    QBUUser* user = contactsArray[section].users[row];
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


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    NSInteger section = cell.tag / 1000;
    NSInteger row = cell.tag  - section * 1000;
    QBUUser* user = contactsArray[section].users[row];
    switch (index) {
        case 0:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            [self removeUserFromList:user cellIndexPath:cellIndexPath];
            
            break;
        }
        default:
            break;
    }
}

- (void) removeUserFromList:(QBUUser*) user cellIndexPath:(NSIndexPath*) cellIndexPath
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message: @"Are You Sure?"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [self.tableView setEditing:NO animated:YES];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          [SVProgressHUD show];
                                                          [[QMNetworkManager sharedManager] removeFavoriteContact:user withCompletion:^(NSError * _Nonnull error) {
                                                              [SVProgressHUD dismiss];
                                                              if (error == nil) {
                                                                  [QMAlert showAlertWithMessage:@"Successfully deleted" actionSuccess:YES inViewController:self];
                                                                  
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_FAVORITE_CONTACT object:nil];
                                                                 
                                                              } else {
                                                                      [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:self];
                                                                      [self.tableView setEditing:NO animated:YES];
                                                                  }
                                                          }];
                                                          
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
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

- (void) removeContactFromFavoriteList:(QBUUser*) user {
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    [[QMNetworkManager sharedManager] removeFavoriteContact:user withCompletion:^(NSError * _Nonnull error) {
        
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            [self updateContactsAndEndRefreshing];
        } else {
            [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:self];
        }
    }];
}


- (IBAction)didChangeUserType:(UISegmentedControl*)sender {
    [self updateDataSourceByScope:sender.selectedSegmentIndex];
    [self filterContactList];
}

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
}

#pragma mark - searchbar delegate
- (void) filterContactList
{
    NSMutableArray* newArray = [NSMutableArray new];
    if (self.filter.length == 0) {
        contactsArray = originalContacts;
    } else {
        for (ChatFirmModel* firmModel in originalContacts) {
            ChatFirmModel* newModel = [ChatFirmModel new];
            newModel.firmName = firmModel.firmName;
            newModel.firmCode = firmModel.firmCode;
            NSMutableArray* userArray = [NSMutableArray new];
            for(QBUUser* user in firmModel.users) {
                if ([user.fullName localizedCaseInsensitiveContainsString:self.filter]) {
                    [userArray addObject:user];
                }
            }
            newModel.users = [userArray copy];
            [newArray addObject:newModel];
        }
        contactsArray = [newArray copy];
    }
    
    [self.tableView reloadData];
}

- (void) didChangeSearchBar:(NSString*) searchText {
    self.filter = searchText;
    if (self.filter.length == 0) {
        [self updateFriendList];
    } else {
        [self filterContactList];
    }
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    [self didChangeSearchBar:searchText];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChatFirmModel* firmModel = contactsArray[indexPath.section];
    selectedFirmCode = firmModel.firmCode;
    QBUUser *user = firmModel.users[indexPath.row];
    BOOL isRequestSent = [[QMCore instance].contactManager isContactListItemExistentForUserWithID:user.ID];
 
    if (![[QMCore instance].contactManager isFriendWithUserID: user.ID] && !isRequestSent) {
        @weakify(self);
        [self addToContact:user withCompletion:^{
            @strongify(self);
            [self gotoChat:user];
        }];
    } else {
        [self gotoChat:user];
    }
}

- (IBAction)addToContact:(QBUUser*) user withCompletion:(void(^)(void)) completion {
    
    if (self.addUserTask) {
        // task in progress
        return;
    }
    
    if (![[QMCore instance].contactManager isFriendWithUserID:user.ID]) {
        BOOL isRequestSent = [[QMCore instance].contactManager isContactListItemExistentForUserWithID:user.ID];
        if (isRequestSent) {
            if (completion != nil) {
                completion();
            }
            return;
        } else {
            [SVProgressHUD showWithStatus:@"Sending"];
            
            self.addUserTask = [[[QMCore instance].contactManager addUserToContactList:user] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                
                [SVProgressHUD dismiss];
                if (self == nil) return nil;
                if (!task.isFaulted) {
                    if (completion != nil) {
                        completion();
                    }
                }
                else {
                    [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil)
                                    actionSuccess:NO
                                 inViewController:self];
                }
                
                return nil;
            }];
        }
    }
}

- (void) gotoChat: (QBUUser*) user {
    
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
        
        [self updateFriendList];
        
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
    
   [self updateFriendList];
    
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
   [self updateFriendList];
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused users {
    
    [self updateFriendList];
}

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)__unused users {
    
    [self updateFriendList];
}

#pragma mark - QMSearchProtocol

- (QMSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}

#pragma mark - Nib registration

- (void)registerNibs {
    
    [FavContactCell registerForReuseInTableView:self.tableView];
    
    [QMContactCell registerForReuseInTableView:self.tableView];
    
    [QMNoContactsCell registerForReuseInTableView:self.tableView];
}

@end
