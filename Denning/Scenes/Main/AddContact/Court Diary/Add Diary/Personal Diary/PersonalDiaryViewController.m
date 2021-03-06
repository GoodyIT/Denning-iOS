//
//  PersonalDiaryViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 22/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "PersonalDiaryViewController.h"
#import "ListWithCodeTableViewController.h"
#import "StaffViewController.h"
#import "BirthdayCalendarViewController.h"
#import "DetailWithAutocomplete.h"
#import "MatterLitigationViewController.h"
#import "ClientModel.h"
#import "SimpleAutocomplete.h"

@interface PersonalDiaryViewController ()
<UITextFieldDelegate, SWTableViewCellDelegate, ContactListWithCodeSelectionDelegate>
{
    NSString* titleOfList;
    NSString* nameOfField;
    
    NSString* selectedDetails;
    NSString* selectedAttendantStatus, *selectedStaffAssigned;
    
    NSString* selectedStaff;
    
    CGFloat autocompleteCellHeight;
    
    __block BOOL isLoading, isSaved;
    NSString* serverAPI;
}

@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *startDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *startTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *place;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *staffAssigned;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *details;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *Remarks;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *staffAttended;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *attendantStatus;

@property (strong, nonatomic) UIToolbar *accessoryView;

@property (weak, nonatomic) IBOutlet SWTableViewCell *detailsCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *startDateCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *endDateCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *placeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *staffAssignedCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *remarksCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *staffAttendedCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *attendantStatusCell;

@end

@implementation PersonalDiaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    if  (_personalDiary != nil) {
        [_btnSave setTitle:@"Update" forState:UIControlStateNormal];
        [self displayDiary];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) displayDiary
{
    _place.text = _personalDiary.place;
    _details.text = _personalDiary.appointmentDetails;
    _staffAttended.text = _personalDiary.staffAttended;
    _staffAssigned.text = _personalDiary.staffAssigned.name;
    selectedStaffAssigned = _personalDiary.staffAssigned.clientCode;
    _attendantStatus.text = _personalDiary.attendedStatus.descriptionValue;
    selectedAttendantStatus = _personalDiary.attendedStatus.codeValue;
    _Remarks.text = _personalDiary.remarks;
    
    _startDate.text = [DIHelpers getDateTimeSeprately:_personalDiary.startDate][0];
    _startTime.text = [DIHelpers getDateTimeSeprately:_personalDiary.startDate][1];
    _endDate.text = [DIHelpers getDateTimeSeprately:_personalDiary.endDate][0];
    _endTime.text = [DIHelpers getDateTimeSeprately:_personalDiary.endDate][1];
}

- (void) prepareUI {
    autocompleteCellHeight = 58;
    serverAPI = [DataManager sharedManager].user.serverAPI;

    self.startDate.floatLabelActiveColor = [UIColor redColor];
    self.startTime.floatLabelActiveColor =  [UIColor redColor];
    self.endDate.floatLabelPassiveColor = self.endDate.floatLabelPassiveColor = [UIColor redColor];
    self.endTime.floatLabelActiveColor = self.endTime.floatLabelPassiveColor = [UIColor redColor];
    self.place.floatLabelActiveColor = self.place.floatLabelPassiveColor = [UIColor redColor];
        self.details.floatLabelActiveColor = self.details.floatLabelPassiveColor = [UIColor redColor];
    self.details.floatLabelActiveColor = self.details.floatLabelPassiveColor = [UIColor redColor];
    self.Remarks.floatLabelActiveColor = self.Remarks.floatLabelPassiveColor = [UIColor redColor];
    
    self.startDate.delegate = self;
    self.startTime.delegate = self;
    self.endDate.delegate = self;
    self.endTime.delegate = self;
    
    _accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    _accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    _accessoryView.tintColor = [UIColor babyRed];
    
    _accessoryView.items = @[
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [_accessoryView sizeToFit];
    
    self.Remarks.inputAccessoryView = _accessoryView;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (NSString*) getStartDate {
    return  [NSString stringWithFormat:@"%@ %@", [DIHelpers toMySQLDateFormatWithoutTime:_startDate.text], _endTime.text];
}

- (NSString*) getEndDate {
    return [NSString stringWithFormat:@"%@ %@", [DIHelpers toMySQLDateFormatWithoutTime:_endDate.text], _endTime.text];
}

- (NSDictionary*) buildUpdateParams {
    NSMutableDictionary* data = [NSMutableDictionary new];
    [data addEntriesFromDictionary:@{@"code":_personalDiary.diaryCode}];
    
    if (![_details.text isEqualToString:_personalDiary.appointmentDetails]) {
        [data addEntriesFromDictionary:@{@"appointmentDetails":_details.text}];
    }
    
    NSArray* startDateTime = [DIHelpers getDateTimeSeprately:_personalDiary.startDate];
    if (![_startDate.text isEqualToString:startDateTime[0]]) {
        [data addEntriesFromDictionary:@{@"startdate":[self getStartDate]}];
    }
    
    if (![_startTime.text isEqualToString:startDateTime[1]]) {
        [data addEntriesFromDictionary:@{@"startdate":[self getStartDate]}];
    }
    
    NSArray* endDateTime = [DIHelpers getDateTimeSeprately:_personalDiary.endDate];
    if (![_endDate.text isEqualToString:endDateTime[0]]) {
        [data addEntriesFromDictionary:@{@"endDate":[self getEndDate]}];
    }
    
    if (![_endTime.text isEqualToString:endDateTime[1]]) {
        [data addEntriesFromDictionary:@{@"endDate":[self getEndDate]}];
    }
    
    if (![_place.text isEqualToString:_personalDiary.place]) {
        [data addEntriesFromDictionary:@{@"place":_place.text}];
    }
    
    if (![selectedStaffAssigned isEqualToString:_personalDiary.staffAssigned.clientCode]) {
        [data addEntriesFromDictionary:@{@"staffAssigned":@{@"code":selectedStaffAssigned}}];
    }
    
    if (![_staffAttended.text isEqualToString:_personalDiary.staffAttended]) {
        [data addEntriesFromDictionary:@{@"staffAttended":_staffAttended.text}];
    }
    
    if (![_Remarks.text isEqualToString:_personalDiary.remarks]) {
        [data addEntriesFromDictionary:@{@"remarks":_Remarks.text}];
    }
    
    return [data copy];
}

- (void) _update {
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:PERSONAL_DIARY_SAVE_URL];
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading
                                                                          message:NSLocalizedString(@"QM_STR_LOADING", nil)
                                                                         duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivatePutWithURL:url params:[self buildUpdateParams] completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionTask* _Nonnull task) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully updated" duration:1.0];
            
        } else {
            [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}

- (IBAction)updateDiary:(id)sender {
    [self.view endEditing:YES];
    
    [QMAlert showConfirmDialog:@"Do you want to update data?" withTitle:@"Alert" inViewController:self forBarButton:nil completion:^(UIAlertAction * _Nonnull action) {
        if  ([action.title isEqualToString:@"OK"]) {
            [self _update];
        }
    }];
}

- (NSDictionary*) buildSaveParams {
    NSString* endDate = [NSString stringWithFormat:@"%@ %@", [DIHelpers toMySQLDateFormatWithoutTime:_endDate.text], [DIHelpers toMySQLDateFormatWithoutTime:_endTime.text]];
    NSString* startDate = [NSString stringWithFormat:@"%@ %@", [DIHelpers toMySQLDateFormatWithoutTime:_startDate.text], [DIHelpers toMySQLDateFormatWithoutTime:_startTime.text]];
    return  @{
                           @"appointmentDetails":self.details.text,
                           @"attendedStatus": @{
                                   @"code": @"0",
                                   },
                           @"endDate":endDate,
                           @"startDate": startDate,
                           @"staffAssigned": @{
                                   @"code":selectedStaffAssigned
                                   },
                           @"place": _place.text,
                           @"enclosureDetails": self.details.text,
                           
                           @"remarks": self.Remarks.text
                           };
}

- (void) _save {
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading
                                                                          message:NSLocalizedString(@"QM_STR_LOADING", nil)
                                                                         duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] savePersonalDiaryWithData:[self buildSaveParams] WithCompletion:^(EditCourtModel * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            self->isSaved = YES;
            self.btnSave.enabled = NO;
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully saved" duration:1.0];
            
        } else {
            [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:2.0];
        }
    }];
}

- (void) saveDiary {
    if (isSaved) {
        return;
    }
    
    [self.view endEditing:YES];

    [QMAlert showConfirmDialog:@"Do you want to save data?" withTitle:@"Alert" inViewController:self forBarButton:nil completion:^(UIAlertAction * _Nonnull action) {
        if  ([action.title isEqualToString:@"OK"]) {
            [self _save];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1:
            nameOfField = @"startDate";
            [self showCalendar:self.startDate.text];
            break;
        case 2:
            nameOfField = @"startTime";
            [self showTimePicker:self.startTime.text];
            break;
        case 3:
            nameOfField = @"endDate";
            [self showCalendar:self.endDate.text];
            break;
        case 4:
            nameOfField = @"endTime";
            [self showTimePicker:self.endTime.text];
            break;
            
        default:
            break;
    }
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_personalDiary != nil) {
        return 8;
    }
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return self.startDateCell;;
    } else if (indexPath.row == 1) {
        return self.endDateCell;
    } else if (indexPath.row == 2) {
        self.placeCell.leftUtilityButtons = [self leftButtons];
        self.placeCell.delegate = self;
        return self.placeCell;
    } else if (indexPath.row == 3) {
        self.detailsCell.leftUtilityButtons = [self leftButtons];
        self.detailsCell.delegate = self;
        return self.detailsCell;
    }  else if (indexPath.row == 4) {
        self.staffAssignedCell.leftUtilityButtons = [self leftButtons];
        self.staffAssignedCell.delegate = self;
        return self.staffAssignedCell;
    } else if (indexPath.row == 5) {
        self.staffAttendedCell.leftUtilityButtons = [self leftButtons];
        self.staffAttendedCell.delegate = self;
        return self.staffAttendedCell;
    } else if (indexPath.row == 6) {
        if (_personalDiary != nil) {
            self.attendantStatusCell.leftUtilityButtons = [self leftButtons];
            self.attendantStatusCell.delegate = self;
            return self.attendantStatusCell;
        } else {
            self.remarksCell.leftUtilityButtons = [self leftButtons];
            self.remarksCell.delegate = self;
            return self.remarksCell;
        }
        
    } else if (indexPath.row == 7) {
        self.remarksCell.leftUtilityButtons = [self leftButtons];
        self.remarksCell.delegate = self;
        return self.remarksCell;
    }
    
    return nil;
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
    
    if (indexPath.row == 2) {
        self.place.text = @"";
    } else if (indexPath.row == 3) {
        self.details.text = @"";
    } else if (indexPath.row == 4) {
        self.staffAssigned.text = @"";
        selectedStaffAssigned = @"";
    } else if (indexPath.row == 5) {
        self.staffAttended.text = @"";
    } else if (indexPath.row == 6) {
        if (_personalDiary != nil) {
            self.attendantStatus.text = @"";
            selectedAttendantStatus = @"";
        } else {
            self.Remarks.text = @"";
        }
    } else if (indexPath.row == 7) {
        self.Remarks.text = @"";
    }
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

- (void) showTimePicker:(NSString*) initialTime {
    [self.view endEditing:YES];
    
    TimePickerViewController *timeViewController = [[UIStoryboard storyboardWithName:@
                                                     "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"TimePickerView"];
    timeViewController.initialTime = initialTime;
    timeViewController.updateHandler =  ^(NSString* date) {
        if ([nameOfField isEqualToString:@"startTime"]) {
            self.startTime.text = date;
        } else {
            self.endTime.text = date;
        }
    };
    
    [self showPopup:timeViewController];
}

- (void) showCalendar:(NSString*) initialDate {
    [self.view endEditing:YES];
    
    BirthdayCalendarViewController *calendarViewController = [[UIStoryboard storyboardWithName:@"AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        if ([nameOfField isEqualToString:@"startDate"]) {
            self.startDate.text = date;
            if (self.startTime.text.length == 0) {
                self.startTime.text = @"09:00";
            }
            if (_endDate.text.length == 0) {
                _endDate.text = date;
            }
            if (self.endTime.text.length == 0) {
                self.endTime.text = @"17:00";
            }
        } else {
            self.endDate.text = date;
            if (self.endTime.text.length == 0) {
                self.endTime.text = @"17:00";
            }
        }
    };
    [self showPopup:calendarViewController];
}

- (void) showDetailAutocomplete {
    [self.view endEditing:YES];
    
    DetailWithAutocomplete *vc = [[UIStoryboard storyboardWithName:@
                                   "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailWithAutocomplete"];
    vc.url = COURT_PERSONAL_DETAIL_GET_LIST_URL;
    vc.updateHandler =  ^(CodeDescription* model) {
        self.details.text = model.descriptionValue;
    };
    [self showPopup:vc];
}

- (void) showAutocomplete:(NSString*) url {
    [self.view endEditing:YES];
    
    SimpleAutocomplete *vc = [[UIStoryboard storyboardWithName:@
                               "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"SimpleAutocomplete"];
    vc.url = url;
    vc.title = @"";
    vc.updateHandler =  ^(NSString* selectedString) {
        if ([nameOfField isEqualToString:@"Place"]) {
            self.place.text = selectedString;
        } else {
            self.details.text = selectedString;
        }
    };
    
    [self showPopup:vc];
}


#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 2) {
        nameOfField = @"Place";
        [self showAutocomplete:COURT_PERSONAL_PLACE_GET_LIST_URL];
    } else if (indexPath.row == 3) {
        nameOfField = @"Details";
        [self showAutocomplete:COURT_PERSONAL_DETAIL_GET_LIST_URL];
    } else if (indexPath.row == 4) {
         selectedStaff = @"Staff Assigned";
        [self performSegueWithIdentifier:kStaffSegue sender:@"attest"];
    } else if (indexPath.row == 5) {
        selectedStaff = @"Staff Attended";
        [self performSegueWithIdentifier:kStaffSegue sender:@"attest"];
    } else if (indexPath.row == 6) {
        if (_personalDiary != nil) {
            titleOfList = @"Attendant Type";
            nameOfField = @"Attendant Status";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_ATTENDED_STATUS_GET_URL];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ContactListWithCodeSelectionDelegate
- (void) didSelectList:(UIViewController *)listVC name:(NSString*) name withModel:(CodeDescription *)model
{
    if ([name isEqualToString:@"Attendant Status"]) {
        self.attendantStatus.text = model.descriptionValue;
        selectedAttendantStatus = model.codeValue;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kStaffSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        StaffViewController* staffVC = navVC.viewControllers.firstObject;
        staffVC.typeOfStaff = sender;
        staffVC.updateHandler = ^(NSString* typeOfStaff, StaffModel* model) {
            if ([selectedStaff isEqualToString:@"Staff Assigned"]) {
                self.staffAssigned.text = model.name;
                selectedStaffAssigned = model.staffCode;
            } else {
                _staffAttended.text = model.name;
            }
        };
    } else if ([segue.identifier isEqualToString:kListWithCodeSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        ListWithCodeTableViewController *listCodeVC = navVC.viewControllers.firstObject;
        listCodeVC.delegate = self;
        listCodeVC.titleOfList = titleOfList;
        listCodeVC.name = nameOfField;
        listCodeVC.url = sender;
    }
}


@end
