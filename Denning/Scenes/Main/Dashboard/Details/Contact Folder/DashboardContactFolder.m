//
//  DashboardContactFolder.m
//  Denning
//
//  Created by Denning IT on 2017-12-01.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DashboardContactFolder.h"
#import "ThreeColumnSecondCell.h"
#import "BankReconHeaderCell.h"
#import "DocumentViewController.h"

@interface DashboardContactFolder ()
<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    __block BOOL isLoading;
    BOOL isAppending;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listOfContactFolders;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;
@end

@implementation DashboardContactFolder

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareUI];
    [self registerNib];
    [self getList];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) registerNib {
    [ThreeColumnSecondCell registerForReuseInTableView:self.tableView];
    [BankReconHeaderCell registerForReuseInTableView:self.tableView];
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

- (void) appendList {
    isAppending = YES;
    [self getList];
}

- (void) getList{
    if (isLoading) return;
    isLoading = YES;
    NSString* urlString = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, _url, _filter, _page];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:urlString completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        @strongify(self)
        [self.tableView finishInfiniteScroll];
        if (error == nil) {
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            NSArray* array = [ContactFolderItem getContactFolderItemArray:(NSArray*)result];
            if (isAppending) {
                self.listOfContactFolders = [[self.listOfContactFolders arrayByAddingObjectsFromArray:array] mutableCopy];
                
            } else {
                self.listOfContactFolders = [array mutableCopy];
            }
            
            [self.tableView reloadData];
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
    
    return self.listOfContactFolders.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BankReconHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[BankReconHeaderCell cellIdentifier]];
    cell.firstValue.text = @"Contact";
    cell.secondValue.text = @"Last Modified";
    cell.thirdValue.text = @"Items";
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactFolderItem *model = self.listOfContactFolders[indexPath.row];
    
    ThreeColumnSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:[ThreeColumnSecondCell cellIdentifier] forIndexPath:indexPath];
    [cell configureCellWithContactFolderItem:model];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self openContactFolder:_listOfContactFolders[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) openContactFolder: (ContactFolderItem*) model
{
    if (isLoading) return;
    isLoading = YES;
    @weakify(self);
    [SVProgressHUD showWithStatus:@"Loading"];
    [[QMNetworkManager sharedManager] getResponseWithUrl:model.url withCompletion:^(id  _Nonnull result, NSError * _Nonnull error) {
        @strongify(self);
        self->isLoading = false;
        [SVProgressHUD dismiss];
        if (error == nil) {
            DocumentModel* documentModel = [DocumentModel getDocumentFromResponse:result];
            [self performSegueWithIdentifier:kDocumentSearchSegue sender:documentModel];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kDocumentSearchSegue]){
        UINavigationController* navC = segue.destinationViewController;
        DocumentViewController* documentVC = navC.viewControllers.firstObject;
        documentVC.title = @"Contact Folder";
        documentVC.documentModel = sender;
    }
    // Get the new view controller using [segue destinationViewController].
    
    // Pass the selected object to the new view controller.
}


@end
