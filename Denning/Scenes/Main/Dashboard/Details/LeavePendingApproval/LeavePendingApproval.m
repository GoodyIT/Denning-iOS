//
//  LeavePendingApproval.m
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LeavePendingApproval.h"
#import "FloatingTextCell.h"
#import "AddLastOneButtonCell.h"
#import "DateTimeViewController.h"
#import "ListWithCodeTableViewController.h"
#import "ListWithDescriptionViewController.h"
#import "LeaveRecordsViewController.h"
#import "DashboardContact.h"

enum SECTIONS {
    APPLICATION_DETAILS_SECTION,
    APPROVAL_DETAILS_SECTION
};

@interface LeavePendingApproval ()<UITableViewDataSource, UITableViewDelegate, ContactListWithCodeSelectionDelegate, SWTableViewCellDelegate, UITextFieldDelegate>
{
    NSString *startDate, *endDate;
    NSString* typeOfLeaveCode, *typeOfLeave;
    NSString* noOfDaysCode, *noOfDays;
    NSString* staffRemarks;
    NSString* status, *statusCode;
    NSString* reason;
    NSString* approvedBy, *approvedByCode;
    NSString* dateApproved;
    NSString* typeOfLeaveApproved, *typeOfLeaveApprovedCode;
    
    NSInteger selectedRow;
    
    NSString* titleOfList;
    NSString* nameOfField;
    
    __block BOOL isLoading;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<NSArray*> *listOfValsForApp;
@property (nonatomic, strong) NSArray *headers;
@property (strong, nonatomic) NSNumber* page;
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
    [AddLastOneButtonCell registerForReuseInTableView:self.tableView];
    [FloatingTextCell registerForReuseInTableView:self.tableView];
    
    [self.tableView reloadData];
}

- (void) prepareUI {
    startDate = [DIHelpers getDateInShortForm:_model.dtStartDate];
    endDate = [DIHelpers getDateInShortForm:_model.dtEndDate];
    typeOfLeaveApproved = typeOfLeave = _model.clsTypeOfLeave.descriptionValue;
    typeOfLeaveApprovedCode = typeOfLeaveCode = _model.clsTypeOfLeave.codeValue;
    staffRemarks = _model.strStaffRemarks;
    noOfDays = _model.strLeaveLength.descriptionValue;
    noOfDaysCode = _model.strLeaveLength.codeValue;
    status = _model.clsLeaveStatus.descriptionValue;
    statusCode = _model.clsLeaveStatus.codeValue;
    reason = _model.strManagerRemarks;
    dateApproved = [DIHelpers getDateInShortForm:[DIHelpers todayWithTime]];
    approvedBy = _model.clsApprovedBy.strName;
    approvedByCode = _model.clsApprovedBy.attendanceCode;
    
    _listOfValsForApp = @[@[@"Start Date", @"End Date", @"Type Of Leave", @"No. of Days", @"Staff Remarks", @"Submitted By"], @[@"Status", @"Reason", @"Approved By", @"Date Approved", @"Type of Leave Approved", @"Submit"]];
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

- (void) showCalendar {
    [self.view endEditing:YES];
    
    DateTimeViewController *calendarViewController = [[UIStoryboard storyboardWithName:@"AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"DateTimeViewController"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        if (selectedRow == 0) {
            startDate = date;
        } else {
            endDate =date;
        }
        [self.tableView reloadData];
    };
    [self showPopup:calendarViewController];
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

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    UIFont *font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    NSAttributedString* clearString = [[NSAttributedString alloc] initWithString:@"Clear" attributes:attributes];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] attributedTitle:clearString];
    
    return leftUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    [cell hideUtilityButtonsAnimated:YES];
    if  (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                startDate = @"";
                break;
            case 1:
                endDate = @"";
                break;
            case 2:
                typeOfLeave = @"";
                typeOfLeaveCode = @"";
                break;
            case 3:
                noOfDays = @"";
                break;
            case 4:
                staffRemarks = @"";
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
                status = statusCode = @"";
                break;
            case 1:
                reason = @"";
                break;
            case 2:
                approvedBy =approvedByCode = @"";
                break;
            case 4:
                typeOfLeaveApproved = typeOfLeaveApprovedCode = @"";
                break;
            default:
                break;
        }
    }
}

- (NSDictionary*) buildParams {
    NSMutableDictionary* params = [NSMutableDictionary new] ;
    
    [params addEntriesFromDictionary:@{@"clsLeaveStatus":@{@"code":statusCode}}];
    [params addEntriesFromDictionary:@{@"code":_submittedByCode}];
    [params addEntriesFromDictionary:@{@"clsTypeOfLeave":@{@"code":typeOfLeaveApprovedCode}}];
    [params addEntriesFromDictionary:@{@"dtDateApproved":[DIHelpers convertDateToMySQLFormat:dateApproved]}];
    [params addEntriesFromDictionary:@{@"strLeaveLength":noOfDaysCode}];
    [params addEntriesFromDictionary:@{@"strManagerRemarks":reason}];
    
    return [params copy];
}

- (void) save {
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:STAFF_LEAVE_SAVE_URL];
    if (isLoading) return;
    isLoading = YES;
    [SVProgressHUD showWithStatus:@"Saving"];
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivatePutWithURL:url params:[self buildParams] completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [SVProgressHUD showSuccessWithStatus:@"Successfully saved"];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Fail to Save"];
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 5) {
        AddLastOneButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastOneButtonCell cellIdentifier] forIndexPath:indexPath];
        [cell.calculateBtn setTitle:@"Submit" forState:UIControlStateNormal];
        cell.calculateHandler = ^ {
            [self save];
        };
        
        return cell;
    }
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    
    FloatingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[FloatingTextCell cellIdentifier] forIndexPath:indexPath];
    cell.floatingTextField.tag = indexPath.row;
    cell.floatingTextField.userInteractionEnabled = NO;
    
    cell.floatingTextField.floatLabelActiveColor = cell.floatingTextField.floatLabelPassiveColor = [UIColor redColor];
    cell.floatingTextField.placeholder = _listOfValsForApp[indexPath.section][indexPath.row];
    cell.floatingTextField.inputAccessoryView = accessoryView;
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    cell.floatingTextField.delegate = self;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) { // Start Date
            cell.floatingTextField.text = startDate;
        } else if (indexPath.row == 1) { // End date
            cell.floatingTextField.text = endDate;
        } else if (indexPath.row == 2)  { // Type Of Leave
            cell.floatingTextField.text = typeOfLeave;
        } else if (indexPath.row == 3)  { // No Of Days
            cell.floatingTextField.text = noOfDays;
        } else if (indexPath.row == 4)  { // Staff Remarks
            cell.floatingTextField.userInteractionEnabled = YES;
            cell.floatingTextField.text = staffRemarks;
        } else if (indexPath.row == 5)  { // Submitted By
            cell.floatingTextField.text = _submittedBy;
            cell.delegate = nil;
        }
    } else {
        if (indexPath.row == 0) {
            cell.floatingTextField.text = status;
        } else if (indexPath.row == 1) {
            cell.floatingTextField.text = reason;
            cell.floatingTextField.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 2) {
            cell.floatingTextField.text = approvedBy;
        } else if (indexPath.row == 3) {
            cell.floatingTextField.text = dateApproved;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 4) {
            cell.floatingTextField.text = typeOfLeaveApproved;
        }
    }
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedRow = indexPath.row;
    if (indexPath.section == 0) {
        
    } else {
        if (selectedRow == 0) {
            titleOfList = @"Leave Status";
            nameOfField = @"Leave Status";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:LEAVE_TYPE_GET_URL];
        } else if (selectedRow == 2) {
            [self performSegueWithIdentifier:kContactGetListSegue sender:GENERAL_CONTACT_URL];
        } else if (selectedRow == 4) {
            titleOfList = @"Leave Type Approved";
            nameOfField = @"Leave Type Approved";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:LEAVE_TYPE_GET_URL];
        }
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if  (section == 0) {
        return _listOfValsForApp[section].count;
    }
    
    return _listOfValsForApp[section].count;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0) {
        return;
    }
    staffRemarks = textField.text;
}

#pragma mark - ContactListWithCodeSelectionDelegate
- (void) didSelectList:(UIViewController *)listVC name:(NSString*) name withModel:(CodeDescription *)model
{
    if ([name isEqualToString:@"Leave Type"]) {
        typeOfLeaveCode = model.codeValue;
        typeOfLeave = model.descriptionValue;
    } else if ([name isEqualToString:@"No. Of Days"]) {
        noOfDaysCode = model.codeValue;
        noOfDays = model.descriptionValue;
    } else if ([name isEqualToString:@"Leave Type Approved"]) {
        typeOfLeaveApproved = model.descriptionValue;
        typeOfLeaveApprovedCode = model.codeValue;
    } else if ([name isEqualToString:@"Leave Status"]) {
        status = model.descriptionValue;
        statusCode = model.codeValue;
    }
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kListWithCodeSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        ListWithCodeTableViewController *listCodeVC = navVC.viewControllers.firstObject;
        listCodeVC.delegate = self;
        listCodeVC.titleOfList = titleOfList;
        listCodeVC.name = nameOfField;
        listCodeVC.url = sender;
    } else if ([segue.identifier isEqualToString:kContactGetListSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        DashboardContact* vc = nav.viewControllers.firstObject;
        vc.url = sender;
        vc.callback = @"callback";
        vc.updateHandler = ^(SearchResultModel *model) {
            approvedBy = [model.JsonDesc objectForKey:@"name"];
            approvedByCode = [model.JsonDesc objectForKey:@"code"];
        };
    } else if ([segue.identifier isEqualToString:kLeaveRecordSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        LeaveRecordsViewController *vc = nav.viewControllers.firstObject;
        vc.staffCode = _model.clsStaff.attendanceCode;
    }
}

@end
