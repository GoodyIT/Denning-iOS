//
//  LeaveAppViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 15/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LeaveAppViewController.h"
#import "LeaveRecordCell.h"
#import "FloatingTextCell.h"
#import "LeaveRecordHeaderCell.h"
#import "AddLastOneButtonCell.h"
#import "DateTimeViewController.h"
#import "ListWithCodeTableViewController.h"
#import "ListWithDescriptionViewController.h"

@interface LeaveAppViewController ()<UITableViewDataSource, UITableViewDelegate, ContactListWithCodeSelectionDelegate, ContactListWithDescSelectionDelegate, SWTableViewCellDelegate, UITextFieldDelegate>
{
    NSInteger selectedPage;
    NSString *startDate, *endDate;
    NSString* typeOfLeaveCode, *typeOfLeave;
    NSString* noOfDaysCode, *noOfDays;
    NSString* staffRemarks;
    NSString* submittedBy, *submittedByCode;
    
    NSInteger selectedRow;
    
    NSString* titleOfList;
    NSString* nameOfField;
    
    __block Boolean isLoading, isAppending;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listOfValsForApp;
@property (strong, nonatomic) NSMutableArray* listOfLeaveRecords;
@property (strong, nonatomic) NSNumber* page;
@property (weak, nonatomic) IBOutlet UILabel *staffName;

@end

@implementation LeaveAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNibs];
    [self fillUpSubmittedBy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) registerNibs {
    [AddLastOneButtonCell registerForReuseInTableView:self.tableView];
    [LeaveRecordCell registerForReuseInTableView:self.tableView];
    [FloatingTextCell registerForReuseInTableView:self.tableView];
    [LeaveRecordHeaderCell registerForReuseInTableView:self.tableView];
    
    [self.tableView reloadData];
}

- (void) prepareUI {
    _staffName.text = [DataManager sharedManager].user.username;
    _listOfValsForApp = @[@"Start Date", @"End Date", @"Type Of Leave", @"No. of Days", @"Staff Remarks", @"Submitted By"];
    _page = @(1);
    selectedPage = 0;
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

- (void) appendList {
    isAppending = YES;
    [self loadLeaveRecords];
}

- (void) fillUpSubmittedBy {
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:LEAVE_SUBMITTED_BY_URL];
    @weakify(self)
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        @strongify(self)
        if (error == nil) {
            submittedBy = [result valueForKeyNotNull:@"strName"];
            submittedByCode = [result valueForKeyNotNull:@"code"];
            [self.tableView reloadData];
        }
    }];
}

- (void) loadLeaveRecords {
    if (isLoading) return;
    isLoading = NO;
    NSString *url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, LEAVE_RECORD_GET_URL,submittedByCode, _page];
    [SVProgressHUD show];
    @weakify(self)
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
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
                _listOfLeaveRecords = [[_listOfLeaveRecords arrayByAddingObjectsFromArray:array] mutableCopy];
            } else {
                _listOfLeaveRecords = [array mutableCopy];
            }
            
            [self.tableView reloadData];
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (NSDictionary*) buildParams {
    NSMutableDictionary* params = [NSMutableDictionary new] ;
    
    [params addEntriesFromDictionary:@{@"clsLeaveStatus":@{@"code":@"0"}}];
    [params addEntriesFromDictionary:@{@"clsStaff":@{@"code":@"0"}}];
    [params addEntriesFromDictionary:@{@"clsTypeOfLeave":@{@"code":typeOfLeaveCode}}];
    [params addEntriesFromDictionary:@{@"dtEndDate":[DIHelpers convertDateToMySQLFormat:endDate]}];
    [params addEntriesFromDictionary:@{@"dtStartDate":[DIHelpers convertDateToMySQLFormat:startDate]}];
    [params addEntriesFromDictionary:@{@"dtDateSubmitted":[DIHelpers todayWithTime]}];
    [params addEntriesFromDictionary:@{@"strLeaveLength":noOfDaysCode}];
    [params addEntriesFromDictionary:@{@"strStaffRemarks":staffRemarks}];
    
    return [params copy];
}

- (void) saveLeaveApplication {
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (selectedPage == 0) {
        return 0;
    }
    return 33;
//    return 0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LeaveRecordHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[LeaveRecordHeaderCell cellIdentifier]];

    return cell;
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
            noOfDaysCode = @"";
            break;
        case 4:
            staffRemarks = @"";
            break;
        case 5:
            submittedBy = @"";
            break;
            
        default:
            break;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (selectedPage == 0) {
        if (indexPath.row == 6) {
            AddLastOneButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastOneButtonCell cellIdentifier] forIndexPath:indexPath];
            [cell.calculateBtn setTitle:@"Submit" forState:UIControlStateNormal];
            cell.calculateHandler = ^ {
                [self saveLeaveApplication];
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
        cell.floatingTextField.placeholder = _listOfValsForApp[indexPath.row];
        cell.floatingTextField.floatLabelActiveColor = cell.floatingTextField.floatLabelPassiveColor = [UIColor redColor];
        
        cell.floatingTextField.inputAccessoryView = accessoryView;
        cell.leftUtilityButtons = [self leftButtons];
        cell.delegate = self;
        cell.floatingTextField.delegate = self;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) { // Start Date
            cell.floatingTextField.text = startDate;
        } else if (indexPath.row == 1) { // End date
            cell.floatingTextField.text = endDate;
        } else if (indexPath.row == 2)  { // Type Of Leave
             cell.floatingTextField.text = typeOfLeave;
        } else if (indexPath.row == 3)  { // No Of Days
            cell.floatingTextField.text = noOfDays;
        } else if (indexPath.row == 4)  { // Staff Remarks
            cell.accessoryType = UITableViewCellAccessoryNone;
             cell.floatingTextField.userInteractionEnabled = YES;
            cell.floatingTextField.text = staffRemarks;
        } else if (indexPath.row == 5)  { // Submitted By
            cell.floatingTextField.text = submittedBy;
            cell.floatingTextField.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
    
    LeaveRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:[LeaveRecordCell cellIdentifier] forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.tag = indexPath.section;
    [cell configureCellWithModel:_listOfLeaveRecords[indexPath.row]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (selectedPage == 0) {
        selectedRow = indexPath.row;
        if (selectedRow == 0 || selectedRow == 1) {
            [self showCalendar];
        } else if (selectedRow == 2) {
            titleOfList = @"Leave Type";
            nameOfField = @"Leave Type";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:LEAVE_TYPE_GET_URL];
        } else if (selectedRow == 3) {
            titleOfList = @"No. Of Days";
            nameOfField = @"No. Of Days";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:LEAVE_NUMBER_OF_DAYS_URL];
        }
    } else {
        
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (selectedPage == 0) {
        return _listOfValsForApp.count + 1;
    }
    return _listOfLeaveRecords.count;
}

- (void) topFilterChanged: (HMSegmentedControl*) control {
    selectedPage = control.selectedSegmentIndex;
    if (selectedPage == 0) {
        [self.tableView reloadData];
    } else {
        _page = @(1);
        isAppending = NO;
        [self loadLeaveRecords];
    }
}

//- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (textField.text.length == 0) {
//        return YES;
//    }
//    staffRemarks = textField.text;
//    return NO;
//}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0) {
        return;
    }
    staffRemarks = textField.text;
}

#pragma mark - ContactListWithDescriptionDelegate
- (void) didSelectListWithDescription:(UIViewController *)listVC name:(NSString*) name withString:(NSString *)description
{
    if ([name isEqualToString:@"Submitted By"]) {
        submittedBy = description;
    }
    [self.tableView reloadData];
}


#pragma mark - ContactListWithCodeSelectionDelegate
- (void) didSelectList:(UIViewController *)listVC name:(NSString*) name withModel:(CodeDescription *)model
{
    if ([name isEqualToString:@"Leave Type"]) {
        typeOfLeaveCode = model.codeValue;
        typeOfLeave = model.descriptionValue;
    } else {
        noOfDaysCode = model.codeValue;
        noOfDays = model.descriptionValue;
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
    } else if ([segue.identifier isEqualToString:kListWithDescriptionSegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        ListWithDescriptionViewController* vc = navVC.viewControllers.firstObject;
        vc.url = sender;
        vc.titleOfList = titleOfList;
        vc.name = nameOfField;
        vc.contactDelegate = self;
    }
}


@end
