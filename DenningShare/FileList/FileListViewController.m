//
//  FileListViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileListViewController.h"
#import "SearchResultModel.h"

@interface FileListViewController ()<UISearchBarDelegate, UISearchControllerDelegate,UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate, NSURLSessionDataDelegate>
{
    NSURLSession* mySession;
    NSMutableData *receivedData;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString* filter;
@property (strong, nonatomic) NSArray* listOfFile;
@end

@implementation FileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerNib];
    [self prepareUI];
    [self getList];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [mySession invalidateAndCancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerNib {
    //    [PropertyContactCell registerForReuseInTableView:self.tableView];
    //    [SecondContactCell registerForReuseInTableView:self.tableView];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) prepareUI {
    _filter = @"";
    receivedData = [NSMutableData new];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

- (void) getList{
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.denningshare.extension"];
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[(NSString*)[defaults valueForKey:@"api"] stringByAppendingString:[self.url stringByAppendingString:_filter]]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"GET"];
    // This is how we set header fields
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[defaults valueForKey:@"sessionID"]  forHTTPHeaderField:@"webuser-sessionid"];
    [request setValue:[defaults valueForKey:@"email"] forHTTPHeaderField:@"webuser-id"];
    
    NSURLSessionDataTask *task = [[self  configureMySession]
                                  dataTaskWithRequest: request];
    [task resume];
}

- (NSURLSession *) configureMySession {
    if (!mySession) {
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"group.denningshare.extension"];
        // To access the shared container you set up, use the sharedContainerIdentifier property on your configuration object.
        config.sharedContainerIdentifier = @"group.denningshare.extension";
        mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return mySession;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler
{
    receivedData = [NSMutableData new];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    [receivedData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSError *errorJson=nil;
    _listOfFile = [SearchResultModel getSearchResultArrayFromResponse: [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&errorJson]];
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        [self.tableView reloadData];
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler{
    NSLog(@"%s",__func__);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _listOfFile.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    PropertyContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[PropertyContactCell cellIdentifier]];
//    return cell;
//}


- (NSArray*) separateNameIntoTwo:(NSString*) title
{
    NSMutableArray *items = [[title componentsSeparatedByString:@"("] mutableCopy];
    if ([items count] > 1) {
        items[1] = [items[1] substringToIndex:((NSString*)items[1]).length-1];
    } else {
        [items addObject:@""];
    }
    
    
    return items;
}

- (NSString*) getDateInShortForm: (NSString*) date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[[NSTimeZone localTimeZone] secondsFromGMT]/3600];
    [formatter setTimeZone:timeZone];
    
    NSDate *creationDate = [formatter dateFromString:date];
    [newFormatter setTimeZone:timeZone];
    [newFormatter setDateFormat:@"d MMM yyyy"];
    
    return [newFormatter stringFromDate:creationDate];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultModel *model = self.listOfFile[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    UILabel* firstValue = (UILabel*)[cell viewWithTag:1];
    UILabel* secondValue = (UILabel*)[cell viewWithTag:2];
    UILabel* thirdValue = (UILabel*)[cell viewWithTag:3];
    firstValue.text = model.key;
    if ([model.title containsString:@"File No."]) {
        thirdValue.text = [self separateNameIntoTwo:[model.title substringFromIndex:10]][1];
    } else {
        thirdValue.text = [self separateNameIntoTwo:model.title][1];
    }
    
    secondValue.text = [self getDateInShortForm:model.sortDate];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.updateHandler(_listOfFile[indexPath.row]);
    [self.navigationController popViewControllerAnimated:YES];
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
    
    [self getList];
    [_searchBar resignFirstResponder];
}

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    self.filter = @"";
    searchController.searchBar.text = @"";
    
    [self getList];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    self.filter = searchText;
    [self getList];
}

@end
