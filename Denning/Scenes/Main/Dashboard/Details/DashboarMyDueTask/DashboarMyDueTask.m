//
//  DashboarMyDueTask.m
//  Denning
//
//  Created by Ho Thong Mee on 28/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DashboarMyDueTask.h"
#import "myDueTaskCell.h"
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>

@interface DashboarMyDueTask ()
<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource,  HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>
{
    __block BOOL isLoading;
    BOOL isAppending;
    NSInteger selectedIndex;
    NSString* baseUrl;
}

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listOfTasks;
@property (strong, nonatomic) UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;

@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;
@property (strong, nonatomic) NSArray* topFilter;
@property (strong, nonatomic) NSArray* arrayOfFilterValues;
@end

@implementation DashboarMyDueTask

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self parseUrl];
    [self prepareUI];
    [self registerNibs];
//    [self configureSearch];
    [SVProgressHUD showWithStatus:@"Loading"];
    [self getList];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    [self.searchContainer addSubview:self.searchController.searchBar];
}

- (void)registerNibs {
    [myDueTaskCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

- (void) parseUrl {
    NSRange range =  [_url rangeOfString:@"?" options:NSBackwardsSearch];
    if (range.location > _url.length) {
        baseUrl = _url;
        return;
    }
    baseUrl = [_url substringToIndex:range.location];
}

- (void) prepareUI
{
    self.page = @(1);
    self.filter = @"";
    isAppending = NO;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
    
    self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, 44)];
    self.selectionList.delegate = self;
    self.selectionList.dataSource = self;
    
    self.selectionList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.selectionList.showsEdgeFadeEffect = YES;
    
    _topFilter = @[@"Today", @"Next 7 Days",  @"After 7 Days"];
    _arrayOfFilterValues = @[@"Today", @"next7", @"afterNext7"];
    self.selectionList.selectionIndicatorColor = [UIColor colorWithHexString:@"FF3B2F"];
    [self.selectionList setTitleColor:[UIColor colorWithHexString:@"FF3B2F"] forState:UIControlStateHighlighted];
    [self.selectionList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-Regular" size:17] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-SemiBold" size:17]  forState:UIControlStateSelected];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-SemiBold" size:17] forState:UIControlStateHighlighted];
    
    [self.view addSubview:self.selectionList];
    self.selectionList.backgroundColor = [UIColor blackColor];
    self.selectionList.selectedButtonIndex = 0;
    self.selectionList.hidden = NO;
    
    CustomInfiniteIndicator *indicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    
    // Set custom indicator
    self.tableView.infiniteScrollIndicatorView = indicator;
    // Set custom indicator margin
    self.tableView.infiniteScrollIndicatorMargin = 40;
    
    // Set custom trigger offset
    self.tableView.infiniteScrollTriggerOffset = 500;
    
    // Add infinite scroll handler
    @weakify(self)
    [self.tableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        @strongify(self)
        [self appendList];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    
    return self.topFilter.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    
    return self.topFilter[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    // update the view for the corresponding index
    selectedIndex = index;
    isAppending = NO;
  //  self.filter = @"";
    self.page = @(1);
    [SVProgressHUD showWithStatus:@"Loading"];
    [self getList];
}

- (void) appendList {
    isAppending = YES;
    [self getList];
}

- (NSString*) buildURL:(NSInteger) index {
    return [NSString stringWithFormat:@"%@?filterBy=%@", baseUrl, _arrayOfFilterValues[index]];
}

- (void) getList{
    
    if (isLoading) return;
    isLoading = YES;
    
    NSString* newUrl = [self buildURL:selectedIndex];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    self->isLoading = NO;
    [self.tableView finishInfiniteScroll];
    [[QMNetworkManager sharedManager] getDashboardMyDueTaskWithURL:newUrl withPage:_page withFilter:_filter withCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        [SVProgressHUD dismiss];
        if (error == nil) {
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                self.listOfTasks = [[self.listOfTasks arrayByAddingObjectsFromArray:result] mutableCopy];
                
            } else {
                self.listOfTasks = [result mutableCopy];
            }
            
            [self.tableView reloadData];
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
    }];
}

- (void) clean {
    isLoading = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listOfTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCheckModel *model = self.listOfTasks[indexPath.row];
    
    myDueTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:[myDueTaskCell cellIdentifier] forIndexPath:indexPath];
    
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

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    self.filter = @"";
    self.page = @(1);
    searchController.searchBar.text = @"";
    isAppending = NO;
    [self getList];
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
