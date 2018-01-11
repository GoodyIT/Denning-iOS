//
//  DenningShareViewController.m
//  DenningShare
//
//  Created by Denning IT on 2018-01-04.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import "DenningShareViewController.h"
@import MobileCoreServices;
#import "MLPAutoCompleteTextField.h"
#import "DEMOCustomAutoCompleteCell.h"
#import "DEMOCustomAutoCompleteObject.h"
#import "AFHTTPSessionOperation.h"
//#import "DocumentViewController.h"
#import "UIScrollView+InfiniteScroll.h"
#import "CustomInfiniteIndicator.h"
#import "FileSearchCell.h"
#import "CoreDataOperation.h"
#import "Items.h"
#import "GetJSONOperation.h"
#import "Constants.h"
#import "DIGlobal.h"
#import "NSString+URLEncoding.h"
#import "RequestObject.h"
#import "StaffModel.h"
#import "SearchResultModel.h"
#import "ShareHelper.h"
#import "DocumentModel.h"
#import "FirmURLModel.h"

static int THE_CELL_HEIGHT = 450;

@interface DenningShareViewController ()
<UITextFieldDelegate, MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource,
UITableViewDelegate, UITableViewDataSource,
NSURLSessionDelegate, UITextFieldDelegate>
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
    
    NSString* userType;
    
    NSInteger selectedIndex, page;
    
    NSUserDefaults* defaults;
    NSURLSession* mySession;
    
    NSMutableArray* shareItems, *selectedIndexPaths;
    NSString* fileNo1;
    
    __block BOOL isLoading;
    __block BOOL isAppending;
}

@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientSearchTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *transitBtn;

@property (strong, nonatomic) UIAlertController *uploadingIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchView;

@property (nonatomic, strong) NSDictionary *generalSearchFilters;
@property (nonatomic, strong) NSDictionary *publicSearchFilters;

@property (strong, nonatomic) NSMutableArray* searchResultArray, *filteredArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchContainerConstraint;
@property (weak, nonatomic) IBOutlet UIView *searchContainerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl* topSegment;

@property RequestObject *requestDataObject;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* filter;
@end

@implementation DenningShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self registerNibs];
    [self loadShareItems];
    [self prepareUI];
    if ([defaults boolForKey:@"isStaff"] ) {
        _clientSearchTextField.hidden = YES;
        [self prepareSearchTextField];
        [self displaySearchResult];
        [self setupCustomIndicator];
    } else {
        _searchContainerView.hidden = YES;
        _topSegment.hidden = YES;
        [self getBranch];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)dismissView:(id)sender {
    NSError* error;
    [self.extensionContext cancelRequestWithError:error];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden =  YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
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
    [self.searchTextField setAutoCompleteRegularFontName:@"Helvetica"];
    [self.searchTextField setAutoCompleteBoldFontName:@"Helvetica-Bold"];
    // searchcontainer constraint
    self.searchContainerView.userInteractionEnabled = YES;
    self.searchContainerConstraint.constant = 44;
    
    // add search icon to the left view
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* searchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search_gray"]];
    self.searchTextField.leftView = searchImageView;
    
    [self performSelector:@selector(searchFieldKeyboardShow) withObject:nil afterDelay:1.0f];
}

- (void) searchFieldKeyboardShow {
     [self.searchTextField becomeFirstResponder];
}

- (void) loadShareItems {
    shareItems = [NSMutableArray new];
    for (NSItemProvider* itemProvider in ((NSExtensionItem*)self.extensionContext.inputItems[0]).attachments) {
         NSString* typeIdenfier = itemProvider.registeredTypeIdentifiers[0];
        [itemProvider loadItemForTypeIdentifier:typeIdenfier options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
            NSData* imgData;
            if ([(NSObject*)item isKindOfClass:[NSURL class]]) {
                imgData = [NSData dataWithContentsOfURL:(NSURL*)item];
            }
            NSNumber* fileLength = [NSNumber numberWithInteger:imgData.length];
            
            NSString* base64Data = [[NSData dataWithContentsOfFile:(NSString*)item] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            NSString* fileType = [(NSString*)item pathExtension];
            NSString* fileName = [(NSString*)item lastPathComponent];
            
            NSDictionary* dic = @{@"FileName":fileName,
                                  @"MimeType":fileType,
                                  @"dateCreate": [ShareHelper todayWithTime],
                                  @"dateModify":[ShareHelper todayWithTime],
                                  @"fileLength":fileLength,
                                  @"remarks":@"file from iOS",
                                  @"base64":base64Data
                                  };
            [shareItems addObject:dic];
        }];
    }
}

- (void) setupCustomIndicator {
    CustomInfiniteIndicator *indicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    
    // Set custom indicator
    self.tableView.infiniteScrollIndicatorView = indicator;
    // Set custom indicator margin
    self.tableView.infiniteScrollIndicatorMargin = 40;
    
    // Set custom trigger offset
    self.tableView.infiniteScrollTriggerOffset = 500;
    
    // Add infinite scroll handler
    __weak __typeof(self)weakSelf = self;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        
        [weakSelf appendSearchResult];
    }];
}

- (void) prepareUI
{
    [UITextField appearance].keyboardAppearance = UIKeyboardAppearanceDark;
    
    self.url = @"";
    fileNo1 = @"";
    _sendBtn.enabled = NO;
    _filter = @"";
    
    selectedIndexPaths = [NSMutableArray new];
    searchType = @"Normal";
    selectedIndex = 0;
    page = 1;
    category = 0;
    _topSegment.selectedSegmentIndex = selectedIndex;
    
    defaults = [[NSUserDefaults alloc] initWithSuiteName:kGroupShareIdentifier];
    userType = [defaults valueForKey:@"isDenning"];
    
    if (![defaults boolForKey:@"isDenning"] && ![defaults boolForKey:@"isClient"] && ![defaults boolForKey:@"isStaff"]) {
        [self showAlertWithMessage:@"You cannot upload file. please login into Denning." withTitle:@"Warning" actionSuccess:NO inViewController:self withCallback:^{
            [self dismissView:nil];
        }];
    }
    
    _searchResultArray = [NSMutableArray new];
    searchURL = [[defaults valueForKey:@"api"] stringByAppendingString: GENERAL_SEARCH_URL];
    
    _email = [defaults valueForKey:@"email"];
 
    self.searchTextField.placeholder = @"Denning Folders";
    if ([defaults boolForKey:@"isStaff"] ) {
        _topHeightConstraint.constant = 130;
        self.searchTextField.text = keyword = _initialKeyword;
        _sessionID = [defaults valueForKey:@"sessionID"];
    } else {
        _topHeightConstraint.constant = 90;
        _sessionID = @"{334E910C-CC68-4784-9047-0F23D37C9CF9}";
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self buildSearchKeywordURL];
    });
}

- (void) buildSearchKeywordURL
{
    searchKeywordURL = [[defaults valueForKey:@"api"] stringByAppendingString: GENERAL_KEYWORD_SEARCH_URL];
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

- (IBAction)didTapSend:(id)sender {
    if (isLoading) return;
    isLoading = YES;
    
    NSDictionary* params = @{@"fileNo1":fileNo1,
                             @"documents":shareItems
                             };
    
    self.uploadingIndicator = [UIAlertController
                               alertControllerWithTitle:@""
                               message:@"Uploading..."
                               preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    [self.uploadingIndicator addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull __unused action) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
         __strong typeof(self) strongSelf = weakSelf;
        strongSelf->isLoading = NO;
    }]];
    
    [self presentViewController:self.uploadingIndicator animated:YES completion:nil];
    
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    _requestDataObject = [RequestObject new];
    [_requestDataObject setIncompleteString:@""];
    
    [_requestDataObject setMyCompletionBlock:^(NSArray *items, NSInteger statusCode) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf->isLoading = NO;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [strongSelf dismissAlert];
        });
        
        if (statusCode == 410) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [ShareHelper showAlertWithMessage:@"Session is expired. Please log in again." actionSuccess:NO inViewController:strongSelf];
            });
        } else{
            [strongSelf performSelector:@selector(dismissAlert) withObject:nil afterDelay:0.2f];
            if ([items[0] isEqualToString:@"200"]) {
                [strongSelf performSelector:@selector(showCompleteMessage) withObject:nil afterDelay:0.3f];
            } else {
                [strongSelf performSelector:@selector(showCompleteMessage) withObject:nil afterDelay:0.3f];
            }
        }
    }];
    
    NSString* urlString = [self.url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *downloadURL = [NSURL URLWithString:urlString];
    GetJSONOperation *operation = [[GetJSONOperation alloc] initWithCustomURL:downloadURL sessionID:[defaults valueForKey:@"sessionID"]
                                                          withCompletionBlock:_requestDataObject.myCompletionBlock params:params];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void) dismissAlert {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showCompleteMessage {
    [ShareHelper showAlertWithMessage:@"Success" actionSuccess:YES inViewController:self];
}

- (IBAction)didTapTransitFolder:(id)sender {
    self.url = [[defaults valueForKey:@"api"] stringByAppendingString: MATTER_STAFF_TRANSIT_FOLDER];
    fileNo1 = @"Transit Folder";
    _sendBtn.enabled = YES;
}

- (NSUInteger) detectItemType: (NSString*) form
{
    if ([form isEqualToString:@"200customer"]) // Contact
    {
        return DIContactCell;
    } else if ([form isEqualToString:@"500file"]){ // Related Matter
        return DIRelatedMatterCell;
    } else if ([form isEqualToString:@"800property"]){ // Property
        return DIPropertyCell;
    } else if ([form isEqualToString:@"400bankbranch"]){ // Bank
        return DIBankCell;
    } else if ([form isEqualToString:@"310landoffice"] || [form isEqualToString:@"310landregdist"]){ // Government Office
        return DIGovernmentLandOfficesCell;
    } else if ([form isEqualToString:@"320PTG"]){ // Government Office
        return DIGovernmentPTGOfficesCell;
    } else if ([form isEqualToString:@"300lawyer"]){ // Legal firm
        return DILegalFirmCell;
    } else if ([form isEqualToString:@"950docfile"] || [form isEqualToString:@"900book"]){ // Document
        return DIDocumentCell;
    }
    
    return 0;
}

- (void) getBranch {
    if (isLoading) return;
    isLoading = YES;
    
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    
    _requestDataObject = [RequestObject new];
    [_requestDataObject setIncompleteString:@""];
    __weak typeof(self) weakSelf = self;
    [_requestDataObject setMyCompletionBlock:^(NSArray *items, NSInteger statusCode) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf->isLoading = NO;
        if (statusCode == 410) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [ShareHelper showAlertWithMessage:@"Session is expired. Please log in again." actionSuccess:NO inViewController:weakSelf];
            });
        } else {
            
            if (items > 0) {
                strongSelf->page++;
            }
            NSArray* resultArray = [FirmURLModel getFirmArrayFromResponse:items];
            if (strongSelf->isAppending) {
                _searchResultArray = [[_searchResultArray arrayByAddingObjectsFromArray:resultArray] mutableCopy];
            } else {
                strongSelf.searchResultArray = [resultArray mutableCopy];
            }
            
            [strongSelf filterResult];
        }
        
        strongSelf->isAppending = NO;
        [weakSelf.tableView finishInfiniteScroll];
    }];
    
    NSString* urlString = [NSString stringWithFormat:@"%@%@", THIRD_PARTY_UPLOAD_CATEGORY, _email];
    
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *downloadURL = [NSURL URLWithString:urlString];
    GetJSONOperation *operation = [[GetJSONOperation alloc] initWithCustomURL:downloadURL sessionID:_sessionID
                                                          withCompletionBlock:_requestDataObject.myCompletionBlock params:nil];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![defaults boolForKey:@"isStaff"] && [textField isKindOfClass:[_clientSearchTextField class]]) {
        if (string.length == 0) {
            _filter = @"";
        } else {
            _filter = [textField.text stringByAppendingString:string];
        }
        [self filterClientFolder];
        [self.tableView reloadData];
    }
    
    return YES;
}

- (void) filterClientFolder {
    NSMutableArray* temp = [NSMutableArray new];
    if (_filter.length == 0) {
        temp = _searchResultArray;
    } else {
        for (FirmURLModel *model in _searchResultArray) {
            if ([model.name localizedStandardContainsString:_filter.lowercaseString] || [model.city localizedStandardContainsString:_filter.lowercaseString]) {
                [temp addObject:model];
            }
        }
    }
    
    _filteredArray = [temp mutableCopy];
}

- (void) filterStaffFolder {
    NSMutableArray* temp = [NSMutableArray new];
    for (SearchResultModel* model in _searchResultArray) {
        NSUInteger cellType = [self detectItemType:model.form];
        if  (selectedIndex == 0 && (cellType == DIContactCell || cellType == DIRelatedMatterCell)) {
            [temp addObject:model];
        } else if (cellType == DIContactCell && selectedIndex == 2 ) { // Contact
            [temp addObject:model];
        } else if (cellType == DIRelatedMatterCell && selectedIndex == 1) { // File
            [temp addObject:model];
        }
    }
    
    if (selectedIndex == 3) {
        temp = [NSMutableArray new];
        [self didTapTransitFolder:nil];
    }
    
    _filteredArray = [temp mutableCopy];
}

- (void) filterResult {
    _sendBtn.enabled = NO;
    
    if ([defaults boolForKey:@"isStaff"]) {
        [self filterStaffFolder];
    } else {
        [self filterClientFolder];
    }
   
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
    
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    _requestDataObject = [RequestObject new];
    [_requestDataObject setIncompleteString:@""];
    __weak typeof(self) weakSelf = self;
    [_requestDataObject setMyCompletionBlock:^(NSArray *items, NSInteger statusCode) {
         __strong typeof(self) strongSelf = weakSelf;
        strongSelf->isLoading = NO;
        if (statusCode == 410) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [ShareHelper showAlertWithMessage:@"Session is expired. Please log in again." actionSuccess:NO inViewController:weakSelf];
            });
        } else {
           
            if (items > 0) {
                strongSelf->page++;
            }
            NSArray* resultArray = [SearchResultModel getSearchResultArrayFromResponse:items];
            if (strongSelf->isAppending) {
                _searchResultArray = [[_searchResultArray arrayByAddingObjectsFromArray:resultArray] mutableCopy];
            } else {
                strongSelf.searchResultArray = [resultArray mutableCopy];
            }
            
            [strongSelf filterResult];
        }
        
        strongSelf->isAppending = NO;
        [weakSelf.tableView finishInfiniteScroll];
    }];
    
    NSString* urlString = [NSString stringWithFormat:@"%@%@&category=%ld&page=%ld", searchURL, keyword, (long)category, (long)page];
    if ([searchType isEqualToString:@"Normal"]) { // Direct Tap on the search button
        urlString = [urlString stringByAppendingString:@"&isAutoComplete=1"];
    }
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *downloadURL = [NSURL URLWithString:urlString];
    GetJSONOperation *operation = [[GetJSONOperation alloc] initWithCustomURL:downloadURL
                                                          withCompletionBlock:_requestDataObject.myCompletionBlock];
    [[NSOperationQueue mainQueue] addOperation:operation];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    page = 1;
    if ([defaults boolForKey:@"isStaff"] && [textField isKindOfClass:[_clientSearchTextField class]]) {
        [self.clientSearchTextField resignFirstResponder];
        [self getBranch];
    } else {
        keyword = self.searchTextField.text;
        [self.searchTextField resignFirstResponder];
        searchType = @"Special";
        selectedIndexPaths = [NSMutableArray new];
        [self displaySearchResult];
    }
    
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
    NSString *sectionName = @"";
    if ([defaults boolForKey:@"isStaff"] ) {
        SearchResultModel* model = self.filteredArray[section];
        NSUInteger cellType = [self detectItemType:model.form];
        if (cellType == DIContactCell) { // Contact
            sectionName = @"Contact";
        } else if (cellType == DIRelatedMatterCell){ // Related Matter
            sectionName = @"Matter";
        }
    }
    
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([defaults boolForKey:@"isStaff"] ) {
        return 30;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:[FileSearchCell cellIdentifier] forIndexPath:indexPath];
    if ([defaults boolForKey:@"isStaff"] ) {
        SearchResultModel* model = self.filteredArray[indexPath.section];
        [cell configureCell:model];
    } else {
        FirmURLModel* model = self.filteredArray[indexPath.section];
        [cell configureCellWithFirm:model];
    }
    
    if ([selectedIndexPaths containsObject:indexPath]) {
        [cell setChecked:YES];
    } else {
        [cell setChecked:NO];
    }
    return cell;
}

- (void) addIndexPath:(NSIndexPath *)indexPath checked:(BOOL) isChecked{
//    if ([selectedIndexPaths containsObject:indexPath]) {
//        [selectedIndexPaths removeObject:indexPath];
//    } else {
//        [selectedIndexPaths addObject:indexPath];
//    }
    selectedIndexPaths = [NSMutableArray new];
    if (!isChecked) {
        [selectedIndexPaths addObject:indexPath];
    }
   
    [self.tableView reloadData];
    BOOL sendBtnEnabled = NO;
    if (selectedIndexPaths.count > 0) {
        sendBtnEnabled = YES;
    }
    self.sendBtn.enabled = sendBtnEnabled;
}

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FileSearchCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL isChecked = cell.checked;
    [cell setChecked:!isChecked];
    [self addIndexPath:indexPath checked:isChecked];
    
    if ([defaults boolForKey:@"isStaff"] ) {
        SearchResultModel* model = self.filteredArray[indexPath.section];
        NSUInteger cellType = [self detectItemType:model.form];
        if (cellType == DIContactCell) {
            self.url = [[defaults valueForKey:@"api"] stringByAppendingString:MATTER_STAFF_CONTACT_FOLDER];
            
        } else {
            fileFolderTitle = @"File Folder";
            self.url = [[defaults valueForKey:@"api"] stringByAppendingString:MATTER_STAFF_FILEFOLDER];
        }
        fileNo1 = model.key;
    } else {
        FirmURLModel* model = self.filteredArray[indexPath.section];
        fileNo1 = model.theCode;
        self.url = [model.firmServerURL stringByAppendingString:  MATTER_CLIENT_FILEFOLDER];
    }

//    [self openDocument:url];
}

- (void) openDocument: url
{
    if (isLoading) return;
    isLoading = YES;
    
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    _requestDataObject = [RequestObject new];
    [_requestDataObject setIncompleteString:@""];
    __weak typeof(self) weakSelf = self;
    [_requestDataObject setMyCompletionBlock:^(NSArray *items, NSInteger statusCode) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf->isLoading = NO;
        if (statusCode == 410) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [ShareHelper showAlertWithMessage:@"Session is expired. Please log in again." actionSuccess:NO inViewController:weakSelf];
            });
        } else {
            DocumentModel* documentModel = [DocumentModel getDocumentFromResponse:(NSDictionary*)items];
            [strongSelf performSegueWithIdentifier:@"DocumentSearchSegue" sender:documentModel];
        }
    }];
    
    NSString* urlString = [NSString stringWithFormat:@"%@%@&category=%ld&page=%ld", searchURL, keyword, (long)category, page];
    if ([searchType isEqualToString:@"Normal"]) { // Direct Tap on the search button
        urlString = [urlString stringByAppendingString:@"&isAutoComplete=1"];
    }
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *downloadURL = [NSURL URLWithString:urlString];
    GetJSONOperation *operation = [[GetJSONOperation alloc] initWithCustomURL:downloadURL
                                                          withCompletionBlock:_requestDataObject.myCompletionBlock];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


#pragma mark - MLPAutoCompleteTextField DataSource


//example of asynchronous fetch:
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    self.requestDataObject = [RequestObject new];
    [self.requestDataObject setIncompleteString:[string urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    [self.requestDataObject setCompletionBlock:handler];
     NSString* url = [searchKeywordURL stringByAppendingString:[string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    NSURL *downloadURL = [NSURL URLWithString:url];
    GetJSONOperation *operation = [[GetJSONOperation alloc] initWithDownloadURL:downloadURL
                                                            withCompletionBlock:self.requestDataObject.completionBlock];
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
        page = 1;
        selectedIndexPaths = [NSMutableArray new];
        [self displaySearchResult];
    }
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view will be removed from the view hierarchy");
    // searchcontainer constraint
    self.searchContainerConstraint.constant = 44 ;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view will be added to the view hierarchy");
    // searchcontainer constraint
    self.searchContainerConstraint.constant = 165;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view ws removed from the view hierarchy");
    // [self.searchTextField resignFirstResponder];
    
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view was added to the view hierarchy");
}

- (void)showAlertWithMessage:(NSString *)message withTitle:(NSString*)title actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController withCallback:(void (^)(void))completion {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull __unused action) {
        if (completion != nil) {
            completion();
        }
    }]];
    [alertController.view layoutIfNeeded];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"DocumentSearchSegue"]){
//        DocumentViewController* documentVC = segue.destinationViewController;
//        documentVC.title = fileFolderTitle;
//        documentVC.documentModel = sender;
//        documentVC.custom = @"custom";
//        documentVC.updateHandler = _updateHandler;
    }
}

- (IBAction)topSegment:(id)sender {
}
@end
