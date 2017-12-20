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
    
    CGPoint originalContentOffset;
    CGRect originalFrame;
    
    __block BOOL isLoading;
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


- (void)keyboardWillShow:(NSNotification *)notification{
    NSValue* keyboardFrameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    
    CGFloat tableViewHeight = CGRectGetMinY(keyboardFrame) - CGRectGetMinY(self.view.bounds);
    
    originalContentOffset = _tableView.contentOffset;
    originalFrame = _tableView.frame;
    
    // Get the duration of the animation.
    NSValue* animationDurationValue = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:self.textFieldIndexPath];
    CGFloat minCellOffsetY = CGRectGetMaxY(cellRect) - tableViewHeight + 10.0; // Add a small margin below the row
    CGFloat maxCellOffsetY = CGRectGetMinY(cellRect) - 10.0; // Add a small margin above the row
    maxCellOffsetY = MAX(0.0, maxCellOffsetY);
    CGFloat maxContentOffsetY = self.tableView.contentSize.height - tableViewHeight;
    CGFloat scrollOffsetY = self.tableView.contentOffset.y;
    if (scrollOffsetY < minCellOffsetY)
    {
        scrollOffsetY = minCellOffsetY;
    }
    else if (scrollOffsetY > maxCellOffsetY)
    {
        scrollOffsetY = maxCellOffsetY;
    }
    scrollOffsetY = MIN(scrollOffsetY, maxContentOffsetY) + kDefaultAccordionHeaderViewHeight;
    CGPoint updatedContentOffset = CGPointMake(self.tableView.contentOffset.x, scrollOffsetY);
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.tableView.contentOffset = updatedContentOffset;
                     }
                     completion:^(BOOL finished) {
                         self.tableView.frame = CGRectMake(CGRectGetMinX(self.tableView.frame), CGRectGetMinY(self.tableView.frame),
                                                           CGRectGetWidth(self.tableView.frame), tableViewHeight);
                     }];
}

- (void)keyboardWillHide:(NSNotification *) __unused notification{
    // Get the duration of the animation.
    NSValue *animationDurationValue = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                     }
                     completion:^(BOOL finished) {
                         self.tableView.frame = originalFrame;
                         self.tableView.contentOffset = originalContentOffset;
                         [self.tableView layoutIfNeeded];
                     }
     ];
}

- (BOOL) isApproved {
    return [_model.clsLeaveStatus.descriptionValue.localizedLowercaseString isEqualToString:@"approved"];
}

- (BOOL) isRejected {
    return [_model.clsLeaveStatus.descriptionValue.localizedLowercaseString isEqualToString:@"rejected"];
}

- (void) updateBelowInfo {
    status = _model.clsLeaveStatus.descriptionValue;
    statusCode = _model.clsLeaveStatus.codeValue;
    reason = _model.strManagerRemarks;
    dateApproved = [DIHelpers getDateInShortForm:[DIHelpers todayWithTime]];
    approvedBy = _model.clsApprovedBy.strName;
    approvedByCode = _model.clsApprovedBy.attendanceCode;
    typeOfLeaveApproved = _model.clsLeaveStatus.descriptionValue;
    typeOfLeaveApprovedCode = _model.clsLeaveStatus.codeValue;
}

- (void) prepareUI {
    startDate = [DIHelpers getDateInShortForm:_model.dtStartDate];
    endDate = [DIHelpers getDateInShortForm:_model.dtEndDate];
    typeOfLeave = _model.clsTypeOfLeave.descriptionValue;
    typeOfLeaveCode = _model.clsTypeOfLeave.codeValue;
    staffRemarks = _model.strStaffRemarks;
    noOfDays = _model.decLeaveLength;
    _staffName.text = _submittedBy;
    
    [self updateBelowInfo];
    
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

- (NSDictionary*) buildParams:(NSString*) leaveStatusCode {
    NSMutableDictionary* params = [NSMutableDictionary new] ;
    
    [params addEntriesFromDictionary:@{@"clsLeaveStatus":@{@"code":leaveStatusCode}}];
    [params addEntriesFromDictionary:@{@"code":_model.codeValue}];

    return [params copy];
}

- (void) reject {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reject" message:@"Please input the reason to reject." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSMutableDictionary* params = [[self buildParams:@"2"] mutableCopy];
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
            _model = [StaffLeaveModel getStaffLeaveFromResponse:result];
            [self updateBelowInfo];
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
        if  ([self isApproved]) {
            if (indexPath.row == 3) {
              return  [self configureActionCellWithApprovalTitle:@"Approved" approvalState:NO rejectTitle:@"Reject" rejectState:NO inTableView:tableView inIndexPath:indexPath];
            }
        } else if  ([self isRejected]) {
            if (indexPath.row == 4) {
              return  [self configureActionCellWithApprovalTitle:@"Approve" approvalState:NO rejectTitle:@"Rejected" rejectState:NO inTableView:tableView inIndexPath:indexPath];
            }
        } else {
            if (indexPath.row == 0) {
             return   [self configureActionCellWithApprovalTitle:@"Approve" approvalState:YES rejectTitle:@"Reject" rejectState:YES inTableView:tableView inIndexPath:indexPath];
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
            cell.floatingTextField.userInteractionEnabled = YES;
        } else if (indexPath.row == 4)  { // Staff Remarks
            cell.floatingTextField.userInteractionEnabled = YES;
            cell.floatingTextField.text = staffRemarks;
        } else if (indexPath.row == 5)  { // Submitted By
            cell.floatingTextField.text = _submittedBy;
            cell.delegate = nil;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.floatingTextField.userInteractionEnabled = NO;
        
        if  ([self isApproved]) {
            if (indexPath.row == 0) {
                cell.floatingTextField.text = status;
            } else if (indexPath.row == 1) {
                cell.floatingTextField.text = approvedBy;
                cell.floatingTextField.placeholder = @"Approved By";
            } else if (indexPath.row == 2) {
                cell.floatingTextField.placeholder = @"Date Approved";
                cell.floatingTextField.text = dateApproved;
            }
        } else if ([self isRejected]) {
            if (indexPath.row == 0) {
                cell.floatingTextField.text = status;
            } else if (indexPath.row == 1) {
                cell.floatingTextField.text = reason;
            } else if (indexPath.row == 2) {
                cell.floatingTextField.text = approvedBy;
            } else if (indexPath.row == 3) {
                cell.floatingTextField.text = dateApproved;
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
    
    if ([self isApproved]) {
        return _listOfValsForApp[section].count - 1;
    } else if ([self isRejected]) {
        return _listOfValsForApp[section].count;
    }
    
    return 1;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    NSInteger section = textField.tag / 10;
    NSInteger row = textField.tag - section*10;
    _textFieldIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return YES;
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
            [self.tableView reloadData];
        };
    } else if ([segue.identifier isEqualToString:kLeaveRecordSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        LeaveRecordsViewController *vc = nav.viewControllers.firstObject;
        vc.staffCode = _model.clsStaff.attendanceCode;
    } 
}

@end
