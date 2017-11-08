
//
//  TaxInvoice.m
//  Denning
//
//  Created by Ho Thong Mee on 15/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TaxInvoice.h"
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import "TaxInvoiceCell.h"
#import "BankReconHeaderCell.h"

@interface TaxInvoice ()
<UIDocumentInteractionControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource,  HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>
{
    __block BOOL isFirstLoading;
    __block BOOL isLoading;
    BOOL initCall;
    BOOL isAppending;
    NSInteger selectedIndex;
    NSString* curBalanceFilter, *baseUrl;
    NSURL* selectedDocument;
}

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listOfTaxInvoices;
@property (strong, nonatomic) UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;
@property (strong, nonatomic) NSNumber* page;

@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;
@property (strong, nonatomic) NSArray* topFilter;
@property (strong, nonatomic) NSArray* arrayOfFilterValues;
@end

@implementation TaxInvoice

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
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
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
    [TaxInvoiceCell registerForReuseInTableView:self.tableView];
    [BankReconHeaderCell registerForReuseInTableView:self.tableView];
    
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
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
    
    self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, 44)];
    self.selectionList.delegate = self;
    self.selectionList.dataSource = self;
    
    self.selectionList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.selectionList.showsEdgeFadeEffect = YES;
    
    _topFilter = @[@"All", @"Settles", @"Outstanding"];
    _arrayOfFilterValues = @[@"all", @"settled", @"outstanding"];
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
    // update the view for the corresponding index
    selectedIndex = index;
    isAppending = NO;
    self.page = @(1);
    curBalanceFilter = _arrayOfFilterValues[index];
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
    curBalanceFilter = [_url substringFromIndex:range.location+1];
}

- (void) getList{
    if (isLoading) return;
    isLoading = YES;
    _url = [NSString stringWithFormat:@"%@%@", baseUrl, curBalanceFilter];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    @weakify(self)
    [[QMNetworkManager sharedManager] getDashboardTaxInvoiceInURL:_url withPage:_page withFilter:_filter withCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        @strongify(self)
        if (error == nil) {
            if (result.count != 0) {
                self.page = [NSNumber numberWithInteger:[self.page integerValue] + 1];
            }
            if (isAppending) {
                self.listOfTaxInvoices = [[self.listOfTaxInvoices arrayByAddingObjectsFromArray:result] mutableCopy];
                
            } else {
                self.listOfTaxInvoices = [result mutableCopy];
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
    
    return self.listOfTaxInvoices.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BankReconHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[BankReconHeaderCell cellIdentifier]];
    cell.firstValue.text = @"Tax invoice no.";
    cell.secondValue.text = @"File no.";
    cell.thirdValue.text = @"Amount";
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaxInvoceModel *model = self.listOfTaxInvoices[indexPath.row];
    
    TaxInvoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:[TaxInvoiceCell cellIdentifier] forIndexPath:indexPath];
    
    [cell configureCellWithModel:model];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaxInvoceModel *model = self.listOfTaxInvoices[indexPath.row];
    [SVProgressHUD showWithStatus:@"Loading"];
    [self viewPDF:model.APIpdf];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) viewPDF:(NSString*) pdfUrl {
    NSString *urlString = [NSString stringWithFormat:@"%@denningwcf/%@", [DataManager sharedManager].user.serverAPI, pdfUrl];
    NSURL *url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[DataManager sharedManager].user.email  forHTTPHeaderField:@"webuser-id"];
    [request setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                           inDomain:NSUserDomainMask
                                                                  appropriateForURL:nil
                                                                             create:NO error:nil];
        
        NSString* newPath = [[documentsDirectory absoluteString] stringByAppendingString:[NSString stringWithFormat:@"DenningIT%@/", [DIHelpers randomTime]]];
        if (![FCFileManager isDirectoryItemAtPath:newPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:newPath  withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        return [documentsDirectory URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [SVProgressHUD dismiss];
        if (filePath != nil) {
            selectedDocument = filePath;
            [self displayDocument:filePath];
        }
    }];
    [downloadTask resume];
}

- (void)displayDocument:(NSURL*)document {
    UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:document];
    documentInteractionController.delegate = self;
    [documentInteractionController presentPreviewAnimated:YES];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controlle
{
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[selectedDocument path] error:&error];
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
    [self getList];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == self.listOfTaxInvoices.count-1 && initCall) {
        isFirstLoading = NO;
        initCall = NO;
    }
}

#pragma mark - Navigation

@end
