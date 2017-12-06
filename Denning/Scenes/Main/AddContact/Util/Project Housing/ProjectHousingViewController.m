//
//  ProjectHousingViewController.m
//  Denning
//
//  Created by DenningIT on 17/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ProjectHousingViewController.h"
#import "TwoColumnCell.h"
#import "SecondMatterTypeCell.h"
#import "TwoColumnCell.h"

@interface ProjectHousingViewController ()
<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate>
{
    __block BOOL isLoading;
    BOOL isAppending;
}


@property (strong, nonatomic) NSMutableArray* listOfHousings;
@property (strong, nonatomic) NSArray* copyedList;

@property (strong, nonatomic) UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;

@end

@implementation ProjectHousingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self configureSearch];
    [self registerNib];
    [self getList];
    
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) registerNib {
    [TwoColumnCell registerForReuseInTableView:self.tableView];
    [SecondMatterTypeCell registerForReuseInTableView:self.tableView];
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
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void) prepareUI
{
    self.copyedList = [NSMutableArray new];
    self.page = @(0);
    self.filter = @"";
    
    self.tableView.delegate = self;
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.backgroundColor = [UIColor clearColor];
//    self.refreshControl.tintColor = [UIColor blackColor];
//    [self.refreshControl addTarget:self
//                            action:@selector(appendList)
//                  forControlEvents:UIControlEventValueChanged];
    
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
    self.tableView.infiniteScrollTriggerOffset = 100;
    
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

- (void) appendList {
    isAppending = YES;
    [self getList];
}

- (void) getList {
    if (isLoading) return;
    isLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] getPropertyProjectHousingWithPage:self.page  withSearch:(NSString*)self.filter WithCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        @strongify(self)
//        if (self.refreshControl.isRefreshing) {
//            self.refreshControl.attributedTitle = [DIHelpers getLastRefreshingTime];
//            [self.refreshControl endRefreshing];
//        }
        self->isLoading = NO;
        [self.tableView finishInfiniteScroll];
        if (error == nil) {
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            
            if (isAppending) {
                self.listOfHousings = [[self.listOfHousings arrayByAddingObjectsFromArray:result] mutableCopy];
            } else {
                self.listOfHousings = [result mutableCopy];
            }
            
            [self.tableView reloadData];
            
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listOfHousings.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TwoColumnCell *cell = [tableView dequeueReusableCellWithIdentifier:[TwoColumnCell cellIdentifier]];
    cell.codeLabel.text = @"ID";
    cell.descLabel.text = @"Name";
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProjectHousingModel *model = self.listOfHousings[indexPath.row];
    
    SecondMatterTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:[SecondMatterTypeCell cellIdentifier] forIndexPath:indexPath];
    cell.firstValue.text = model.housingCode;
    cell.secondValue.text = model.name;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectHousingModel *model = self.listOfHousings[indexPath.row];
    self.updateHandler(model);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    //    CGFloat contentHeight = scrollView.contentSize.height;
    if (offsetY > 10) {
        
        [self.searchController.searchBar endEditing:YES];
    }
}

#pragma mark - Search Delegate

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    self.filter = @"";
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


@end
