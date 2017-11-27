//
//  Template.m
//  Denning
//
//  Created by Ho Thong Mee on 24/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "Template.h"
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import "TemplateCell.h"
#import "ListWithDescriptionViewController.h"
#import "TemplateType.h"

@interface Template ()<UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource,  HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate,
ContactListWithDescSelectionDelegate>
{
    __block BOOL isFirstLoading;
    __block BOOL isLoading;
    BOOL initCall;
    BOOL isAppending;
    NSInteger selectedIndex;
    NSString* curUserFilter, *baseUrl;
    NSString* curCategory, *curType;
    NSString* titleOfList;
    NSString* nameOfField;
}
@property (weak, nonatomic) IBOutlet UILabel *fileNo;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UIButton *btnCategory;
@property (weak, nonatomic) IBOutlet UIButton *btnType;

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listOfTemplates;
@property (strong, nonatomic) UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;
@property (strong, nonatomic) NSString* url;
@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;
@property (strong, nonatomic) NSArray* topFilter;
@property (strong, nonatomic) NSArray* arrayOfFilterValues;
@end

@implementation Template

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self parseUrl];
    [self prepareUI];
    [self updateHeaderInfo];
    [self registerNibs];
    [self configureSearch];
}

- (void) viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) updateHeaderInfo {
    _fileNo.text = _fileNoLabel;
    _fileName.text = _fileNameLabel;
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
    [TemplateCell registerForReuseInTableView:self.tableView];
    
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
    curUserFilter = @"all";
    
    self.btnCategory.titleLabel.minimumScaleFactor = 0.5f;
    self.btnCategory.titleLabel.numberOfLines = 0;
    self.btnCategory.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.btnType.titleLabel.minimumScaleFactor = 0.5f;
    self.btnType.titleLabel.numberOfLines = 0;
    self.btnType.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
    
    self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 75, self.view.frame.size.width, 44)];
    self.selectionList.delegate = self;
    self.selectionList.dataSource = self;
    
    self.selectionList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.selectionList.showsEdgeFadeEffect = YES;
    
    _topFilter = @[@"All", @"Online", @"User"];
    _arrayOfFilterValues = @[@"all", @"online", @"user"];
    self.selectionList.selectionIndicatorColor = [UIColor colorWithHexString:@"FF3B2F"];
    [self.selectionList setTitleColor:[UIColor colorWithHexString:@"FF3B2F"] forState:UIControlStateHighlighted];
    [self.selectionList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-Regular" size:17] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-SemiBold" size:17]  forState:UIControlStateSelected];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-SemiBold" size:17] forState:UIControlStateHighlighted];
    
    [self.view addSubview:self.selectionList];
    self.selectionList.backgroundColor = [UIColor blackColor];
    self.selectionList.selectedButtonIndex = 0;
    self.selectionList.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    
    return self.topFilter.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    
    return self.topFilter[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    if (curCategory.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select a category first" actionSuccess:NO inViewController:self];
        return;
    } else if (curType.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select a type" actionSuccess:NO inViewController:self];
        return;
    }
    // update the view for the corresponding index
    selectedIndex = index;
    isAppending = NO;
    self.page = @(1);
    curUserFilter = _arrayOfFilterValues[index];
    [self getList];
}

- (void) appendList {
    isAppending = YES;
    [self getList];
}

- (void) parseUrl {
    NSRange range =  [_url rangeOfString:@"/" options:NSBackwardsSearch];
    baseUrl = [_url substringToIndex:range.location+1];
    curUserFilter = [_url substringFromIndex:range.location+1];
}

- (IBAction)didTapCategory:(id)sender {
    titleOfList = @"Category";
    nameOfField = @"Category";
    [self performSegueWithIdentifier:kListWithDescriptionSegue sender:SEARCH_TEMPLATE_CATEGORY_GET];
}

- (IBAction)didTapType:(id)sender {
    if (curCategory.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select a category first" actionSuccess:NO inViewController:self];
        return;
    }
    [self performSegueWithIdentifier:kTemplateTypeSegue sender:SEARCH_TEMPLATE_CATEGORY_GET];
}

- (void) getList{
    if (isLoading) return;
    isLoading = YES;
  //  _url = [NSString stringWithFormat:@"%@%@", baseUrl, curUserFilter];
    @weakify(self)
    [[QMNetworkManager sharedManager] getTemplateWithFileno:[_fileNo.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] online:curUserFilter category:curCategory type:curType page:_page search:_filter withCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        @strongify(self)
        if (error == nil) {
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                self.listOfTemplates = [[self.listOfTemplates arrayByAddingObjectsFromArray:result] mutableCopy];
                
            } else {
                self.listOfTemplates = [result mutableCopy];
            }
            
            [self.tableView reloadData];
        }
        else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
        
        [self performSelector:@selector(clean) withObject:nil afterDelay:1.0];
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
    
    return self.listOfTemplates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TemplateModel *model = self.listOfTemplates[indexPath.row];
    
    TemplateCell *cell = [tableView dequeueReusableCellWithIdentifier:[TemplateCell cellIdentifier] forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [cell configureCellWithModel:model];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TemplateModel *model = self.listOfTemplates[indexPath.row];
    [self viewDocument:model.generateAPI];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    if (offsetY > contentHeight - scrollView.frame.size.height && !isFirstLoading) {
        
        [self appendList];
    }
}

#pragma mark - Search Delegate


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
    if (indexPath.row == self.listOfTemplates.count-1 && initCall) {
        isFirstLoading = NO;
        initCall = NO;
    }
}

#pragma mark - ContactListWithDescriptionDelegate
- (void) didSelectListWithDescription:(UIViewController *)listVC name:(NSString*) name withString:(NSString *)description
{
    if ([name isEqualToString:@"Category"]) {
        [self.btnCategory setTitle:description forState:UIControlStateNormal];
        curCategory = description;
    } else {
        [self.btnType setTitle:description forState:UIControlStateNormal];
        curType = description;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kListWithDescriptionSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        ListWithDescriptionViewController *listDescVC = navVC.viewControllers.firstObject;
        listDescVC.contactDelegate = self;
        listDescVC.titleOfList = titleOfList;
        listDescVC.name = nameOfField;
        listDescVC.url = sender;
    } else if ([segue.identifier isEqualToString:kTemplateTypeSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        TemplateType* vc = navVC.viewControllers.firstObject;
        vc.category = curCategory;
        vc.updateHandler = ^(NSDictionary *type) {
            curType = [type valueForKeyNotNull:@"strTypeCode"];
            [self.btnType setTitle:[type valueForKeyNotNull:@"strTypeName"] forState:UIControlStateNormal];
            
            [SVProgressHUD showWithStatus:@"Loading"];
            [self getList];
        };
    }
}

@end
