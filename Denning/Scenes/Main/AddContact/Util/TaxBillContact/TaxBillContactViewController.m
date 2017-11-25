//
//  TaxBillContactViewController.m
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TaxBillContactViewController.h"
#import "PropertyContactCell.h"
#import "SecondContactCell.h"
#import "ContactViewController.h"
#import "CommonTextCell.h"
#import "ContactCell.h"

@interface TaxBillContactViewController ()
<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    __block BOOL isLoading;
    BOOL isAppending;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<MatterSimple*>* listOfContacts;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;

@end

@implementation TaxBillContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNib];
    [self getListWithCompletion:nil];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) registerNib {
    [PropertyContactCell registerForReuseInTableView:self.tableView];
    [SecondContactCell registerForReuseInTableView:self.tableView];
    [ContactCell registerForReuseInTableView:self.tableView];
    [CommonTextCell registerForReuseInTableView:self.tableView];
}

- (void) prepareUI
{
    self.page = @(1);
    self.filter = @"";
    _url = GENERAL_CONTACT_URL;
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

- (NSArray*) filterResult:(NSArray*) result {
    NSMutableArray* array = [NSMutableArray new];
    
    for (MatterSimple* simple in result) {
        if (simple.partyGroupArray.count > 0) {
            [array addObject:simple];
        }
    }
    
    return [array copy];
}

- (NSDictionary*) getPartySectionInfo:(int) row matterModel:(MatterSimple*) matterSimple{
    int count = 0;
    NSDictionary* info = [NSDictionary new];
    for (int i = 0; i < matterSimple.partyGroupArray.count; i++) {
        PartyGroupModel* partyGroup = matterSimple.partyGroupArray[i];
        if (partyGroup.partyArray.count == 0) {
            continue;
        }
        info = @{@"group":[NSNumber numberWithInt:i],
                 @"party":[NSNumber numberWithInt:row-count]
                 };
        count += partyGroup.partyArray.count;
        if (row < count) {
            break;
        }
    }
    
    return info;
}

- (void) getListWithCompletion:(void(^)(void)) completion {
    if (isLoading) return;
    isLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    if (!isAppending) {
        [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Loading" duration:0];
    }
    @weakify(self)
    [[QMNetworkManager sharedManager] getSimpleMatter:self.page withSearch:(NSString*)self.filter WithCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        @strongify(self)
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            result = [self filterResult:result];
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                self.listOfContacts = [[self.listOfContacts arrayByAddingObjectsFromArray:result] mutableCopy];
                
            } else {
                [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
                self.listOfContacts = [result mutableCopy];
            }
            
            [self.tableView reloadData];
            
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
        self->isLoading = NO;
        [self.tableView finishInfiniteScroll];
    }];
}

- (void) clean {
    isLoading = NO;
}
#pragma mark - Table view data source

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _listOfContacts[section].systemNo;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.listOfContacts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = 0;
    for (PartyGroupModel* partyGroup in self.listOfContacts[section].partyGroupArray) {
        count += partyGroup.partyArray.count;
    }
    
    return count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kDefaultAccordionHeaderViewHeight;
}

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    PropertyContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[PropertyContactCell cellIdentifier]];
//    return cell;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MatterSimple *model = self.listOfContacts[indexPath.section];
    
    NSDictionary* partySectionInfo = [self getPartySectionInfo:(int)indexPath.row matterModel:model];
    PartyGroupModel* partyGroup = model.partyGroupArray[[[partySectionInfo objectForKey:@"group"] integerValue]];
    ClientModel* party = (ClientModel*)partyGroup.partyArray[[[partySectionInfo objectForKey:@"party"] integerValue]];
    
//    SecondContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[SecondContactCell cellIdentifier] forIndexPath:indexPath];
//    cell.firstValue.text = party.IDNo;
//    cell.secondValue.text = party.name;
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([[partySectionInfo objectForKey:@"party"] integerValue] == 0) {
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContactCell cellIdentifier] forIndexPath:indexPath];
        [cell configureCellWithContact:partyGroup.partyGroupName text:party.name];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    CommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[CommonTextCell cellIdentifier] forIndexPath:indexPath];
    [cell configureCellWithString:party.name];
    cell.valueLabel.font = [UIFont fontWithName:@"SFUIText-Light" size:13];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MatterSimple *model = self.listOfContacts[indexPath.section];
    
    NSDictionary* partySectionInfo = [self getPartySectionInfo:(int)indexPath.row matterModel:model];
    PartyGroupModel* partyGroup = model.partyGroupArray[[[partySectionInfo objectForKey:@"group"] integerValue]];
    ClientModel* party = (ClientModel*)partyGroup.partyArray[[[partySectionInfo objectForKey:@"party"] integerValue]];
    _updateHandler(party);
    [self.navigationController popViewControllerAnimated:YES];
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
