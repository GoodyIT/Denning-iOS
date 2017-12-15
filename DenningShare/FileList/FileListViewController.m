//
//  FileListViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileListViewController.h"
#import "SearchResultModel.h"
#import "GetJSONOperation.h"
#import "RequestObject.h"
#import "CustomInfiniteIndicator.h"
#import "UIScrollView+InfiniteScroll.h"
#import "PropertyContactCell.h"
#import "ShareHelper.h"

@interface FileListViewController ()<UISearchBarDelegate, UISearchControllerDelegate,UITableViewDelegate, UITableViewDataSource>
{
    NSURLSession* mySession;
    NSMutableData *receivedData;
     RequestObject* requestDataObject;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString* filter;
@property (strong, nonatomic) NSMutableArray* listOfFile;
@property (assign, nonatomic) BOOL isAppending;
@property (assign, nonatomic) NSInteger page;
@end

@implementation FileListViewController

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
//    [PropertyContactCell registerForReuseInTableView:self.tableView];
    //    [SecondContactCell registerForReuseInTableView:self.tableView];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) prepareUI {
    _filter = @"";
    _page = 1;
    receivedData = [NSMutableData new];
    
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
    [requestDataObject setMyCompletionBlock:^(NSArray *items, NSInteger statusCode) {
        if (statusCode == 410) {
            [ShareHelper showAlertWithMessage:@"Session is expired. Please log in again." actionSuccess:NO inViewController:weakSelf];
        } else {
            if (items > 0) {
                weakSelf.page++;
            }
            NSArray* array = [SearchResultModel getSearchResultArrayFromResponse:items];
            if (weakSelf.isAppending) {
                _listOfFile = [[_listOfFile arrayByAddingObjectsFromArray:array] mutableCopy];
            } else {
                _listOfFile = [array mutableCopy];
            }
            
            [weakSelf.tableView reloadData];
        }
        
        weakSelf.isAppending = NO;
        [weakSelf.tableView finishInfiniteScroll];
    }];
    
    NSString* urlString = [NSString stringWithFormat:@"%@%@%@&page=%ld",[defaults valueForKey:@"api"], _url, _filter, _page];
    NSURL *downloadURL = [NSURL URLWithString:urlString];
    GetJSONOperation *operation = [[GetJSONOperation alloc] initWithCustomURL:downloadURL
                                                          withCompletionBlock:requestDataObject.myCompletionBlock];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _listOfFile.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    PropertyContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[PropertyContactCell cellIdentifier]];
//    return cell;
//}

- (NSArray*) separateNameIntoTwo:(NSString*) title
{
    NSMutableArray *items = [[title componentsSeparatedByString:@"("] mutableCopy];
    if ([items count] > 1) {
        items[1] = [items[1] substringToIndex:((NSString*)items[1]).length-1];
    } else {
        [items addObject:@""];
    }
    
    return items;
}

- (NSString*) getDateInShortForm: (NSString*) date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[[NSTimeZone localTimeZone] secondsFromGMT]/3600];
    [formatter setTimeZone:timeZone];
    
    NSDate *creationDate = [formatter dateFromString:date];
    [newFormatter setTimeZone:timeZone];
    [newFormatter setDateFormat:@"d MMM yyyy"];
    
    return [newFormatter stringFromDate:creationDate];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultModel *model = self.listOfFile[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    UILabel* firstValue = (UILabel*)[cell viewWithTag:1];
    UILabel* secondValue = (UILabel*)[cell viewWithTag:2];
    UILabel* thirdValue = (UILabel*)[cell viewWithTag:3];
    firstValue.text = model.key;
    if ([model.title containsString:@"File No."]) {
        thirdValue.text = [self separateNameIntoTwo:[model.title substringFromIndex:10]][1];
    } else {
        thirdValue.text = [self separateNameIntoTwo:model.title][1];
    }
    
    secondValue.text = [self getDateInShortForm:model.sortDate];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.updateHandler(_listOfFile[indexPath.row]);
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

@end
