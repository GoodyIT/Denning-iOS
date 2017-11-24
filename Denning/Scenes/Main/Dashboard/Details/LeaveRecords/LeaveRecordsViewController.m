//
//  LeavePendingApproval.m
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LeaveRecordsViewController.h"
#import "LeaveRecordCell.h"
#import "LeaveRecordHeaderCell.h"


@interface LeaveRecordsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    __block Boolean isLoading, isAppending;
    NSString* baseUrl, *curFilterURL;
    
}

//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* listOfLeaveRecords;
@property (strong, nonatomic) NSNumber* page;
@end

@implementation LeaveRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNibs];
    [self loadLeaveRecords];
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
    _listOfLeaveRecords = [NSMutableArray new];
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
}

- (void) appendList {
    isAppending = YES;
    [self loadLeaveRecords];
}

- (void) loadLeaveRecords {
    if (isLoading) return;
    isLoading = NO;
    NSString *url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, LEAVE_RECORD_GET_URL, _staffCode, _page];
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        [SVProgressHUD dismiss];
        @strongify(self)
        self->isLoading = NO;
        
        [self.tableView finishInfiniteScroll];
        if  (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
            NSArray* array = [LeaveRecordModel getLEaveRecordArrayFromResponse:(NSArray*)result];
            if (array.count > 0) {
                _page = [NSNumber numberWithInteger:([_page integerValue] + 1)];
            }
            if (isAppending) {
                _listOfLeaveRecords = [[_listOfLeaveRecords arrayByAddingObjectsFromArray:array] mutableCopy];
            } else {
                _listOfLeaveRecords = [array mutableCopy];
            }
            
            [self.tableView reloadData];
            
        } else {
           [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
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
    [cell configureCellWithModel:_listOfLeaveRecords[indexPath.row]];
    
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
    return _listOfLeaveRecords.count;
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
