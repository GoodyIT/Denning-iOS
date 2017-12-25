//
//  StaffLeaveViewController.m
//  Denning
//
//  Created by Denning IT on 2017-11-23.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "StaffLeaveViewController.h"
#import "ApprovalRecordCell.h"
#import "LeaveRecordHeaderCell.h"
#import "PendingApprovalCell.h"
#import "PendingApprovalHeaderCell.h"
#import "LeavePendingApproval.h"
#import "DashboardContact.h"

@interface StaffLeaveViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSInteger selectedPage;
    __block Boolean isLoading, isAppending;
    NSString* baseUrl;
    NSArray* curFilterURL;
    AttendanceInfo* clsStaff;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<LeaveRecordModel*>* listOfData;
@property (strong, nonatomic) NSNumber* page;

@end

@implementation StaffLeaveViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view.
     _page = @(1);
    [self loadTableData];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self registerNibs];
    [self parseURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) registerNibs {
    [ApprovalRecordCell registerForReuseInTableView:self.tableView];
    [LeaveRecordHeaderCell registerForReuseInTableView:self.tableView];
    [PendingApprovalCell registerForReuseInTableView:self.tableView];
    [PendingApprovalHeaderCell registerForReuseInTableView:self.tableView];
}

- (void) prepareUI {
    _page = @(1);
    selectedPage = 0;
    _listOfData = [NSMutableArray new];
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
    HMSegmentedControl *selectionList = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, 34)];
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
    curFilterURL = @[@"pending", @"approved"];
}

- (void) appendList {
    isAppending = YES;
    [self loadTableData];
}

- (void) loadTableData {
    _url = [NSString stringWithFormat:@"%@denningwcf/%@%@&page=%@", [DataManager sharedManager].user.serverAPI, baseUrl, curFilterURL[selectedPage], _page];
    
    if (isLoading) return;
    isLoading = NO;
    [SVProgressHUD show];
    @weakify(self)
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        [SVProgressHUD dismiss];
        @strongify(self)
        self->isLoading = NO;
        [self.tableView finishInfiniteScroll];
        if  (error == nil) {
            NSArray* array = [LeaveRecordModel getLEaveRecordArrayFromResponse:(NSArray*)result];
            if (array.count > 0) {
                _page = [NSNumber numberWithInteger:([_page integerValue] + 1)];
            }
            if (isAppending) {
                _listOfData = [[_listOfData arrayByAddingObjectsFromArray:array] mutableCopy];
            } else {
                _listOfData = [array mutableCopy];
            }
            
            [self.tableView reloadData];
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
        self->isAppending = NO;
        
    }];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kDefaultAccordionHeaderViewHeight;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if  (selectedPage == 0) {
        PendingApprovalHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[PendingApprovalHeaderCell cellIdentifier]];
        
        return cell;
    }
    LeaveRecordHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[LeaveRecordHeaderCell cellIdentifier]];
    cell.period.text = @"Staff";
    cell.no.text = @"PYL";
    cell.status.text = @"AL";
    cell.type.text = @"Taken";
    
    return cell;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if  (selectedPage == 0) {
        PendingApprovalCell *cell = [tableView dequeueReusableCellWithIdentifier:[PendingApprovalCell cellIdentifier] forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.tag = indexPath.section;
        [cell configureCell:_listOfData[indexPath.row]];
        
        return cell;
    }
    ApprovalRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:[ApprovalRecordCell cellIdentifier] forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.tag = indexPath.section;
    [cell configureCell:_listOfData[indexPath.row]];
    
    return cell;
}

- (void) gotoLeavePendingApproval:(NSIndexPath *)indexPath {
    clsStaff = _listOfData[indexPath.row].clsStaff;
    
    _url = [NSString stringWithFormat:@"%@denningwcf/v1/table/StaffLeave/%@", [DataManager sharedManager].user.serverAPI, _listOfData[indexPath.row].leaveCode];
    if (isLoading) return;
    isLoading = NO;
    [SVProgressHUD show];
    @weakify(self)
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        [SVProgressHUD dismiss];
        @strongify(self)
        self->isLoading = NO;
        if  (error == nil) {
            [self performSegueWithIdentifier:kLeavePendingApprovalSegue sender:[StaffLeaveModel getStaffLeaveFromResponse:result]];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (selectedPage == 0) {
        [self gotoLeavePendingApproval:indexPath];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listOfData.count;
}

- (void) topFilterChanged: (HMSegmentedControl*) control {
    selectedPage = control.selectedSegmentIndex;
    _page = @(1);
    [self loadTableData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kLeavePendingApprovalSegue]) {
        LeavePendingApproval *vc = segue.destinationViewController;
        vc.submittedBy = clsStaff.strName;
        vc.submittedByCode = clsStaff.attendanceCode;
        vc.fromDashboard = @"dashboard";
        vc.model = sender;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
