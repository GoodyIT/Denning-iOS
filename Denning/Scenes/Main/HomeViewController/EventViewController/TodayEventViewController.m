//
//  TodayEventViewController.m
//  Denning
//
//  Created by Denning IT on 2017-11-22.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TodayEventViewController.h"
#import "EventCell.h"

@interface TodayEventViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate>
{
    __block BOOL isLoading, isAppending;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* eventsArray;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (copy, nonatomic) NSString *search;
@property (strong, nonatomic) NSNumber* page;
@end

@implementation TodayEventViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentSizeInPopup = CGSizeMake(300, 350);
    self.landscapeContentSizeInPopup = CGSizeMake(350, 300);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNibs];
    [self loadEventFromFilters];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareUI
{
    self.title = [DIHelpers getDateInShortFormWithoutTime:_startDate];
    self.page = @(1);
    _search = @"";
    self.eventsArray = [NSMutableArray new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
    
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
        [self appendEvent];
    }];
}

- (void)registerNibs {
    [EventCell registerForReuseInTableView:self.tableView];
}

- (void) loadEventFromFilters {
    NSString* currentBottomFilter = @"0All";
    if (isLoading) return;
    isLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    @weakify(self);
    [[QMNetworkManager sharedManager] getLatestEventWithStartDate:_startDate endDate:_endDate filter:currentBottomFilter search:_search page:_page withCompletion:^(NSArray * _Nonnull eventsArray, NSError * _Nonnull error) {
        @strongify(self);
        self->isLoading = NO;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.tableView finishInfiniteScroll];
        if (error == nil) {
            if (isAppending) {
                self.eventsArray = [[self.eventsArray arrayByAddingObjectsFromArray:eventsArray] mutableCopy];
            } else {
                self.eventsArray = eventsArray;
            }
            
            if (eventsArray.count > 0) {
                _page = [NSNumber numberWithInteger:([_page integerValue] + 1)];
            }
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
        self->isAppending = NO;
    }];
}

- (void) appendEvent {
    isAppending = YES;
    [self loadEventFromFilters];
}

- (void) updateEvents {
    _page = @(1);
    [self loadEventFromFilters];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    //    CGFloat contentHeight = scrollView.contentSize.height;
    if (offsetY > 10) {
        
        [self.searchBar endEditing:YES];
        _searchBar.showsCancelButton = NO;
    }
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
    searchBar.text = @"";
    [self searchBarSearchButtonClicked:searchBar];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    _search = searchText;
    [self updateEvents];
}

#pragma mark - UISearchControllerDelegate

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    _searchBar.text = @"";
    _search = @"";
    [self updateEvents];
}

#pragma mark - searchbar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.search = searchBar.text;
    
    [self updateEvents];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    
    return [self.eventsArray count];
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:[EventCell cellIdentifier] forIndexPath:indexPath];
    
    cell.tag = indexPath.section;
    [cell configureCellWithEvent:self.eventsArray[indexPath.section]];
    
    return cell;
}

@end
