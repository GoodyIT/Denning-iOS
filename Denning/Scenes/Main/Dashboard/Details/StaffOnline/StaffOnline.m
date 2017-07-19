//
//  StaffOnline.m
//  Denning
//
//  Created by Ho Thong Mee on 17/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "StaffOnline.h"
#import "StaffOnlineCell.h"
#import "StaffOnlineHeaderCell.h"

@interface StaffOnline ()<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate,UITableViewDelegate, UITableViewDataSource>{
    __block BOOL isFirstLoading;
    __block BOOL isLoading;
    BOOL initCall;
    BOOL isAppending;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

//@property (strong, nonatomic)  UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;
@property (strong, nonatomic)  NSArray<StaffOnlineModel*>* onlineModel;
@property (strong, nonatomic) NSArray<ItemModel*> *headerModel;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnAll;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnOnline;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnOffline;

@end

@implementation StaffOnline

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNibs];
//    [self configureSearch];
    [self getHeaderInfo];
    [self getList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareUI
{
    _page = @(1);
    _filter = @"";
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

- (void)registerNibs {
    [StaffOnlineHeaderCell registerForReuseInTableView:self.tableView];
    [StaffOnlineCell registerForReuseInTableView:self.tableView];
}
//
//- (void) configureSearch
//{
//    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
//    self.searchController.searchBar.placeholder = NSLocalizedString(@"Search", nil);
//    self.searchController.searchBar.delegate = self;
//    self.searchController.delegate = self;
//    self.searchController.dimsBackgroundDuringPresentation = NO;
//    self.searchController.hidesNavigationBarDuringPresentation = NO;
//    self.definesPresentationContext = YES;
//    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
//    self.tableView.tableHeaderView = self.searchController.searchBar;
//}

- (IBAction)didTapAll:(id)sender {
    _url = _headerModel[0].api;
    _page = @(1);
    [self getList];
}

- (IBAction)didTapOnline:(id)sender {
    _url = _headerModel[1].api;
    _page = @(1);
    [self getList];
}

- (IBAction)didTapOffline:(id)sender {
    _url = _headerModel[2].api;
    _page = @(1);
    [self getList];
}

- (void) updateHeaderInfo:(ThreeItemModel*) info {
    [DIHelpers configureButton:_btnAll withBadge:info.items[0].value withColor:[UIColor grayColor]];
    [DIHelpers configureButton:_btnOnline withBadge:info.items[1].value withColor:[UIColor babyGreen]];
    [DIHelpers configureButton:_btnOffline withBadge:info.items[2].value withColor:[UIColor redColor]];
}

- (void) getHeaderInfo {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] getDashboardThreeItmesInURL:DASHBOARD_S10_GET_URL withCompletion:^(ThreeItemModel * _Nonnull result, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        @strongify(self)
        if (error == nil) {
            _headerModel = result.items;
            [self updateHeaderInfo:result];
            [self.tableView reloadData];
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
    }];
}

- (void) getList{
    if (isLoading) return;
    isLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] getStaffOnlineWithURL:_url withPage:_page withFilter:_filter withCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error == nil) {
            
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                _onlineModel = [[_onlineModel arrayByAddingObjectsFromArray:result] mutableCopy];
                
            } else {
                _onlineModel = result;
            }

            [self.tableView reloadData];
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
        [self performSelector:@selector(clean) withObject:nil afterDelay:0.5];
    }];
}

- (void) clean {
    isLoading = NO;
    isFirstLoading = NO;
}

- (void) appendList {
    isAppending = YES;
    [self getList];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _onlineModel.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    StaffOnlineHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[StaffOnlineHeaderCell cellIdentifier]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StaffOnlineModel *model = _onlineModel[indexPath.row];
    
    StaffOnlineCell *cell = [tableView dequeueReusableCellWithIdentifier:[StaffOnlineCell cellIdentifier] forIndexPath:indexPath];
    
    [cell configureCellWithModel:model];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    //    CGFloat contentHeight = scrollView.contentSize.height;
    if (offsetY > 10) {
        
        [self.searchBar endEditing:YES];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    
    if (offsetY > contentHeight - scrollView.frame.size.height && !isFirstLoading) {
        
        [self appendList];
    }
}

#pragma mark - Search Delegate


- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    self.filter = @"";
    self.page = @(1);
    searchController.searchBar.text = @"";
    isAppending = NO;
    [self getList];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    self.filter = searchText;
    isAppending = NO;
    self.page = @(1);
    [self getList];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == self.onlineModel.count-1 && initCall) {
        isFirstLoading = NO;
        initCall = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
