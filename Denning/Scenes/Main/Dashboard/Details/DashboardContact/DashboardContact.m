//
//  DashboardContact.m
//  Denning
//
//  Created by Ho Thong Mee on 15/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DashboardContact.h"
#import "ClientModel.h"
#import "PropertyContactCell.h"
#import "SecondContactCell.h"
#import "ContactViewController.h"

@interface DashboardContact ()
<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    __block BOOL isLoading;
    BOOL isAppending;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listOfContacts;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;
@end

@implementation DashboardContact

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNib];
    [self getListWithCompletion:nil];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) registerNib {
    [PropertyContactCell registerForReuseInTableView:self.tableView];
    [SecondContactCell registerForReuseInTableView:self.tableView];
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
    [self getListWithCompletion:nil];
}

- (void) getListWithCompletion:(void(^)(void)) completion {
    if (isLoading) return;
    isLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] getDashboardContactInURL:_url withPage:_page withFilter:_filter withCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        @strongify(self)
        [self.tableView finishInfiniteScroll];
        if (error == nil) {
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            
            if (isAppending) {
                self.listOfContacts = [[self.listOfContacts arrayByAddingObjectsFromArray:result] mutableCopy];
                
            } else {
                self.listOfContacts = [result mutableCopy];
            }
            
            [self.tableView reloadData];
            if (completion != nil) {
                
            }
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
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listOfContacts.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PropertyContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[PropertyContactCell cellIdentifier]];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultModel *model = self.listOfContacts[indexPath.row];
    
    SecondContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[SecondContactCell cellIdentifier] forIndexPath:indexPath];
    cell.firstValue.text = [model.JsonDesc valueForKeyNotNull:@"name"];
    cell.secondValue.text = [NSString stringWithFormat:@"%@\n%@", [model.JsonDesc valueForKeyNotNull:@"IDNo"], [model.JsonDesc valueForKeyNotNull:@"KPLama"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_callback isEqualToString:@"callback"]) {
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (_updateHandler != nil) {
                _updateHandler(self.listOfContacts[indexPath.row]);
            }
        }];
    } else {
        [self openContact:self.listOfContacts[indexPath.row]];

    }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) openContact: (SearchResultModel*) model
{
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self);
    [[QMNetworkManager sharedManager] loadContactFromSearchWithCode:model.key completion:^(ContactModel * _Nonnull contactModel, NSError * _Nonnull error) {
        
        @strongify(self);
        self->isLoading = false;
        [SVProgressHUD dismiss];
        if (error == nil) {
            [self performSegueWithIdentifier:kContactSearchSegue sender:contactModel];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kContactSearchSegue]){
        UINavigationController* navVC = segue.destinationViewController;
        ContactViewController* contactVC = navVC.viewControllers.firstObject;
        contactVC.contactModel = sender;
    }
}
@end
