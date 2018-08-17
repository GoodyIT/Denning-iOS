//
//  CompletionDateTracking.m
//  Denning
//
//  Created by Ho Thong Mee on 17/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CompletionDateTracking.h"
#import "CompletionTrackingCell.h"

@interface CompletionDateTracking ()<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate,UITableViewDelegate, UITableViewDataSource>{
    __block BOOL isLoading;
    BOOL isAppending;
    NSArray* btnArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

//@property (strong, nonatomic)  UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnFirst;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnSecond;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnThird;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnForth;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnCritical;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnTerminal;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnUncertain;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnCompleted;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (strong, nonatomic) NSArray<ThirdItemModel*> *headerModel;
@property (strong, nonatomic) NSArray<CompletionTrackingModel*> *listOfCompletion;

@end

@implementation CompletionDateTracking

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNibs];
    [self getHeaderInfo];
    [self resetAllButtons];
    [self setStatus:btnArray[[_selHeaderId integerValue]-1]];
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

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController removeFromParentViewController];
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
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
    for (int i = 0; i < btnArray.count; i++) {
        [self resetState:btnArray[i]];
    }
}

- (void) updateFromHeaderInfo:(NSInteger) index
{
    [SVProgressHUD showWithStatus:@"Loading"];
    [self resetAllButtons];
    [self setStatus:btnArray[index]];
    _url = _headerModel[index].api;
    _page = @(1);
    isAppending = NO;
    [self getList];
}

- (IBAction)didTapFirstBtn:(id)sender {
    [self updateFromHeaderInfo:0];
}

- (IBAction)didTapSecondBtn:(id)sender {
    [self updateFromHeaderInfo:1];
}

- (IBAction)didTapThirdBtn:(id)sender {
    [self updateFromHeaderInfo:2];
}

- (IBAction)didTapForthBtn:(id)sender {
    [self updateFromHeaderInfo:3];
}

- (IBAction)didTapCriticalBtn:(id)sender {
    [self updateFromHeaderInfo:4];
}

- (IBAction)didTapTerminalBtn:(id)sender {
    [self updateFromHeaderInfo:5];
}

- (IBAction)didTapUncertainBtn:(id)sender {
    [self updateFromHeaderInfo:6];
}

- (IBAction)didTapCompletedBtn:(id)sender {
    [self updateFromHeaderInfo:7];
}

- (void) prepareUI
{
    btnArray = @[_btnFirst, _btnSecond, _btnThird, _btnForth, _btnCritical, _btnTerminal, _btnUncertain, _btnCompleted];
    _page = @(1);
    _filter = @"";
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
    
//    CustomInfiniteIndicator *indicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
//
//    // Set custom indicator
//    self.tableView.infiniteScrollIndicatorView = indicator;
//    // Set custom indicator margin
//    self.tableView.infiniteScrollIndicatorMargin = 40;
//
//    // Set custom trigger offset
//    self.tableView.infiniteScrollTriggerOffset = 500;
    
    // Add infinite scroll handler
    @weakify(self)
    [self.tableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        @strongify(self)
        [self appendList];
    }];
}

- (void)registerNibs {
    [CompletionTrackingCell registerForReuseInTableView:self.tableView];
}

- (void) updateHeaderInfo{
    if (_headerModel.count == 0) {
        return;
    }
    for (int i = 0; i < btnArray.count; i++) {
        [btnArray[i] setTitle:_headerModel[i].label forState:UIControlStateNormal];
        [DIHelpers configureButton:btnArray[i] withBadge:_headerModel[i].value withColor:[UIColor grayColor]];
    }
    [btnArray[[_selHeaderId integerValue]-1] setBadgeBackgroundColor:[UIColor redColor]];
}

- (void) getHeaderInfo {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] getDashboardCompletionHeaderInURL:DASHBOARD_COMPLETION_TRACKING_HEADER_GET_URL withCompletion:^(S3Model * _Nonnull result, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        @strongify(self)
        if (error == nil) {
            _headerModel = result.items;
            [self updateHeaderInfo];
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
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] getCompletionTrackingWithURL:_url withPage:_page withFilter:_filter withCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        [self.tableView finishInfiniteScroll];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD dismiss];
        if (error == nil) {
            
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                _listOfCompletion = [[_listOfCompletion arrayByAddingObjectsFromArray:result] mutableCopy];
            } else {
                if (_listOfCompletion.count > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                     });
                }
                _listOfCompletion = result;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
        [self performSelector:@selector(clean) withObject:nil afterDelay:0.5];
    }];
}

- (void) clean {
    isLoading = NO;
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
    
    return _listOfCompletion.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CompletionTrackingModel *model = _listOfCompletion[indexPath.row];
    
    CompletionTrackingCell *cell = [tableView dequeueReusableCellWithIdentifier:[CompletionTrackingCell cellIdentifier] forIndexPath:indexPath];
    
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
        _searchBar.showsCancelButton = NO;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
