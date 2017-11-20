//
//  OfficeDiaryViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 22/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "OfficeDiaryViewController.h"
#import "ListWithCodeTableViewController.h"
#import "StaffViewController.h"
#import "BirthdayCalendarViewController.h"
#import "DetailWithAutocomplete.h"
#import "SimpleMatterViewController.h"
#import "ClientModel.h"
#import "SimpleAutocomplete.h"
#import "MatterLitigationViewController.h"

@interface OfficeDiaryViewController ()
<UITextFieldDelegate, SWTableViewCellDelegate, ContactListWithCodeSelectionDelegate>
{
    NSString* titleOfList;
    NSString* nameOfField;
    
    NSString* selectedNatureOfHearing;
    NSString* selectedDetails;
    
    NSString* selectedAttendantStatus, *selectedStaffAssigned, *selectedStaffAttended;
    
    CGFloat autocompleteCellHeight;
    
    __block BOOL isLoading;
    NSString* serverAPI;
}

@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *appointment;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *fileNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *caseNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *caseName;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *startDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *startTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *place;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *staffAssigned;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *Remarks;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *attendantStatus;

@property (weak, nonatomic) IBOutlet SWTableViewCell *appointmentCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *fileNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *caseNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *caseNameCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *startDateCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *endDateCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *placeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *staffAssignedCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *attendantStatusCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *remarksCell;


@property (strong, nonatomic) UIToolbar *accessoryView;

@end

@implementation OfficeDiaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    
    if  (_officeDiary != nil) {
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
    _place.text = _officeDiary.place;
    _staffAssigned.text = _officeDiary.staffAssigned.descriptionValue;
    _appointment.text = _officeDiary.appointmentDetails;
    _Remarks.text = _officeDiary.remarks;
    _caseNo.text = _officeDiary.caseNo;
    _caseName.text = _officeDiary.caseName;
    _fileNo.text = _officeDiary.fileNo1;
    _attendantStatus.text = _officeDiary.attendedStatus.descriptionValue;
    selectedAttendantStatus = _officeDiary.attendedStatus.codeValue;
    
    _startDate.text = [DIHelpers getDateTimeSeprately:_officeDiary.startDate][0];
    _startTime.text = [DIHelpers getDateTimeSeprately:_officeDiary.startDate][1];
    _endDate.text = [DIHelpers getDateTimeSeprately:_officeDiary.endDate][0];
    _endTime.text = [DIHelpers getDateTimeSeprately:_officeDiary.endDate][1];
}

- (void) prepareUI {
    selectedStaffAssigned = selectedAttendantStatus = selectedDetails = selectedStaffAttended = selectedNatureOfHearing = @"";
    
    autocompleteCellHeight = 58;
    serverAPI = [DataManager sharedManager].user.serverAPI;
    
    self.appointment.floatLabelActiveColor = self.appointment.floatLabelPassiveColor = [UIColor redColor];
    self.fileNo.floatLabelActiveColor = self.fileNo.floatLabelPassiveColor = [UIColor redColor];
    self.caseName.floatLabelActiveColor = self.caseName.floatLabelPassiveColor = [UIColor redColor];
    self.caseNo.floatLabelActiveColor = self.caseNo.floatLabelPassiveColor = [UIColor redColor];
    self.startDate.floatLabelActiveColor = self.startDate.floatLabelPassiveColor = [UIColor redColor];
    self.startTime.floatLabelActiveColor = self.startTime.floatLabelPassiveColor = [UIColor redColor];
    self.place.floatLabelActiveColor = self.place.floatLabelPassiveColor = [UIColor redColor];
    self.endDate.floatLabelActiveColor = self.endTime.floatLabelPassiveColor = [UIColor redColor];
    self.endTime.floatLabelActiveColor = self.endTime.floatLabelPassiveColor = [UIColor redColor];
    self.staffAssigned.floatLabelActiveColor = self.staffAssigned.floatLabelPassiveColor = [UIColor redColor];
    
    self.startDate.delegate = self;
    self.startTime.delegate = self;
    self.endDate.delegate = self;
    self.endTime.delegate = self;
   
    self.Remarks.floatLabelActiveColor = self.Remarks.floatLabelPassiveColor = [UIColor redColor];
    
    _accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    _accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    _accessoryView.tintColor = [UIColor babyRed];
    
    _accessoryView.items = @[
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [_accessoryView sizeToFit];
    
    self.appointment.inputAccessoryView = _accessoryView;
    self.caseName.inputAccessoryView = _accessoryView;
    self.caseNo.inputAccessoryView = _accessoryView;
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

- (IBAction)updateDiary:(id)sender {
    NSMutableDictionary* data = [NSMutableDictionary new];
    [data addEntriesFromDictionary:@{@"code":_officeDiary.diaryCode}];
    
    if (![_appointment.text isEqualToString:_officeDiary.appointmentDetails]) {
        [data addEntriesFromDictionary:@{@"appointmentDetails":_appointment.text}];
    }
    
    if (![_attendantStatus.text isEqualToString:_officeDiary.attendedStatus.descriptionValue]) {
        [data addEntriesFromDictionary:@{@"attendedStatus":@{@"code":selectedAttendantStatus}}];
    }
    
    NSArray* startDateTime = [DIHelpers getDateTimeSeprately:_officeDiary.startDate];
    if (![_startDate.text isEqualToString:startDateTime[0]]) {
        [data addEntriesFromDictionary:@{@"startdate":[self getStartDate]}];
    }
    
    if (![_startTime.text isEqualToString:startDateTime[1]]) {
        [data addEntriesFromDictionary:@{@"startdate":[self getStartDate]}];
    }
    
    NSArray* endDateTime = [DIHelpers getDateTimeSeprately:_officeDiary.endDate];
    if (![_endDate.text isEqualToString:endDateTime[0]]) {
        [data addEntriesFromDictionary:@{@"endDate":[self getEndDate]}];
    }
    
    if (![_endTime.text isEqualToString:endDateTime[1]]) {
        [data addEntriesFromDictionary:@{@"endDate":[self getEndDate]}];
    }
    
    if (![_place.text isEqualToString:_officeDiary.place]) {
        [data addEntriesFromDictionary:@{@"place":_place.text}];
    }
    
    if (![_fileNo.text isEqualToString:_officeDiary.fileNo1]) {
        [data addEntriesFromDictionary:@{@"fileNo1":_fileNo.text}];
    }
    
    if (![_staffAssigned.text isEqualToString:_officeDiary.staffAssigned.descriptionValue]) {
        [data addEntriesFromDictionary:@{@"staffAssigned":@{@"code":selectedStaffAssigned}}];
    }
    
    if (![_Remarks.text isEqualToString:_officeDiary.remarks]) {
        [data addEntriesFromDictionary:@{@"remarks":_Remarks.text}];
    }
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:OFFICE_DIARY_SAVE_URL];
    if (isLoading) return;
    isLoading = YES;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivatePutWithURL:url params:data completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully updated" duration:1.0];
            
        } else {
            [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}

- (void) saveDiary {
    NSDictionary* data = @{
                           @"appointmentDetails": self.appointment.text,
                           @"attendedStatus": @{
                                   @"code": @"0"
                                   },
                           
                           @"staffAssigned": @{@"code":selectedStaffAssigned},
                           
                           @"courtDecision": @"",
                           @"fileNo1": self.fileNo.text,
                           @"place": self.place.text,
                           @"startDate": [self getStartDate],
                           @"endDate": [self endDate],
                           
                           @"remark": self.Remarks.text
                           };
    if (isLoading) return;
    isLoading = YES;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] saveOfficeDiaryWithData:data WithCompletion:^(EditCourtModel * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully saved" duration:1.0];
            
        } else {
            [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
        
    }];
}

#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1:
            nameOfField = @"startDate";
            [self showCalendar];
            break;
        case 2:
            nameOfField = @"startTime";
            [self showTimePicker];
            break;
        case 3:
            nameOfField = @"endDate";
            [self showCalendar];
            break;
        case 4:
            nameOfField = @"endTime";
            [self showTimePicker];
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
    if  (_officeDiary != nil) {
        return 10;
    }
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        self.appointmentCell.leftUtilityButtons = [self leftButtons];
        self.appointmentCell.delegate = self;
        return self.appointmentCell;;
    } else if (indexPath.row == 1) {
        return self.startDateCell;;
    } else if (indexPath.row == 2) {
        return self.endDateCell;
    } else if (indexPath.row == 3) {
        self.placeCell.leftUtilityButtons = [self leftButtons];
        self.placeCell.delegate = self;
        return self.placeCell;
    } else if (indexPath.row == 4) {
        self.fileNoCell.leftUtilityButtons = [self leftButtons];
        self.fileNoCell.delegate = self;
        return self.fileNoCell;
    } else if (indexPath.row == 5) {
        self.caseNoCell.leftUtilityButtons = [self leftButtons];
        self.caseNoCell.delegate = self;
        return self.caseNoCell;
    } else if (indexPath.row == 6) {
        self.caseNameCell.leftUtilityButtons = [self leftButtons];
        self.caseNameCell.delegate = self;
        return self.caseNameCell;
    } else if (indexPath.row == 7) {
        self.staffAssignedCell.leftUtilityButtons = [self leftButtons];
        self.staffAssignedCell.delegate = self;
        return self.staffAssignedCell;
    } else if (indexPath.row == 8) {
        if  (_officeDiary == nil) {
            self.remarksCell.leftUtilityButtons = [self leftButtons];
            self.remarksCell.delegate = self;
            return self.remarksCell;
        } else {
            self.attendantStatusCell.leftUtilityButtons = [self leftButtons];
            self.attendantStatusCell.delegate = self;
            return self.attendantStatusCell;
        }
        
    }else if (indexPath.row == 9) {
        if  (_officeDiary != nil) {
            self.remarksCell.leftUtilityButtons = [self leftButtons];
            self.remarksCell.delegate = self;
            return self.remarksCell;
        }
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
    
    if (indexPath.row == 0) {
        self.appointment.text = @"";
    } else if (indexPath.row == 3) {
        self.place.text = @"";
    } else if (indexPath.row == 4) {
        self.fileNo.text = @"";
    } else if (indexPath.row == 5) {
        self.caseNo.text = @"";
    } else if (indexPath.row == 6) {
        self.caseName.text = @"";
    } else if (indexPath.row == 7) {
        self.staffAssigned.text = @"";
    } else if (indexPath.row == 8) {
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

- (void) showAutocomplete:(NSString*) url {
    [self.view endEditing:YES];
    
    SimpleAutocomplete *vc = [[UIStoryboard storyboardWithName:@
                               "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"SimpleAutocomplete"];
    vc.url = url;
    vc.title = @"";
    vc.updateHandler =  ^(NSString* selectedString) {
        if ([nameOfField isEqualToString:@"Appointment"]) {
            self.appointment.text = selectedString;
        } else {
            self.place.text = selectedString;
        }
    };
    
    [self showPopup:vc];
}

- (void) showTimePicker {
    [self.view endEditing:YES];
    
    TimePickerViewController *timeViewController = [[UIStoryboard storyboardWithName:@
                                                     "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"TimePickerView"];
    timeViewController.updateHandler =  ^(NSString* date) {
        if ([nameOfField isEqualToString:@"startTime"]) {
            self.startTime.text = date;
        } else {
            self.endTime.text = date;
        }
    };
    
    [self showPopup:timeViewController];
}

- (void) showCalendar {
    [self.view endEditing:YES];
    BirthdayCalendarViewController *calendarViewController = [[UIStoryboard storyboardWithName:@"AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        if ([nameOfField isEqualToString:@"startDate"]) {
            self.startDate.text = date;
        } else {
            self.endDate.text = date;
        }
    };
    [self showPopup:calendarViewController];
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        nameOfField = @"Appointment";
        [self showAutocomplete:COURT_OFFICE_APPOINTMENT_GET_LIST_URL];
    } else if (indexPath.row == 3) {
        nameOfField = @"Place";
        [self showAutocomplete:COURT_OFFICE_PLACE_GET_LIST_URL];
    } else if (indexPath.row == 4) {
        [self performSegueWithIdentifier:kMatterLitigationSegue sender:nil];
    } else if (indexPath.row == 7) {
        [self performSegueWithIdentifier:kStaffSegue sender:@"attest"];
    } else if (indexPath.row == 8) {
        if (_officeDiary != nil) {
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
    if ([segue.identifier isEqualToString:kMatterLitigationSegue]) {
        MatterLitigationViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterLitigationModel *model) {
            self.fileNo.text = model.systemNo;
            self.caseNo.text = model.courtInfo.caseNumber;
            self.caseName.text = model.courtInfo.caseName;
        };
    } else if ([segue.identifier isEqualToString:kStaffSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        StaffViewController* staffVC = navVC.viewControllers.firstObject;
        staffVC.typeOfStaff = sender;
        staffVC.updateHandler = ^(NSString* typeOfStaff, StaffModel* model) {
                selectedStaffAssigned = model.staffCode;
                self.staffAssigned.text = model.name;
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
