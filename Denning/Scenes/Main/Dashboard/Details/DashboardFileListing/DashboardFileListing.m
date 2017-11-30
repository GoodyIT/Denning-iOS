//
//  DashboardFileListing.m
//  Denning
//
//  Created by Ho Thong Mee on 28/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DashboardFileListing.h"
#import "FileListingHeaderCell.h"
#import "FileListingCell.h"
#import "RelatedMatterViewController.h"

@interface DashboardFileListing ()
<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    __block BOOL isLoading;
    BOOL isAppending;
    
    NSInteger _idx;
    NSArray* btnArray;
}

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listOfFiles;
@property (strong, nonatomic) NSArray<ItemModel*> *items;
@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnAll;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnToday;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnThisweek;

@property (strong, nonatomic) NSArray<UILabel*>* topLabels;
@end

@implementation DashboardFileListing

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNibs];
//    [self configureSearch];
    _idx = 1;
    [self getHeaderWithCompletion:^{
        [SVProgressHUD showWithStatus:@"Loading"];
        [self getList];
    }];
    
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
    [FileListingHeaderCell registerForReuseInTableView:self.tableView];
    [FileListingCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

- (void) prepareUI
{
    btnArray = @[_btnAll, _btnToday, _btnThisweek];
    self.page = @(1);
    self.filter = @"";
    isAppending = NO;

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

- (void) resetState: (MIBadgeButton*) button {
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBadgeBackgroundColor:[UIColor darkGrayColor]];
}

- (void) setStatus:(MIBadgeButton*) button {
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [button setBadgeBackgroundColor:[UIColor redColor]];
}

- (void) resetAllButtons {
    for (int i = 0; i < btnArray.count; i++) {
        [self resetState:btnArray[i]];
    }
}

- (void) didTapButton:(NSInteger) index {
    [self resetAllButtons];
    [self setStatus:btnArray[index]];
    _idx = index;
    _page = @(1);
    isAppending = NO;
    _url = _items[_idx].api;
    [SVProgressHUD showWithStatus:@"Loading"];
    [self getList];
}

- (IBAction)didTapAll:(id)sender {
    [self didTapButton:0];
}

- (IBAction)didTapToday:(id)sender {
    [self didTapButton:1];
}

- (IBAction)didTapThisweek:(id)sender {
    [self didTapButton:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) appendList {
    isAppending = YES;
    [self getList];
}

- (void) updateHeader {
    for (int i = 0; i < btnArray.count; i++) {
        [btnArray[i] setTitle:_items[i].label forState:UIControlStateNormal];
        [DIHelpers configureButton:btnArray[i] withBadge:_items[i].value withColor:[UIColor grayColor]];
    }
    [btnArray[1] setBadgeBackgroundColor:[UIColor redColor]];
}

- (void) getHeaderWithCompletion:(void(^)(void))completion;
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[QMNetworkManager sharedManager] getDashboardThreeItmesInURL:DASHBOARD_S1_MATTERLISTING_GET_URL withCompletion:^(ThreeItemModel * _Nonnull result, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if (error == nil) {
            _items = result.items;
            [self updateHeader];
            if (completion != nil) {
                completion();
            }
        }
    }];
}

- (void) getList{
    if (isLoading) return;
    isLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] getNewMatterInURL:_url withPage:self.page withFilter:self.filter withCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        [self.tableView finishInfiniteScroll];
        [SVProgressHUD dismiss];
        if (error == nil) {
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                self.listOfFiles = [[self.listOfFiles arrayByAddingObjectsFromArray:result] mutableCopy];
                
            } else {
                self.listOfFiles = [result mutableCopy];
            }
            
            [self.tableView reloadData];
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
        self->isLoading = NO;
//        self->isLoading = NO;
//        [self performSelector:@selector(clean) withObject:nil afterDelay:1.0];;
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
    
    return self.listOfFiles.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FileListingHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[FileListingHeaderCell cellIdentifier]];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultModel *model = self.listOfFiles[indexPath.row];
    
    FileListingCell *cell = [tableView dequeueReusableCellWithIdentifier:[FileListingCell cellIdentifier] forIndexPath:indexPath];
    cell.fileNo.text = model.key;
    if ([model.title containsString:@"File No."]) {
        cell.fileName.text = [DIHelpers separateNameIntoTwo:[model.title substringFromIndex:10]][1];
    } else {
        cell.fileName.text = [DIHelpers separateNameIntoTwo:model.title][1];
    }
    
    cell.openDate.text = [DIHelpers getDateInShortForm:model.sortDate];
    
    return cell;
}

- (void) openRelatedMatter: (SearchResultModel*) model {
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self);
    [[QMNetworkManager sharedManager] loadRelatedMatterWithCode:model.key completion:^(RelatedMatterModel * _Nonnull relatedModel, NSError * _Nonnull error) {
        
        @strongify(self);
        self->isLoading = false;
        [SVProgressHUD dismiss];
        if (error == nil) {
            [self performSegueWithIdentifier:kRelatedMatterSegue sender:relatedModel];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self openRelatedMatter:self.listOfFiles[indexPath.row]];
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
    if ([segue.identifier isEqualToString:kRelatedMatterSegue]){
        RelatedMatterViewController* relatedMatterVC = segue.destinationViewController;
        relatedMatterVC.relatedMatterModel = sender;
        relatedMatterVC.previousScreen = @"Dashboard FileListing";
    }

}

@end
