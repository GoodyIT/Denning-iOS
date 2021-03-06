//
//  FileListViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileListViewController.h"

#import "PropertyContactCell.h"
#import "ShareHelper.h"

@interface FileListViewController ()<UISearchBarDelegate, UISearchControllerDelegate,UITableViewDelegate, UITableViewDataSource>
{
    NSInteger page;
   __block BOOL isAppending;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString* filter;
@property (strong, nonatomic) NSMutableArray* listOfFile;
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
    page = 1;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
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
//    self.tableView.infiniteScrollTriggerOffset = 100;
    
    // Add infinite scroll handler
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        [weakSelf appendList];
    }];
}

- (void) appendList {
    isAppending = YES;
    [self getList];
}

- (void) getList{
    NSString* urlString = [NSString stringWithFormat:@"%@%@%@&page=%ld",[DataManager sharedManager].user.serverAPI, _url, _filter, page];
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:urlString completion:^(NSDictionary * _Nonnull items, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        @strongify(self)
        if  (error == nil) {
            if (items > 0) {
                self->page++;
            }
            NSArray* array = [SearchResultModel getSearchResultArrayFromResponse:(NSArray*)items];
            if (self->isAppending) {
                _listOfFile = [[_listOfFile arrayByAddingObjectsFromArray:array] mutableCopy];
            } else {
                _listOfFile = [array mutableCopy];
            }
            
            [self.tableView reloadData];
            self->isAppending = NO;
            [self.tableView finishInfiniteScroll];
        }
    }];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultModel *model = self.listOfFile[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    UILabel* firstValue = (UILabel*)[cell viewWithTag:1];
    UILabel* secondValue = (UILabel*)[cell viewWithTag:2];
    UILabel* thirdValue = (UILabel*)[cell viewWithTag:3];
    firstValue.text = model.key;
    if ([model.title containsString:@"File No."]) {
        thirdValue.text = [DIHelpers separateNameIntoTwo:[model.title substringFromIndex:10]][1];
    } else {
        thirdValue.text = [DIHelpers separateNameIntoTwo:model.title][1];
    }
    
    secondValue.text = [DIHelpers getDateInShortForm:model.sortDate];
    
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
    page = 1;
    [self getList];
    [_searchBar resignFirstResponder];
}

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    self.filter = @"";
    searchController.searchBar.text = @"";
    page = 1;
    [self getList];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    self.filter = searchText;
    page = 1;
    [self getList];
}

@end
