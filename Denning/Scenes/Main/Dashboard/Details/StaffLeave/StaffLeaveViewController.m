//
//  StaffLeaveViewController.m
//  Denning
//
//  Created by Denning IT on 2017-11-23.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "StaffLeaveViewController.h"
#import "LeaveRecordCell.h"
#import "LeaveRecordHeaderCell.h"

@interface StaffLeaveViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSInteger selectedPage;
    __block Boolean isLoading, isAppending;
    NSString* baseUrl, *curFilterURL;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listOfPendingApprovals, *listOfApprovalRecords;
@property (strong, nonatomic) NSNumber* page;

@end

@implementation StaffLeaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNibs];
    [self parseURL];
    [self loadTableData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) registerNibs {
    [LeaveRecordCell registerForReuseInTableView:self.tableView];
    [LeaveRecordHeaderCell registerForReuseInTableView:self.tableView];
}

- (void) prepareUI {
    _page = @(1);
    selectedPage = 0;
    _listOfPendingApprovals = _listOfApprovalRecords = [NSMutableArray new];
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
    self.tableView.infiniteScrollTriggerOffset = 150;
    
    // Add infinite scroll handler
    @weakify(self)
    [self.tableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        @strongify(self)
        [self appendList];
    }];
    
    // Tying up the segmented control to a scroll view
    HMSegmentedControl *selectionList = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 86, self.view.frame.size.width, 34)];
    selectionList.sectionTitles = @[@"Leave Application", @"Leave Record"];
    selectionList.selectedSegmentIndex = 0;
    selectionList.backgroundColor = [UIColor blackColor];
    selectionList.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    selectionList.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"SFUIText-Regular" size:17]};
    selectionList.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"FF3B2F"], NSFontAttributeName: [UIFont fontWithName:@"SFUIText-SemiBold" size:17]};
    selectionList.selectionIndicatorColor = [UIColor colorWithHexString:@"FF3B2F"];
    selectionList.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    [selectionList addTarget:self action:@selector(topFilterChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:selectionList];
}

- (void) parseURL {
    NSRange range =  [_url rangeOfString:@"=" options:NSBackwardsSearch];
    baseUrl = [_url substringToIndex:range.location+1];
    curFilterURL = [_url substringFromIndex:range.location+1];
}

- (void) appendList {
    isAppending = YES;
    [self loadTableData];
}

- (void) loadTableData {
    _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, baseUrl, curFilterURL, _page];
    
    if (isLoading) return;
    isLoading = NO;
    [SVProgressHUD show];
    @weakify(self)
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        [SVProgressHUD dismiss];
        @strongify(self)
        self->isLoading = NO;
        self->isAppending = NO;
        if  (error == nil) {
            NSArray* array = [LeaveRecordModel getLEaveRecordArrayFromResponse:(NSArray*)result];
            if (array.count > 0) {
                _page = [NSNumber numberWithInteger:([_page integerValue] + 1)];
            }
            if (isAppending) {
                _listOfPendingApprovals = [[_listOfPendingApprovals arrayByAddingObjectsFromArray:array] mutableCopy];
            } else {
                _listOfPendingApprovals = [array mutableCopy];
            }
            
            [self.tableView reloadData];
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LeaveRecordHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[LeaveRecordHeaderCell cellIdentifier]];
    
    return cell;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LeaveRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:[LeaveRecordCell cellIdentifier] forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.tag = indexPath.section;
    [cell configureCellWithModel:_listOfPendingApprovals[indexPath.row]];
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (selectedPage == 0) {
        return _listOfPendingApprovals.count;
    }
    return _listOfApprovalRecords.count;
}

- (void) topFilterChanged: (HMSegmentedControl*) control {
    selectedPage = control.selectedSegmentIndex;
    if (selectedPage == 0) {
        [self.tableView reloadData];
    } else {
        _page = @(1);
        [self loadTableData];
    }
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
