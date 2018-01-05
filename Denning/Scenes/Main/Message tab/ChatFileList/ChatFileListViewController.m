//
//  ChatFileListViewController.m
//  Denning
//
//  Created by Denning IT on 2017-12-16.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ChatFileListViewController.h"
#import "MLPAutoCompleteTextField.h"
#import "DEMOCustomAutoCompleteCell.h"
#import "DEMOCustomAutoCompleteObject.h"
#import "AFHTTPSessionOperation.h"
#import "DocumentViewController.h"
#import "FileSearchCell.h"

@interface ChatFileListViewController ()<UITextFieldDelegate, MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource,
UITableViewDelegate, UITableViewDataSource>
{
    NSInteger category;
    NSInteger selectedIndexOfFilter;
    NSString* keyword;
    NSString* searchURL;
    NSString* searchKeywordURL;
    NSString * searchType;
    NSString* fileFolderTitle;
    
    NSString* _email;
    NSString* _sessionID;
    
    NSInteger selectedIndex;
    
    __block BOOL isLoading;
    __block BOOL isAppending;
}

@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *searchTextField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchView;

@property (nonatomic, strong) NSDictionary *generalSearchFilters;
@property (nonatomic, strong) NSDictionary *publicSearchFilters;

@property (strong, nonatomic) NSMutableArray* searchResultArray, *filteredArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchContainerConstraint;
@property (weak, nonatomic) IBOutlet UIView *searchContainerView;
@property (weak, nonatomic) IBOutlet M13ProgressViewBar *topProgressBar;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSNumber* page;
@end

@implementation ChatFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self registerNibs];
    [self prepareUI];
    [self prepareSearchTextField];
    [self displaySearchResult];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)dismissView:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden =  YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareSearchTextField
{
    self.searchTextField.delegate = self;
    self.searchTextField.autoCompleteDataSource = self;
    self.searchTextField.autoCompleteDelegate = self;
    self.searchTextField.backgroundColor = [UIColor whiteColor];
    [self.searchTextField registerAutoCompleteCellClass:[DEMOCustomAutoCompleteCell class]
                                 forCellReuseIdentifier:@"CustomCellId"];
    self.searchTextField.maximumNumberOfAutoCompleteRows = 3;
    self.searchTextField.applyBoldEffectToAutoCompleteSuggestions = YES;
    self.searchTextField.showAutoCompleteTableWhenEditingBegins = YES;
    self.searchTextField.disableAutoCompleteTableUserInteractionWhileFetching = YES;
    [self.searchTextField setAutoCompleteRegularFontName:@"SFUIText-Regular"];
    
    // searchcontainer constraint
    self.searchContainerView.userInteractionEnabled = YES;
    self.searchContainerConstraint.constant = 44;
    
    // add search icon to the left view
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* searchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search_black"]];
    self.searchTextField.leftView = searchImageView;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [DataManager sharedManager].isFirstLoading = @"YES";
        [self.searchTextField becomeFirstResponder];
        [DataManager sharedManager].isFirstLoading = @"NO";
    });
}

- (void) prepareUI
{
    searchType = @"Normal";
    selectedIndex = 0;
    self.page = @(1);
    category = 0;
   
    _searchResultArray = [NSMutableArray new];
    searchURL = [[DataManager sharedManager].user.serverAPI stringByAppendingString: GENERAL_SEARCH_URL];
  
    _email = [DataManager sharedManager].user.email;
    _sessionID = [DataManager sharedManager].user.sessionID;
    [DataManager sharedManager].searchType = @"Denning";
    
    self.searchTextField.placeholder = @"Denning Search";
    self.searchTextField.text = keyword = _initialKeyword;
    
    [_topProgressBar setProgressBarThickness:5];
    [_topProgressBar setShowPercentage:NO];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"EBEBF1"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
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
        [self appendSearchResult];
    }];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [self buildSearchKeywordURL];
    });
}

- (void) buildSearchKeywordURL
{
    searchKeywordURL = [[DataManager sharedManager].user.serverAPI stringByAppendingString: GENERAL_KEYWORD_SEARCH_URL];
}

- (void)registerNibs {
    [FileSearchCell registerForReuseInTableView:self.tableView];
  
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT/2;
}

- (IBAction)didChangeFolderType:(UISegmentedControl *)sender {
    selectedIndex = sender.selectedSegmentIndex;
    [self filterResult];
}

- (IBAction)didTapTransitFolder:(id)sender {
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/matter/transit/fileFolder", [DataManager sharedManager].user.serverAPI];
    fileFolderTitle = @"Transit Folder";
    [self openDocument:url];
}

- (void) filterResult {
    NSMutableArray* temp = [NSMutableArray new];
    for (SearchResultModel* model in _searchResultArray) {
        NSUInteger cellType = [DIHelpers detectItemType:model.form];
        if  (selectedIndex == 0) {
            [temp addObject:model];
        } else if (cellType == DIContactCell && selectedIndex == 2 ) { // Contact
            [temp addObject:model];
        } else if (cellType == DIRelatedMatterCell && selectedIndex == 1) { // File
            [temp addObject:model];
        }
    }
    
    _filteredArray = [temp mutableCopy];
    [self.tableView reloadData];
}

- (void) appendSearchResult {
    isAppending = YES;
    [self displaySearchResult];
}

- (void) displaySearchResult
{
    if (isLoading) return;
    isLoading = YES;
    
    [_topProgressBar performAction:M13ProgressViewActionNone animated:YES];
    [_topProgressBar setProgress:0 animated:YES];
    @weakify(self)
    [[QMNetworkManager sharedManager] getGlobalSearchFromKeyword:keyword searchURL:searchURL forCategory:category searchType:searchType withPage:_page withProgress:^(CGFloat progress) {
        [_topProgressBar setProgress:progress*100 animated:YES];
    } withCompletion:^(NSArray * _Nonnull resultArray, NSError* _Nonnull error) {
        
        [_topProgressBar performAction:M13ProgressViewActionSuccess animated:YES];
        [_topProgressBar setProgress:0 animated:YES];
        @strongify(self);
        self->isLoading = NO;
        [self.tableView finishInfiniteScroll];
        if (error == nil)
        {
            if (resultArray.count > 0) {
                _page = [NSNumber numberWithInteger:([_page integerValue] + 1)];
            }
            if (isAppending) {
                _searchResultArray = [[_searchResultArray arrayByAddingObjectsFromArray:resultArray] mutableCopy];
            } else {
                self.searchResultArray = [resultArray mutableCopy];
            }
            
            [self filterResult];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
        
        self->isAppending = NO;
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    keyword = self.searchTextField.text;
    [self.searchTextField resignFirstResponder];
    searchType = @"Special";
    _page = @(1);
    [self displaySearchResult];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    
    return [self.filteredArray count];
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    SearchResultModel* model = self.filteredArray[section];
    NSUInteger cellType = [DIHelpers detectItemType:model.form];
    if (cellType == DIContactCell) { // Contact
        sectionName = @"Contact";
    } else if (cellType == DIRelatedMatterCell){ // Related Matter
        sectionName = @"Matter";
    }
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultModel* model = self.filteredArray[indexPath.section];
    FileSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:[FileSearchCell cellIdentifier] forIndexPath:indexPath];
    [cell configureCell:model];
    cell.checkmarkImageView.hidden = YES;
    
    return cell;
}

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SearchResultModel* model = self.filteredArray[indexPath.section];
    NSUInteger cellType = [DIHelpers detectItemType:model.form];
    NSString* url;
    if (cellType == DIContactCell) {
        fileFolderTitle = @"Contact Folder";
        url = [NSString stringWithFormat:@"%@denningwcf/v1/app/contactFolder/%@", [DataManager sharedManager].user.serverAPI, model.key];
    } else {
        fileFolderTitle = @"File Folder";
        url = [NSString stringWithFormat:@"%@denningwcf/v1/app/matter/%@/fileFolder", [DataManager sharedManager].user.serverAPI, model.key];
    }
    
    [self openDocument:url];
}

- (void) openDocument: url
{
    if (isLoading) return;
    isLoading = YES;
    @weakify(self);
    [SVProgressHUD showWithStatus:@"Loading"];
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
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

#pragma mark - MLPAutoCompleteTextField DataSource

- (NSArray*) parseResponse: (id) response
{
    NSMutableArray* keywords = [NSMutableArray new];
    for (id obj in response) {
        [keywords addObject:[obj objectForKey:@"keyword"]];
    }
    
    return keywords;
}

//example of asynchronous fetch:
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    
    if ([[DataManager sharedManager].searchType isEqualToString:@"Denning"]){
        [[QMNetworkManager sharedManager].manager.requestSerializer setValue:_sessionID forHTTPHeaderField:@"webuser-sessionid"];
        [[QMNetworkManager sharedManager].manager.requestSerializer setValue:_email forHTTPHeaderField:@"webuser-id"];
    } else {
        [[QMNetworkManager sharedManager].manager.requestSerializer setValue:@"{334E910C-CC68-4784-9047-0F23D37C9CF9}" forHTTPHeaderField:@"webuser-sessionid"];
        [[QMNetworkManager sharedManager].manager.requestSerializer setValue:_email forHTTPHeaderField:@"webuser-id"];
    }
    
    NSString* url = [searchKeywordURL stringByAppendingString:[string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    NSOperation *operation = [AFHTTPSessionOperation operationWithManager:[QMNetworkManager sharedManager].manager
                                                               HTTPMethod:@"GET"
                                                                URLString:url
                                                               parameters:nil
                                                           uploadProgress:nil
                                                         downloadProgress:nil
                                                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                                      NSLog(@"%@", responseObject);
                                                                      
                                                                      handler([self parseResponse:responseObject]);                     } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                                                                          NSLog(@"%@", error);
                                                                      }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    //    CGFloat contentHeight = scrollView.contentSize.height;
    if (offsetY > 10) {
        
        [self.view endEditing:YES];
    }
}

#pragma mark - MLPAutoCompleteTextField Delegate

- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
          shouldConfigureCell:(UITableViewCell *)cell
       withAutoCompleteString:(NSString *)autocompleteString
         withAttributedString:(NSAttributedString *)boldedString
        forAutoCompleteObject:(id<MLPAutoCompletionObject>)autocompleteObject
            forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.textLabel.text = autocompleteString;
    return YES;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedObject){
        NSLog(@"selected object from autocomplete menu %@ with string %@", selectedObject, [selectedObject autocompleteString]);
    } else {
        searchType = @"Normal";
        keyword = selectedString;
        _page = @(1);
        [self displaySearchResult];
    }
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view will be removed from the view hierarchy");
    // searchcontainer constraint
    _topProgressBar.hidden = NO;
    self.searchContainerConstraint.constant = 44 ;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view will be added to the view hierarchy");
    // searchcontainer constraint
    _topProgressBar.hidden = YES;
    self.searchContainerConstraint.constant = 165;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view ws removed from the view hierarchy");
    // [self.searchTextField resignFirstResponder];

}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view was added to the view hierarchy");
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kDocumentSearchSegue]){
        DocumentViewController* documentVC = segue.destinationViewController;
        documentVC.title = fileFolderTitle;
        documentVC.documentModel = sender;
        documentVC.custom = @"custom";
        documentVC.updateHandler = _updateHandler;
    }
}


@end
