//
//  BranchListViewController.m
//  Denning
//
//  Created by DenningIT on 18/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "BranchListViewController.h"
#import "SecondContactCell.h"
#import "PropertyContactCell.h"

@interface BranchListViewController ()
<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate>
{
    __block BOOL isFirstLoading;
    __block BOOL isLoading;
    __block BOOL isAppending;
    BOOL initCall;
}

@property (strong, nonatomic) NSMutableArray* listOfBankBranches;
@property (strong, nonatomic) UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;

@end

@implementation BranchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNibs];
    [self configureSearch];
    [self getList];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)registerNibs {
    [SecondContactCell registerForReuseInTableView:self.tableView];
    [PropertyContactCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
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
    self.page = @(1);
    isFirstLoading = YES;
    self.filter = @"";
    initCall = YES;
    
    self.tableView.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(appendList)
                  forControlEvents:UIControlEventValueChanged];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
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
    [[QMNetworkManager sharedManager] getBankBranchWithPage:self.page withSearch:(NSString*)self.filter withCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        @strongify(self)
        if (self.refreshControl.isRefreshing) {
            self.refreshControl.attributedTitle = [DIHelpers getLastRefreshingTime];
            [self.refreshControl endRefreshing];
        }
        
        if (error == nil) {
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }

            if (isAppending) {
                self.listOfBankBranches = [[self.listOfBankBranches arrayByAddingObjectsFromArray:result] mutableCopy];
                            } else {
                self.listOfBankBranches = [result mutableCopy];
            }
            
            [self.tableView reloadData];
            
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
        self->isLoading = NO;
//        [self performSelector:@selector(clean) withObject:nil afterDelay:1.0];;
        
    }];
}

- (void) clean {
    isLoading = NO;
    isFirstLoading = NO;
}
#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PropertyContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[PropertyContactCell cellIdentifier]];
    cell.name.text = @"Branch Name";
    cell.ID.text = @"HQ";
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listOfBankBranches.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SecondContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[SecondContactCell cellIdentifier] forIndexPath:indexPath];
    
    BankBranchModel *model = self.listOfBankBranches[indexPath.row];
    
    cell.firstValue.text = model.name;
    cell.secondValue.text = model.HQ.name;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BankBranchModel *model = self.listOfBankBranches[indexPath.row];
    self.updateHandler(model);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    
    if (offsetY > contentHeight - scrollView.frame.size.height && !isFirstLoading && !isLoading) {
        
        [self appendList];
    }
}

#pragma mark - Search Delegate

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    self.filter = @"";
    searchController.searchBar.text = @"";
    isAppending = NO;
    self.page = @(1);
    [self getList];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    self.filter = searchText;
    isAppending = NO;
    self.page = @(1);
    [self getList];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == self.listOfBankBranches.count-1 && initCall) {
        isFirstLoading = NO;
        initCall = NO;
    }
}


@end
