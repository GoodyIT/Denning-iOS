//
//  ContactListViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 29/08/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ContactListViewController.h"
#import "StaffModel.h"
#import "ClientModel.h"
#import "SearchResultModel.h"
#import "GetJSONOperation.h"
#import "RequestObject.h"
#import "CustomInfiniteIndicator.h"
#import "UIScrollView+InfiniteScroll.h"
#import "PropertyContactCell.h"

@interface ContactListViewController ()<UISearchBarDelegate, UISearchControllerDelegate,UITableViewDelegate, UITableViewDataSource>
{
    NSURLSession* mySession;
    NSMutableData *receivedData;
    RequestObject* requestDataObject;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString* filter;
@property (strong, nonatomic) NSMutableArray* listOfContact;
@property (assign, nonatomic) BOOL isAppending;
@property (assign, nonatomic) NSInteger page;
@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerNib];
    [self prepareUI];
    [self getList];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [mySession invalidateAndCancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerNib {
    [PropertyContactCell registerForReuseInTableView:self.tableView];
//    [SecondContactCell registerForReuseInTableView:self.tableView];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) prepareUI {
    _filter = @"";
    _page = 1;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
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
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        [weakSelf appendList];
    }];
}

- (void) appendList {
    _isAppending = YES;
    [self getList];
}

- (void) getList{
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.denningshare.extension"];
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    requestDataObject = [RequestObject new];
    [requestDataObject setIncompleteString:@""];
    __weak typeof(self) weakSelf = self;
    [requestDataObject setCompletionBlock:^(NSArray *items) {
        if (items == nil) {
            return;
        }
        if (items > 0) {
            weakSelf.page++;
        }
        NSArray* array = [SearchResultModel getSearchResultArrayFromResponse:items];
        if (weakSelf.isAppending) {
            _listOfContact = [[_listOfContact arrayByAddingObjectsFromArray:array] mutableCopy];
        } else {
            _listOfContact = [array mutableCopy];
        }
        
        [weakSelf.tableView reloadData];
        weakSelf.isAppending = NO;
        [weakSelf.tableView finishInfiniteScroll];
    }];
    NSString* urlString = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%ld",[defaults valueForKey:@"api"], _url, _filter, _page];
    NSURL *downloadURL = [NSURL URLWithString:urlString];
    GetJSONOperation *operation = [[GetJSONOperation alloc] initWithCustomURL:downloadURL
                                                            withCompletionBlock:requestDataObject.completionBlock];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _listOfContact.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PropertyContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[PropertyContactCell cellIdentifier]];
    cell.name.text = @"ID";
    cell.ID.text = @"Name";
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultModel *model = self.listOfContact[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    UILabel* firstValue = (UILabel*)[cell viewWithTag:1];
    UILabel* secondValue = (UILabel*)[cell viewWithTag:2];
    firstValue.text = [model.JsonDesc valueForKey:@"IDNo"];
    secondValue.text = [model.JsonDesc valueForKey:@"name"];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.updateHandler(_listOfContact[indexPath.row]);
    [self.navigationController popViewControllerAnimated:YES];
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
    _page = 1;
    [self getList];
    [_searchBar resignFirstResponder];
}

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    self.filter = @"";
    searchController.searchBar.text = @"";
    _page = 1;
    [self getList];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    self.filter = searchText;
    _page = 1;
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
