//
//  ContactListViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 29/08/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ContactListViewController.h"
#import "StaffModel.h"
#import "ClientModel.h"
//#import "PropertyContactCell.h"
//#import "SecondContactCell.h"

@interface ContactListViewController ()<UISearchBarDelegate, UISearchControllerDelegate,UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate, NSURLSessionDataDelegate>
{
    NSURLSession* mySession;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString* filter;
@property (strong, nonatomic) NSArray<StaffModel*>* listOfContact;
@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerNib];
    [self prepareUI];
    [self getList];
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
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

+ (NSURLSession *)dataSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"group.denningshare.extension"];
        configuration.sharedContainerIdentifier = @"group.denningshare.extension";
        session = [NSURLSession sessionWithConfiguration:configuration];
    });
    return session;
}

- (void) getList{
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.denningshare.extension"];
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[(NSString*)[defaults valueForKey:@"api"] stringByAppendingString:self.url]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"GET"];
    // This is how we set header fields
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[defaults valueForKey:@"sessionID"]  forHTTPHeaderField:@"webuser-sessionid"];
    [request setValue:[defaults valueForKey:@"email"] forHTTPHeaderField:@"webuser-id"];

    NSURLSession *session = [self configureMySession];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSURLSessionDataTask *task = [session
                                      dataTaskWithRequest: request];
        [task resume];
    });
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

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    NSError *errorJson=nil;
    _listOfContact = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorJson];
    [self.tableView reloadData];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler{
    NSLog(@"%s",__func__);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    NSLog(@"%s",__func__);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _listOfContact.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    PropertyContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[PropertyContactCell cellIdentifier]];
//    return cell;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StaffModel *model = self.listOfContact[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
//    UILabel* firstValue = (UILabel*)[cell viewWithTag:1];
//    UILabel* secondValue = (UILabel*)[cell viewWithTag:2];
//    firstValue.text = model.name;
//    secondValue.text = model.IDNo;
    
    cell.textLabel.text = model.name;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.updateHandler(_listOfContact[indexPath.row]);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
