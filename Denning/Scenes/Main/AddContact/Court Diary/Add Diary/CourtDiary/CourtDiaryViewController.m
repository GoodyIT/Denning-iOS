//
//  CourtDiaryViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 22/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CourtDiaryViewController.h"
#import "ListWithCodeTableViewController.h"
#import "StaffViewController.h"
#import "BirthdayCalendarViewController.h"
#import "DetailWithAutocomplete.h"
#import "StaffAutoComplete.h"
#import "SimpleMatterViewController.h"
#import "MatterLitigationViewController.h"
#import "CourtDiaryListViewController.h"
#import "CoramListViewController.h"
#import "ClientModel.h"


@interface CourtDiaryViewController ()
< UITextFieldDelegate, SWTableViewCellDelegate, ContactListWithCodeSelectionDelegate>
{
    NSString* titleOfList;
    NSString* nameOfField;
    NSString* url;
    
    NSString* selectedNatureOfHearing, *selectedNextNatureOfHearing;
    NSString* selectedDetails;
    NSString* selectedCourtCode;
    NSString* selectedCoramCode;
    NSString* selectedAttendedStatus, *selectedAssignedCode;
    NSString* selectedDecisionCode;
    NSString* selectedNextDateTypeCode;
    
    NSString* selectedStaff, *selecteDetail;
    
    CGFloat autocompleteCellHeight;
    
    __block BOOL isLoading, isSaved;
    NSString* serverAPI;
}

@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *fileNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *caseNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *caseName;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *startDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *startTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *place;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *placeType;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *councilAssigned;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *details;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *Remarks;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *natureOfHearing;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *enclosureNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *attendedStatus;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *counselAttended;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *coram;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *opponentCounsel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *courtDecision;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *nextDateType;

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *nextStartDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *nextStartTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *nextEndDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *nextEndTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *nextEnclosureNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *nextNatureOfHearing;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *nextDetails;

@property (weak, nonatomic) IBOutlet SWTableViewCell *fileNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *caseNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *caseNameCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *startDateCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *endDateCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *placeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *enclosureCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *natureOfHearingCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *councilAssignedCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *detailsCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *attendedStatusCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *counselAttendedCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *coramCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *opponentCounselCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *courtDecisionCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *nextDateTypeCell;

@property (weak, nonatomic) IBOutlet SWTableViewCell *remarksCell;

@property (weak, nonatomic) IBOutlet SWTableViewCell *nextStartDateTimeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *nextEndDateTimeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *nextEnclosureNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *nextNatureOfhearingCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *nextDetailCell;

@property (strong, nonatomic) UIToolbar *accessoryView;

@end

@implementation CourtDiaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    if (_courtDiary != nil) {
        [self.btnSave setTitle:@"Update" forState:UIControlStateNormal];
        self.title = @"Update Court Diary";
        [self displayDiary];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) displayDiary {
    _place.text = _courtDiary.court.place;
    _placeType.text = _courtDiary.court.typeCase;
    selectedCourtCode = _courtDiary.court.courtDiaryCode;
    _enclosureNo.text = _courtDiary.enclosureNo;
    _Remarks.text = _courtDiary.remarks;
    _caseNo.text = _courtDiary.caseNo;
    _caseName.text = _courtDiary.caseName;
    _fileNo.text = _courtDiary.fileNo1;
    _natureOfHearing.text = _courtDiary.hearingType;
    _councilAssigned.text = _courtDiary.counselAssigned.name;
    selectedAssignedCode = _courtDiary.counselAssigned.clientCode;
    _details.text = _courtDiary.enclosureDetails;
    _Remarks.text = _courtDiary.remarks;
    _coram.text = _courtDiary.coram.name;
    selectedCoramCode = _courtDiary.coram.coramCode;
    _opponentCounsel.text = _courtDiary.opponentCounsel;
    _attendedStatus.text = _courtDiary.attendedStatus.descriptionValue;
    selectedAttendedStatus = _courtDiary.attendedStatus.codeValue;
    _counselAttended.text = _courtDiary.counselAttended;
    _courtDecision.text = _courtDiary.courtDecision;
    _nextDateType.text = _courtDiary.nextDateType.descriptionValue;
    selectedNextDateTypeCode = _courtDiary.nextDateType.codeValue;
    
    _startDate.text = [DIHelpers getDateTimeSeprately:_courtDiary.hearingStartDate][0];
    _startTime.text = [DIHelpers getDateTimeSeprately:_courtDiary.hearingStartDate][1];
    _endDate.text = [DIHelpers getDateTimeSeprately:_courtDiary.hearingEndDate][0];
    _endTime.text = [DIHelpers getDateTimeSeprately:_courtDiary.hearingEndDate][1];
    
    _nextStartDate.text = [DIHelpers getDateTimeSeprately:_courtDiary.nextStartDate][0];
    _nextStartTime.text = [DIHelpers getDateTimeSeprately:_courtDiary.nextStartDate][1];
    _nextEndDate.text = [DIHelpers getDateTimeSeprately:_courtDiary.nextEndDate][0];
    _nextEndTime.text = [DIHelpers getDateTimeSeprately:_courtDiary.nextEndDate][1];
    if ([_nextStartTime.text isEqualToString:@"00:00"]) {
        _nextStartTime.text = @"09:00";
    }
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareUI {
   selectedDecisionCode = selectedNextDateTypeCode = selectedDetails = selectedNatureOfHearing = selectedCourtCode = selectedAttendedStatus = selectedCoramCode = @"";
    autocompleteCellHeight = 58;
    serverAPI = [DataManager sharedManager].user.serverAPI;
    
    self.fileNo.floatLabelActiveColor = self.fileNo.floatLabelPassiveColor = [UIColor redColor];
    self.caseNo.floatLabelActiveColor = self.caseNo.floatLabelPassiveColor = [UIColor redColor];
    self.caseName.floatLabelActiveColor =  self.caseName.floatLabelPassiveColor = [UIColor redColor];
    self.startDate.floatLabelActiveColor = self.startDate.floatLabelPassiveColor = [UIColor redColor];
    self.startTime.floatLabelActiveColor = self.startTime.floatLabelPassiveColor = [UIColor redColor];
    self.endDate.floatLabelActiveColor = self.endDate.floatLabelPassiveColor = [UIColor redColor];
    self.endTime.floatLabelActiveColor = self.endTime.floatLabelPassiveColor = [UIColor redColor];
    self.place.floatLabelActiveColor = self.place.floatLabelPassiveColor = [UIColor redColor];
    self.natureOfHearing.floatLabelActiveColor = self.natureOfHearing.floatLabelPassiveColor = [UIColor redColor];
    self.councilAssigned.floatLabelActiveColor = self.councilAssigned.floatLabelPassiveColor = [UIColor redColor];
    self.enclosureNo.floatLabelActiveColor = self.enclosureNo.floatLabelPassiveColor = [UIColor redColor];
    self.details.floatLabelActiveColor = self.details.floatLabelPassiveColor = [UIColor redColor];
    self.nextDetails.floatLabelActiveColor = self.nextDetails.floatLabelPassiveColor = [UIColor redColor];
    self.nextEnclosureNo.floatLabelActiveColor = self.nextEnclosureNo.floatLabelPassiveColor = [UIColor redColor];
    self.nextStartDate.floatLabelActiveColor = self.nextStartDate.floatLabelPassiveColor = self.nextEndDate.floatLabelActiveColor = self.nextEndDate.floatLabelPassiveColor = [UIColor redColor];
    self.nextNatureOfHearing.floatLabelActiveColor = self.nextNatureOfHearing.floatLabelPassiveColor = [UIColor redColor];
    self.nextDetails.floatLabelActiveColor = self.nextDetails.floatLabelPassiveColor = [UIColor redColor];
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
    
    self.enclosureNo.inputAccessoryView = _accessoryView;
    self.caseName.inputAccessoryView = _accessoryView;
    self.caseNo.inputAccessoryView = _accessoryView;
    self.Remarks.inputAccessoryView = _accessoryView;
    self.nextEnclosureNo.inputAccessoryView = _accessoryView;
    
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

- (NSString*) getNextStartDate {
    return  [NSString stringWithFormat:@"%@ %@", [DIHelpers toMySQLDateFormatWithoutTime:_nextStartDate.text], _nextStartTime.text];
}

- (NSString*) getNextEndDate {
    return  [NSString stringWithFormat:@"%@ %@", [DIHelpers toMySQLDateFormatWithoutTime:_nextEndDate.text], _nextEndTime.text];
}


- (void) _update {
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:COURT_SAVE_UPATE_URL];
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivatePutWithURL:url params:[self buildUpdateParams] completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
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

- (NSDictionary*) buildUpdateParams {
    NSMutableDictionary* data = [NSMutableDictionary new];
    [data addEntriesFromDictionary:@{@"code":_courtDiary.courtCode}];
    
    if (![selectedAttendedStatus isEqualToString:_courtDiary.attendedStatus.codeValue]) {
        [data addEntriesFromDictionary:@{@"attendedStatus":@{@"code":selectedAttendedStatus}}];
    }
    
    if (![[self getStartDate] isEqualToString:_courtDiary.hearingStartDate]) {
        [data addEntriesFromDictionary:@{@"hearingStartDate":[self getStartDate]}];
    }
    
    if (![[self getEndDate] isEqualToString:_courtDiary.hearingEndDate]) {
        [data addEntriesFromDictionary:@{@"hearingEndDate":[self getEndDate]}];
    }
    
    if (![_fileNo.text isEqualToString:_courtDiary.fileNo1]) {
        [data addEntriesFromDictionary:@{@"fileNo1":_fileNo.text}];
    }
    
    if (![selectedAssignedCode isEqualToString:_courtDiary.counselAssigned.clientCode]) {
        [data addEntriesFromDictionary:@{@"counselAssigned":@{@"code":selectedAssignedCode}}];
    }
    
    if (![_counselAttended.text isEqualToString:_courtDiary.counselAttended]) {
        [data addEntriesFromDictionary:@{@"counselAttended":_counselAttended.text}];
    }
    
    if (![selectedCoramCode isEqualToString:_courtDiary.coram.coramCode]) {
        [data addEntriesFromDictionary:@{@"coram":@{@"code":selectedCoramCode}}];
    }
    
    if (![selectedCourtCode isEqualToString:_courtDiary.court.courtDiaryCode]) {
        [data addEntriesFromDictionary:@{@"court":@{@"code":selectedCourtCode}}];
    }
    
    if (![_courtDecision.text isEqualToString:_courtDiary.courtDecision]) {
        [data addEntriesFromDictionary:@{@"courtDecision":_courtDecision.text}];
    }
    
    if (![_details.text isEqualToString:_courtDiary.enclosureDetails]) {
        [data addEntriesFromDictionary:@{@"enclosureDetails":_details.text}];
    }
    
    if (![_enclosureNo.text isEqualToString:_courtDiary.enclosureNo]) {
        [data addEntriesFromDictionary:@{@"enclosureNo":_enclosureNo.text}];
    }
    
    if (![selectedNextDateTypeCode isEqualToString:_courtDiary.nextDateType.codeValue]) {
        [data addEntriesFromDictionary:@{@"nextDateType":@{@"code":selectedNextDateTypeCode}}];
    }
    
    if (![_opponentCounsel.text isEqualToString:_courtDiary.opponentCounsel]) {
        [data addEntriesFromDictionary:@{@"opponentCounsel":_opponentCounsel.text}];
    }
   
    if (![_natureOfHearing.text isEqualToString:_courtDiary.hearingType]) {
        [data addEntriesFromDictionary:@{@"hearingType":_natureOfHearing.text}];
    }
    
    if (![_Remarks.text isEqualToString:_courtDiary.remarks]) {
        [data addEntriesFromDictionary:@{@"remarks":_Remarks.text}];
    }
    
    [data addEntriesFromDictionary:@{@"nextStartDate":[self getNextStartDate]}];
    
    [data addEntriesFromDictionary:@{@"nextEndDate":[self getNextEndDate]}];
    
    [data addEntriesFromDictionary:@{@"next_hearingType":_nextNatureOfHearing.text}];
    
    [data addEntriesFromDictionary:@{@"next_enclosureNo":_nextEnclosureNo.text}];
    
    [data addEntriesFromDictionary:@{@"next_enclosureDetails":_nextDetails.text}];
    
    return [data copy];
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
    return @{
             @"chkDone":@"0",
             @"attendedStatus": @{
                     @"code": @"0"},
             @"coram":
                 @{
                     @"code": @"0"},
             @"counselAssigned": @{@"code":selectedAssignedCode},
             @"court": @{@"code":selectedCourtCode},
             @"courtDecision": @"",
             @"enclosureDetails": self.details.text,
             @"enclosureNo": self.enclosureNo.text,
             @"fileNo1": self.fileNo.text,
             @"hearingStartDate": [NSString stringWithFormat:@"%@ %@", [DIHelpers toMySQLDateFormatWithoutTime:_startDate.text], _startTime.text],
             @"hearingType": selectedNatureOfHearing,
             @"hearingEndDate": [NSString stringWithFormat:@"%@ %@", [DIHelpers toMySQLDateFormatWithoutTime:_endDate.text], _endTime.text],
             @"nextDateType": @{
                     @"code": @"0"
                     },
             @"opponentCounsel":@"",
             @"previousDate": @"2000-01-01 00:00:00",
             @"remarks": self.Remarks.text
             };
}

- (void) _save {
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] saveCourtDiaryWithData:[self buildSaveParams] WithCompletion:^(EditCourtModel * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully saved" duration:1.0];
            self->isSaved = YES;
            self.btnSave.enabled = NO;
        } else {
            [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}

- (void) saveDiary {
    [self.view endEditing:YES];
    
    if (isSaved) {
        return;
    }
    
    [QMAlert showConfirmDialog:@"Do you want to save data?" withTitle:@"Alert" inViewController:self forBarButton:nil completion:^(UIAlertAction * _Nonnull action) {
        if  ([action.title isEqualToString:@"OK"]) {
            [self _save];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if ([_courtDiary.nextDateType.codeValue isEqualToString:@"0"]) {
        return;
    }
    switch (textField.tag) {
        case 1:
            nameOfField = @"startDate";
            [self showCalendar: self.startDate.text];
            break;
        case 2:
            nameOfField = @"startTime";
            [self showTimePicker:self.startTime.text];
            break;
        case 3:
            nameOfField = @"endDate";
            [self showCalendar: self.endDate.text];
            break;
        case 4:
            nameOfField = @"endTime";
            [self showTimePicker:self.endTime.text];
            break;
        case 11:
            nameOfField = @"nextStartDate";
            [self showCalendar: self.nextStartDate.text];
            break;
        case 12:
            nameOfField = @"nextStartTime";
            [self showTimePicker:self.nextStartTime.text];
            break;
        case 13:
            nameOfField = @"nextEndDate";
            [self showCalendar: self.nextEndDate.text];
            break;
        case 14:
            nameOfField = @"nextEndTime";
            [self showTimePicker:self.nextEndTime.text];
            break;
            
            
        default:
            break;
    }
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([_courtDiary.nextDateType.codeValue isEqualToString:@"0"] && [@[@11, @12, @13, @14, @15] containsObject:@(textField.tag)]) {
        return NO;
    }
    
    return YES;
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
    if (_courtDiary != nil && [selectedNextDateTypeCode isEqualToString:@"0"]) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_courtDiary != nil) {
        if (section == 0) {
            return 17;
        } else {
            if ([selectedNextDateTypeCode isEqualToString:@"0"]) {
                return 5;
            } else {
                return 0;
            }
        }
    }
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.fileNoCell.leftUtilityButtons = [self leftButtons];
            self.fileNoCell.delegate = self;
            return self.fileNoCell;
        } else if (indexPath.row == 1) {
            self.caseNoCell.leftUtilityButtons = [self leftButtons];
            self.caseNoCell.delegate = self;
            return self.caseNoCell;
        } else if (indexPath.row == 2) {
            self.caseNameCell.leftUtilityButtons = [self leftButtons];
            self.caseNameCell.delegate = self;
            return self.caseNameCell;
        } else if (indexPath.row == 3) {
            return self.startDateCell;;
        } else if (indexPath.row == 4) {
            return self.endDateCell;
        } else if (indexPath.row == 5) {
            self.placeCell.leftUtilityButtons = [self leftButtons];
            self.placeCell.delegate = self;
            return self.placeCell;
        } else if (indexPath.row == 6) {
            self.enclosureCell.leftUtilityButtons = [self leftButtons];
            self.enclosureCell.delegate = self;
            return self.enclosureCell;;
        } else if (indexPath.row == 7) {
            self.natureOfHearingCell.leftUtilityButtons = [self leftButtons];
            self.natureOfHearingCell.delegate = self;
            return self.natureOfHearingCell;
        } else if (indexPath.row == 8) {
            self.detailsCell.leftUtilityButtons = [self leftButtons];
            self.detailsCell.delegate = self;
            return self.detailsCell;
        } else if (indexPath.row == 9) {
            self.councilAssignedCell.leftUtilityButtons = [self leftButtons];
            self.councilAssignedCell.delegate = self;
            return self.councilAssignedCell;
        } else if (indexPath.row == 10) {
            if (_courtDiary != nil) {
                self.attendedStatusCell.leftUtilityButtons = [self leftButtons];
                self.attendedStatusCell.delegate = self;
                return self.attendedStatusCell;
            } else {
                self.remarksCell.leftUtilityButtons = [self leftButtons];
                self.remarksCell.delegate = self;
                return self.remarksCell;
            }
        } else if (indexPath.row == 11) {
            if (_courtDiary != nil) {
                self.counselAttendedCell.leftUtilityButtons = [self leftButtons];
                self.counselAttendedCell.delegate = self;
                return self.counselAttendedCell;
            }
        } else if (indexPath.row == 12) {
            self.coramCell.leftUtilityButtons = [self leftButtons];
            self.coramCell.delegate = self;
            return self.coramCell;
        } else if (indexPath.row == 13) {
            self.opponentCounselCell.leftUtilityButtons = [self leftButtons];
            self.opponentCounselCell.delegate = self;
            return self.opponentCounselCell;
        } else if (indexPath.row == 14) {
            self.courtDecisionCell.leftUtilityButtons = [self leftButtons];
            self.courtDecisionCell.delegate = self;
            return self.courtDecisionCell;
        } else if (indexPath.row == 15) {
            self.remarksCell.leftUtilityButtons = [self leftButtons];
            self.remarksCell.delegate = self;
            return self.remarksCell;
        }  else if (indexPath.row == 16) {
            self.nextDateTypeCell.leftUtilityButtons = [self leftButtons];
            self.nextDateTypeCell.delegate = self;
            return self.nextDateTypeCell;
        }
    } else {
        if ([selectedNextDateTypeCode isEqualToString:@"0"]) {
            if (indexPath.row == 0) {
                return self.nextStartDateTimeCell;
            } else if (indexPath.row == 1) {
                return self.nextEndDateTimeCell;
            }  else if (indexPath.row == 2) {
                self.nextEnclosureNoCell.leftUtilityButtons = [self leftButtons];
                self.nextEnclosureNoCell.delegate = self;
                return self.nextEnclosureNoCell;
            } else if (indexPath.row == 3) {
                self.nextNatureOfhearingCell.leftUtilityButtons = [self leftButtons];
                self.nextNatureOfhearingCell.delegate = self;
                return self.nextNatureOfhearingCell;
            } else if (indexPath.row == 4) {
                self.nextDetailCell.leftUtilityButtons = [self leftButtons];
                self.nextDetailCell.delegate = self;
                return self.nextDetailCell;
            }
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
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.fileNo.text = @"";
            self.caseNo.text = @"";
            self.caseName.text = @"";
        } else if (indexPath.row == 1) {
            self.caseNo.text = @"";
        } else if (indexPath.row == 2) {
            self.caseName.text = @"";
        } else if (indexPath.row == 5) {
            self.place.text = @"";
            self.placeType.text = @"";
            selectedCourtCode = @"";
        } else if (indexPath.row == 6) {
            self.enclosureNo.text = @"";
        } else if (indexPath.row == 7) {
            self.natureOfHearing.text = @"";
            selectedNatureOfHearing = @"";
        } else if (indexPath.row == 8) {
            self.details.text = @"";
        } else if (indexPath.row == 9) {
            self.councilAssigned.text = @"";
            selectedAssignedCode = @"";
        } else if (indexPath.row == 10) {
            if (_courtDiary != nil) {
                _attendedStatus.text = @"";
                selectedAttendedStatus = @"";
            } else {
                self.Remarks.text = @"";
            }
        } else if (indexPath.row == 11) {
            _counselAttended.text = @"";
        } else if (indexPath.row == 12) {
            _coram.text = @"";
            selectedCoramCode = @"";
        } else if (indexPath.row == 13) {
            _opponentCounsel.text = @"";
        } else if (indexPath.row == 14) {
            _courtDecision.text = @"";
            selectedDecisionCode = @"";
        } else if (indexPath.row == 15) {
            _nextDateType.text = @"";
            selectedNextDateTypeCode = @"";
        }
    } else {
        if (indexPath.row == 1) {
            _nextEnclosureNo.text = @"";
        } else if (indexPath.row == 2) {
            _nextNatureOfHearing.text = @"";
        } else if (indexPath.row == 3) {
            _nextDetails.text = @"";
        }
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
        } else if ([nameOfField isEqualToString:@"endTime"]) {
            self.endTime.text = date;
        } else if ([nameOfField isEqualToString:@"nextStartTime"]) {
            self.nextStartTime.text = date;
        } else if ([nameOfField isEqualToString:@"nextEndTime"]) {
            self.nextEndTime.text = date;
        }
    };
    
    [self showPopup:timeViewController];
}

- (void) showCalendar: (NSString*) initialDate {
    [self.view endEditing:YES];
    
    BirthdayCalendarViewController *calendarViewController = [[UIStoryboard storyboardWithName:@"AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.initialDate = initialDate;
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
        } else if ([nameOfField isEqualToString:@"endDate"]){
            self.endDate.text = date;
            if (self.endTime.text.length == 0) {
                self.endTime.text = @"17:00";
            }
        } else if ([nameOfField isEqualToString:@"nextStartDate"]) {
            self.nextStartDate.text = date;
            if (self.nextStartTime.text.length == 0) {
                self.nextStartTime.text = @"09:00";
            }
            if (_nextEndDate.text.length == 0) {
                _nextEndDate.text = date;
            }
            if (self.nextEndTime.text.length == 0) {
                self.nextEndTime.text = @"17:00";
            }
        } else if ([nameOfField isEqualToString:@"nextEndDate"]){
            self.endDate.text = date;
            if (self.nextEndTime.text.length == 0) {
                self.nextEndTime.text = @"17:00";
            }
        }
    };
    [self showPopup:calendarViewController];
}

- (void) showStaffAutocomplete {
    [self.view endEditing:YES];
    
    StaffAutoComplete *vc = [[UIStoryboard storyboardWithName:@
                                   "AddCourt" bundle:nil] instantiateViewControllerWithIdentifier:@"StaffAutoComplete"];
    vc.url = vc.url = [NSString stringWithFormat:@"%@%@&search=", STAFF_GET_URL , @"attest"];
    vc.updateHandler =  ^(StaffModel* model) {
        self.counselAttended.text = model.name;
    };
    [self showPopup:vc];
}

- (void) showDetailAutocomplete:(NSString*) url {
    [self.view endEditing:YES];
    
    DetailWithAutocomplete *vc = [[UIStoryboard storyboardWithName:@
                                   "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailWithAutocomplete"];
    vc.url = url;
    vc.updateHandler =  ^(CodeDescription* model) {
        if ([selectedDetails isEqualToString: @"Court Decision"]) {
            _courtDecision.text = model.descriptionValue;
            selectedDecisionCode = model.codeValue;
        } else if ([selectedDetails isEqualToString:@"First Details"]) {
             self.details.text = model.descriptionValue;
        } else {
             self.nextDetails.text = model.descriptionValue;
        }
    };
    [self showPopup:vc];
}

#pragma mark - ContactListWithCodeSelectionDelegate
- (void) didSelectList:(UIViewController *)listVC name:(NSString*) name withModel:(CodeDescription *)model
{
    if ([name isEqualToString:@"natureOfHearing"]) {
        self.natureOfHearing.text = model.descriptionValue;
        selectedNatureOfHearing = model.codeValue;
    } else if ([name isEqualToString:@"nextNatureOfHearing"]) {
        self.nextNatureOfHearing.text = model.descriptionValue;
        selectedNatureOfHearing = model.codeValue;
    } else if ([name isEqualToString:@"Next Date Type"]) {
        self.nextDateType.text = model.descriptionValue;
        selectedNextDateTypeCode = model.codeValue;
        _nextDetails.text = _details.text;
        _nextEnclosureNo.text = _enclosureNo.text;
        _nextNatureOfHearing.text = _natureOfHearing.text;
        _nextStartDate.text = _startDate.text;
        _nextStartTime.text = _startTime.text;
        _nextEndDate.text = _endDate.text;
        _nextEndTime.text = _endTime.text;
        [self.tableView reloadData];
    } else if ([name isEqualToString:@"Attendant Type"]) {
        _attendedStatus.text = model.descriptionValue;
        selectedAttendedStatus = model.codeValue;
    }
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:kMatterLitigationSegue sender:nil];
        } else if (indexPath.row == 5) {
            [self performSegueWithIdentifier:kCourtDiarySegue sender:nil];
        } else if (indexPath.row == 7) {
            titleOfList = @"List of Hearing Type";
            nameOfField = @"natureOfHearing";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_HEARINGTYPE_GET_URL];
        } else if (indexPath.row == 8) { // Details
            selectedDetails = @"First Details";
            [self showDetailAutocomplete:COURT_HEARINGDETAIL_GET_URL];
        } else if (indexPath.row == 9) { // Assigned
            selectedStaff = @"Counsel Assigned";
            [self performSegueWithIdentifier:kStaffSegue sender:@"attest"];
        }
        if (_courtDiary != nil) {
            if (indexPath.row == 10) { // Attendant Type
                titleOfList = @"Attendant Type";
                nameOfField = @"Attendant Type";
                [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_ATTENDED_STATUS_GET_URL];
            } else if (indexPath.row == 11) { // Counsel Attended
                [self showStaffAutocomplete];
            } else if (indexPath.row == 12) { // Coram
                [self performSegueWithIdentifier:kCoramListSegue sender:nil];
            } else if (indexPath.row == 14) { // Decision
                selectedDetails = @"Court Decision";
                [self showDetailAutocomplete:COURT_DECISION_GET_URL];
            } else if (indexPath.row == 16) { // Decision
                if (![_courtDiary.nextDateType.codeValue isEqualToString:@"0"]) {
                    titleOfList = @"Next Date Type";
                    nameOfField = @"Next Date Type";
                    [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_NEXTDATE_TYPE_GET_URL];
                }
            }
        }
    } else {
        if (![_courtDiary.nextDateType.codeValue isEqualToString:@"0"]) {
            if (indexPath.row == 3) {
                titleOfList = @"List of Hearing Type";
                nameOfField = @"nextNatureOfHearing";
                [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_HEARINGTYPE_GET_URL];
            } else if (indexPath.row == 4) { // Details
                selectedDetails = @"Next Details";
                [self showDetailAutocomplete:COURT_HEARINGDETAIL_GET_URL];
            }
        }
    }
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kMatterLitigationSegue]) {
        MatterLitigationViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterLitigationModel *model) {
            self.fileNo.text = model.systemNo;
            self.caseNo.text = model.courtInfo.caseNo;
            self.caseName.text = model.courtInfo.caseName;
        };
    } else if ([segue.identifier isEqualToString:kCourtDiarySegue]) {
        CourtDiaryListViewController* courtVC = segue.destinationViewController;
        courtVC.updateHandler = ^(CourtDiaryModel *model) {
            self.placeType.text = model.place;
            self.place.text = model.typeCase;
            selectedCourtCode = model.courtDiaryCode;
        };
    } else if ([segue.identifier isEqualToString:kStaffSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        StaffViewController* staffVC = navVC.viewControllers.firstObject;
        staffVC.typeOfStaff = sender;
        staffVC.updateHandler = ^(NSString* typeOfStaff, StaffModel* model) {
            self.councilAssigned.text = model.name;
            selectedAssignedCode = model.staffCode;
        };
    } else if ([segue.identifier isEqualToString:kListWithCodeSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        ListWithCodeTableViewController *listCodeVC = navVC.viewControllers.firstObject;
        listCodeVC.delegate = self;
        listCodeVC.titleOfList = titleOfList;
        listCodeVC.name = nameOfField;
        listCodeVC.url = sender;
    } else if ([segue.identifier isEqualToString:kCoramListSegue]) {
        CoramListViewController* coramVC = segue.destinationViewController;
        coramVC.updateHandler = ^(CoramModel *model) {
            _coram.text = model.name;
            selectedCoramCode = model.coramCode;
        };
    }
}


@end
