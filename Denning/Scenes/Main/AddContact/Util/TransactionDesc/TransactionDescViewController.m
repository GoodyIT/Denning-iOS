//
//  TransactionDescViewController.m
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TransactionDescViewController.h"

@interface TransactionDescViewController ()<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>{
    __block BOOL isLoading;
    BOOL isAppending;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;

@end

@implementation TransactionDescViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self getList];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareUI
{
    self.page = @(1);
    self.filter = @"";
    
    self.tableView.delegate = self;
    
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
    _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, _url, _filter, _page];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        @strongify(self)
        [self.tableView finishInfiniteScroll];
        if (error == nil) {
            NSArray* array = [CodeTransactionDesc getCodeTransactionDescArray:(NSArray*)result];
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                self.listOfCodeDesc = [[self.listOfCodeDesc arrayByAddingObjectsFromArray:array] mutableCopy];
                
            } else {
                self.listOfCodeDesc = [array mutableCopy];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        self->isLoading = NO;
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listOfCodeDesc.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CodeDescCell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = ((CodeTransactionDesc*)self.listOfCodeDesc[indexPath.row]).strTransactionDescription;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        _updateHandler(_listOfCodeDesc[indexPath.row]);
    }];
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

#pragma mark - Search Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
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

@end
