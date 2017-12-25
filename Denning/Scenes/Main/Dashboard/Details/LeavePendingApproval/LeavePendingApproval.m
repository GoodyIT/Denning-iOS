//
//  LeavePendingApproval.m
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LeavePendingApproval.h"
#import "FloatingTextCell.h"
#import "TwoButtonsCell.h"
#import "DateTimeViewController.h"
#import "ListWithCodeTableViewController.h"
#import "ListWithDescriptionViewController.h"
#import "LeaveRecordsViewController.h"
#import "DashboardContact.h"

enum SECTIONS {
    APPLICATION_DETAILS_SECTION,
    APPROVAL_DETAILS_SECTION
};

@interface LeavePendingApproval ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSInteger selectedRow;
    
    NSString* titleOfList;
    NSString* nameOfField;
    
    CGPoint originalContentOffset;
    CGRect originalFrame;
    
    __block BOOL isLoading, isActionDone;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<NSArray*> *listOfValsForApp;
@property (weak, nonatomic) IBOutlet UILabel *staffName;
@property (nonatomic, strong) NSArray *headers;
@property (strong, nonatomic) NSNumber* page;

@property (strong, nonatomic) NSIndexPath* textFieldIndexPath;
@end

@implementation LeavePendingApproval

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNibs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotoLeaveRecords:(id)sender {
    [self performSegueWithIdentifier:kLeaveRecordSegue sender:nil];
}

- (IBAction)dismissScreen:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) registerNibs {
    [TwoButtonsCell registerForReuseInTableView:self.tableView];
    [FloatingTextCell registerForReuseInTableView:self.tableView];
    
    [self.tableView reloadData];
}

- (BOOL) isApproved {
    return _model.clsLeaveStatus.codeValue.integerValue == 1;
}

- (BOOL) isRejected {
    return _model.clsLeaveStatus.codeValue.integerValue == 3;
}

- (void) prepareUI {
    _staffName.text = _submittedBy;

    _listOfValsForApp = @[@[@"Start Date", @"End Date", @"Type Of Leave", @"No. of Days", @"Staff Remarks", @"Submitted By"], @[@"Status", @"Reason", @"Approved By", @"Date Approved", @"Approve & Reject"]];
    _headers = @[@"Application Details", @"Approval Details"];
    _page = @(1);
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

- (void) showPopup: (UIViewController*) vc {
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:vc];
    [STPopupNavigationBar appearance].barTintColor = [UIColor blackColor];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.containerView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    popupController.containerView.layer.shadowOffset = CGSizeMake(4, 4);
    popupController.containerView.layer.shadowOpacity = 1;
    popupController.containerView.layer.shadowRadius = 1.0;
    
    [popupController presentInViewController:self];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kDefaultAccordionHeaderViewHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _headers[section];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (NSDictionary*) buildParams:(NSString*) leaveStatusCode {
    NSMutableDictionary* params = [NSMutableDictionary new] ;
    
    [params addEntriesFromDictionary:@{@"clsLeaveStatus":@{@"code":leaveStatusCode}}];
    [params addEntriesFromDictionary:@{@"code":_model.codeValue}];

    return [params copy];
}

- (void) reject {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reject" message:@"Please input the reason to reject." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSMutableDictionary* params = [[self buildParams:@"3"] mutableCopy];
        [params addEntriesFromDictionary:@{@"strManagerRemarks":_model.strStaffRemarks}];
        [self manageApplicationWithParams:[params copy]];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self.tableView reloadData];
    }];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Reason...";
        _model.strStaffRemarks = textField.text;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) approve {
    [self manageApplicationWithParams:[self buildParams:@"1"]];
}

- (void) manageApplicationWithParams:(NSDictionary*) params{
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:STAFF_LEAVE_SAVE_URL];
    if (isLoading) return;
    isLoading = YES;
    [SVProgressHUD showWithStatus:@"Saving"];
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivatePutWithURL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            self->isActionDone = YES;
            _model = [StaffLeaveModel getStaffLeaveFromResponse:result];
            [self.tableView reloadData];
            [SVProgressHUD showSuccessWithStatus:@"Successfully saved"];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Fail to Save"];
        }
    }];
}

- (TwoButtonsCell*) configureActionCellWithApprovalTitle:(NSString*) approvalTitle approvalState:(BOOL) approvalState rejectTitle:(NSString*) rejectTitle rejectState:(BOOL) rejectState inTableView:(UITableView*) tableView inIndexPath:(NSIndexPath*) indexPath{
    TwoButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:[TwoButtonsCell cellIdentifier] forIndexPath:indexPath];
    
    [cell.leftBtn setTitle:approvalTitle forState:UIControlStateNormal];
    cell.leftBtn.enabled = approvalState;
    cell.leftHandler  = ^ { // Approve
        [self approve];
    };
    
    [cell.rightBtn setTitle:rejectTitle forState:UIControlStateNormal];
    cell.rightBtn.enabled = rejectState;
    cell.rightHandler = ^ { // Reject
        [self reject];
    };
    
    return cell;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if  (!isActionDone) {
            if (indexPath.row == 0 && [_fromDashboard isEqualToString:@"dashboard"]) {
                return [self configureActionCellWithApprovalTitle:@"Approve" approvalState:YES rejectTitle:@"Reject" rejectState:YES inTableView:tableView inIndexPath:indexPath];
            }
        }
    }
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    
    FloatingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[FloatingTextCell cellIdentifier] forIndexPath:indexPath];
    cell.floatingTextField.tag = indexPath.section * 10 + indexPath.row;
    cell.floatingTextField.userInteractionEnabled = NO;
    
    cell.floatingTextField.floatLabelActiveColor = cell.floatingTextField.floatLabelPassiveColor = [UIColor redColor];
    cell.floatingTextField.placeholder = _listOfValsForApp[indexPath.section][indexPath.row];
    cell.floatingTextField.inputAccessoryView = accessoryView;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) { // Start Date
            cell.floatingTextField.text = [DIHelpers getDateInShortForm:_model.dtStartDate];
        } else if (indexPath.row == 1) { // End date
            cell.floatingTextField.text = [DIHelpers getDateInShortForm:_model.dtEndDate];
        } else if (indexPath.row == 2)  { // Type Of Leave
            cell.floatingTextField.text = _model.clsTypeOfLeave.descriptionValue;
        } else if (indexPath.row == 3)  { // No Of Days
            cell.floatingTextField.text = _model.decLeaveLength;
        } else if (indexPath.row == 4)  { // Staff Remarks
            cell.floatingTextField.text = _model.strStaffRemarks;
        } else if (indexPath.row == 5)  { // Submitted By
            cell.floatingTextField.text = _submittedBy;
            cell.delegate = nil;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.floatingTextField.userInteractionEnabled = NO;
        if (indexPath.row == 0) {
            cell.floatingTextField.text = _model.clsLeaveStatus.descriptionValue;
        }
        
        if  ([self isApproved]) {
            if (indexPath.row == 1) {
                cell.floatingTextField.text = _model.clsApprovedBy.strName;
                cell.floatingTextField.placeholder = @"Approved By";
            } else if (indexPath.row == 2) {
                cell.floatingTextField.placeholder = @"Date Approved";
                cell.floatingTextField.text = [DIHelpers getDateInShortForm:_model.dtDateApproved];
            }
        } else if ([self isRejected]) {
            if (indexPath.row == 1) {
                cell.floatingTextField.text = _model.strManagerRemarks;
            } else if (indexPath.row == 2) {
                cell.floatingTextField.text = _model.clsApprovedBy.strName;
            } else if (indexPath.row == 3) {
                cell.floatingTextField.text = [DIHelpers getDateInShortForm:_model.dtDateApproved];
            }
        }
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if  (section == 0) {
        return _listOfValsForApp[section].count;
    }
    
    int count = 1;
    
    switch ([_model.clsLeaveStatus.codeValue integerValue]) {
        case 1:
            count = 3;
            break;
        case 3:
            count = 4;
            break;
        default:
            count = 1;
            break;
    }
    
    return count;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kLeaveRecordSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        LeaveRecordsViewController *vc = nav.viewControllers.firstObject;
        vc.staffCode = _model.clsStaff.attendanceCode;
    } 
}

@end
