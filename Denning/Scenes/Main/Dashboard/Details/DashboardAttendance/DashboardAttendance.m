//
//  DashboardAttendance.m
//  Denning
//
//  Created by Ho Thong Mee on 17/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DashboardAttendance.h"
#import "TwoColumnSecondCell.h"
#import "AttendanceHeaderCell.h"
#import "DashboardAttendanceDetail.h"

@interface DashboardAttendance ()<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate,UITableViewDelegate, UITableViewDataSource>{
    __block BOOL isFirstLoading;
    __block BOOL isLoading;
    BOOL initCall;
    BOOL isAppending;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnAll;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnOnDuty;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnOffDuty;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray<ItemModel*> *headerModel;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;

@property (strong, nonatomic) NSArray<StaffOnlineModel*>* listOfAttendance;
@end

@implementation DashboardAttendance


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNibs];
    //    [self configureSearch];
    [self getHeaderInfo];
    [SVProgressHUD showWithStatus:@"Loading"];
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
    _url = [_url stringByAppendingString:@"?"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

- (void)registerNibs {
    [TwoColumnSecondCell registerForReuseInTableView:self.tableView];
}

- (void) resetState: (MIBadgeButton*) button {
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBadgeBackgroundColor:[UIColor darkGrayColor]];
}

- (void) setStatus:(MIBadgeButton*) button {
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [button setBadgeBackgroundColor:[UIColor redColor]];
}

- (void) resetAllButtons {
    [self resetState:_btnAll];
    [self resetState:_btnOffDuty];
    [self resetState:_btnOnDuty];
}

- (IBAction)didTapAll:(id)sender {
    [self resetAllButtons];
    [self setStatus:_btnAll];
    _url = [_headerModel[0].api  stringByAppendingString:@"?"];
    _page = @(1);
    isAppending = NO;
    [SVProgressHUD showWithStatus:@"Loading"];
    [self getList];
}

- (IBAction)didTapOnDuty:(id)sender {
    [self resetAllButtons];
    [self setStatus:_btnOnDuty];
    _url = _headerModel[1].api;
    _page = @(1);
    isAppending = NO;
    [SVProgressHUD showWithStatus:@"Loading"];
    [self getList];
}

- (IBAction)didTapOffDuty:(id)sender {
    [self resetAllButtons];
    [self setStatus:_btnOffDuty];
    _url = _headerModel[2].api;
    _page = @(1);
    isAppending = NO;
    [SVProgressHUD showWithStatus:@"Loading"];
    [self getList];
}

- (void) updateHeaderInfo:(ThreeItemModel*) info {
    [DIHelpers configureButton:_btnAll withBadge:info.items[0].value withColor:[UIColor grayColor]];
    [_btnAll setBadgeBackgroundColor:[UIColor redColor]];
    [DIHelpers configureButton:_btnOnDuty withBadge:info.items[1].value withColor:[UIColor grayColor]];
    [DIHelpers configureButton:_btnOffDuty withBadge:info.items[2].value withColor:[UIColor grayColor]];
}

- (void) getHeaderInfo {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] getDashboardThreeItmesInURL:DASHBOARD_S11_GET_URL withCompletion:^(ThreeItemModel * _Nonnull result, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        @strongify(self)
        if (error == nil) {
            _headerModel = result.items;
            [self updateHeaderInfo:result];
            [self.tableView reloadData];
        } else {
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
        [SVProgressHUD dismiss];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error == nil) {
            
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                _listOfAttendance = [[_listOfAttendance arrayByAddingObjectsFromArray:result] mutableCopy];
                
            } else {
                _listOfAttendance = result;
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
    
    return _listOfAttendance.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AttendanceHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[AttendanceHeaderCell cellIdentifier]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StaffOnlineModel *model = _listOfAttendance[indexPath.row];
    
    TwoColumnSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:[TwoColumnSecondCell cellIdentifier] forIndexPath:indexPath];
    
    cell.leftLabel.text = model.name;
    cell.rightLabel.text = model.status;
    if ([model.status isEqualToString:@"ON-DUTY"]) {
        cell.rightLabel.textColor = [UIColor babyGreen];
    } else {
        cell.rightLabel.textColor = [UIColor redColor];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kAttendanceDetailSegue sender:_listOfAttendance[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    //    CGFloat contentHeight = scrollView.contentSize.height;
    if (offsetY > 10) {
        
        [self.searchBar endEditing:YES];
        _searchBar.showsCancelButton = NO;
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


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    [self searchBarSearchButtonClicked:searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.filter = searchBar.text;
    isAppending = NO;
    self.page = @(1);
    [self getList];
    [_searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    self.filter = searchText;
    isAppending = NO;
    self.page = @(1);
    [self getList];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == self.listOfAttendance.count-1 && initCall) {
        isFirstLoading = NO;
        initCall = NO;
    }
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:kAttendanceDetailSegue]) {
         DashboardAttendanceDetail* vc = segue.destinationViewController;
         vc.model = sender;
     }
 }

@end
