//
//  FeesTransfer.m
//  Denning
//
//  Created by Ho Thong Mee on 15/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FeesTransfer.h"
#import "BankReconCell.h"
#import "BankReconHeaderCell.h"
#import "ThreeColumnSecondCell.h"
#import "FeeTransferDetail.h"

@interface FeesTransfer ()
<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    __block BOOL isFirstLoading;
    __block BOOL isLoading;
    BOOL initCall;
    BOOL isAppending;
    NSInteger selectedIndex;
    NSString* curFeeFilter, *baseUrl;
    BOOL isUntransfer;
}

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listOfFees;
@property (strong, nonatomic) UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;
@property (weak, nonatomic) IBOutlet UIButton *btnUntransfer;
@property (weak, nonatomic) IBOutlet UIButton *btnTransfer;
@property (strong, nonatomic) NSArray* topFilter;
@property (strong, nonatomic) NSArray* arrayOfFilterValues;
@end

@implementation FeesTransfer

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
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
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
    [BankReconCell registerForReuseInTableView:self.tableView];
    [BankReconHeaderCell registerForReuseInTableView:self.tableView];
    [ThreeColumnSecondCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

- (void) prepareUI
{
    self.page = @(1);
    isFirstLoading = YES;
    self.filter = @"";
    initCall = YES;
    isAppending = NO;
    isUntransfer = YES;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapUntransfer:(id)sender {
    curFeeFilter = @"new";
    isUntransfer = YES;
    _page = @(1);
    [self.btnUntransfer setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.btnTransfer setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [SVProgressHUD showWithStatus:@"Loading"];
    [self getList];
}

- (IBAction)didTapTransfer:(id)sender {
    curFeeFilter = @"batch";
    isUntransfer = NO;
    _page = @(1);
    [self.btnUntransfer setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.btnTransfer setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [SVProgressHUD showWithStatus:@"Loading"];
    [self getList];
}

- (void) appendList {
    isAppending = YES;
    [self getList];
}

- (void) parseUrl {
    NSRange range =  [_url rangeOfString:@"/" options:NSBackwardsSearch];
    baseUrl = [_url substringToIndex:range.location+1];
    curFeeFilter = [_url substringFromIndex:range.location+1];
}

- (void) getList{
    if (isLoading) return;
    isLoading = YES;
    _url = [NSString stringWithFormat:@"%@%@", baseUrl, curFeeFilter];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] getDashboardFeeTransferInURL:_url withPage:_page withFilter:_filter withCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        [SVProgressHUD dismiss];
        if (isUntransfer) {
            result = [FeeUntransferModel getFeeUntransferArrayFromResponse:result];
        } else {
            result = [FeeTranserModel getFeeTranserArrayFromResponse:result];
        }
        if (error == nil) {
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                self.listOfFees = [[self.listOfFees arrayByAddingObjectsFromArray:result] mutableCopy];
                
            } else {
                if (_listOfFees.count > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    });
                }
                self.listOfFees = [result mutableCopy];
            }
            
            [self.tableView reloadData];
        }
        else {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listOfFees.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BankReconHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[BankReconHeaderCell cellIdentifier]];
    if (isUntransfer) {
        cell.firstValue.text = @"File no.";
        cell.secondValue.text = @"Tax Invoice no.";
        cell.thirdValue.text = @"Amount";
    } else {
        cell.firstValue.text = @"Date";
        cell.secondValue.text = @"Batch";
        cell.thirdValue.text = @"Amount";
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isUntransfer) {
        FeeUntransferModel *model = self.listOfFees[indexPath.row];
        ThreeColumnSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:[ThreeColumnSecondCell cellIdentifier] forIndexPath:indexPath];
        
        [cell configureCellWithModel:model];
        
        return cell;
    }
    
    FeeTranserModel *model = self.listOfFees[indexPath.row];
    BankReconCell *cell = [tableView dequeueReusableCellWithIdentifier:[BankReconCell cellIdentifier] forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [cell configureCellForFeesTransfer:model];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isUntransfer) {
        FeeTranserModel* model = _listOfFees[indexPath.row];
        [self performSegueWithIdentifier:kFeeTransferDetailSegue sender:model];
    }
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

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    
    if (offsetY > contentHeight - scrollView.frame.size.height && !isFirstLoading) {
        
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == self.listOfFees.count-1 && initCall) {
        isFirstLoading = NO;
        initCall = NO;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kFeeTransferDetailSegue]) {
        FeeTransferDetail* vc = segue.destinationViewController;
        vc.model = sender;
    }
}

@end




