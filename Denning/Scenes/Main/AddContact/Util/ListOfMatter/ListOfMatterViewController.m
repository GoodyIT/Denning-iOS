//
//  ListOfMatterViewController.m
//  Denning
//
//  Created by DenningIT on 12/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ListOfMatterViewController.h"
#import "TwoColumnCell.h"
#import "SecondMatterTypeCell.h"

@interface ListOfMatterViewController ()<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    __block BOOL isFirstLoading;
    __block BOOL isLoading;
    __block BOOL isAppending;
    BOOL initCall;
}

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listOfMatters;
@property (strong, nonatomic) NSArray* copyedList;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;

@end

@implementation ListOfMatterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNib];
  //  [self configureSearch];
    [self getListWithCompletion:nil];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) registerNib {
    [TwoColumnCell registerForReuseInTableView:self.tableView];
    [SecondMatterTypeCell registerForReuseInTableView:self.tableView];
    
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
    [self.searchContainer addSubview:self.searchController.searchBar];
}

- (void) prepareUI
{
    self.copyedList = [NSMutableArray new];
    self.page = @(0);
    isFirstLoading = YES;
    self.filter = @"";
    initCall = YES;
    isAppending = NO;
    self.title = @"Select matter";
    
    self.tableView.delegate = self;
    
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

- (void) appendList {
    isAppending = YES;
    [self getListWithCompletion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.filter = _searchController.searchBar.text;
    isAppending = NO;
    self.page = @(1);
    [self getListWithCompletion:nil];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getListWithCompletion:(void(^)(void)) completion {
    
    if (isLoading) return;
    isLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] getMatterCode:self.page withSearch:(NSString*)self.filter WithCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        @strongify(self)
        if (error == nil) {
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                self.listOfMatters = [[self.listOfMatters arrayByAddingObjectsFromArray:result] mutableCopy];
            } else {
                self.listOfMatters = [result mutableCopy];
            }
           
            [self.tableView reloadData];
            
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
        [self performSelector:@selector(clean) withObject:nil afterDelay:1.0];
        
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
    
    return self.listOfMatters.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TwoColumnCell *cell = [tableView dequeueReusableCellWithIdentifier:[TwoColumnCell cellIdentifier]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MatterCodeModel *model = self.listOfMatters[indexPath.row];
    
    SecondMatterTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:[SecondMatterTypeCell cellIdentifier] forIndexPath:indexPath];
    
    cell.firstValue.text = model.matterCode;
    cell.secondValue.text = model.matterDescription;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MatterCodeModel *model = self.listOfMatters[indexPath.row];
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

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    
    if (offsetY > contentHeight - scrollView.frame.size.height && !isFirstLoading && !isLoading) {
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
    [self getListWithCompletion:nil];
    [_searchBar resignFirstResponder];
}

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    self.filter = @"";
    self.page = @(1);
    searchController.searchBar.text = @"";
    isAppending = NO;
    [self getListWithCompletion:nil];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    self.filter = searchText;
    isAppending = NO;
     self.page = @(1);
    [self getListWithCompletion:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == self.listOfMatters.count-1 && initCall) {
        isFirstLoading = NO;
        initCall = NO;
    }
}


@end
