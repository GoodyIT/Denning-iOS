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
#import "SimpleMatterViewController.h"
#import "MatterLitigationViewController.h"
#import "CourtDiaryListViewController.h"
#import "ClientModel.h"


@interface CourtDiaryViewController ()
< UITextFieldDelegate, SWTableViewCellDelegate, ContactListWithCodeSelectionDelegate>
{
    NSString* titleOfList;
    NSString* nameOfField;
    NSString* url;
    
    NSString* selectedNatureOfHearing;
    NSString* selectedDetails;
    NSString* selectedCourtDiaryCode;
    
    CGFloat autocompleteCellHeight;
    
    __block BOOL isLoading;
    NSString* serverAPI;
}

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *fileNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *caseNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *caseName;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *startDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *startTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *place;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *councilAssigned;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *details;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *Remarks;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *natureOfHearing;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *enclosureNo;

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
@property (weak, nonatomic) IBOutlet SWTableViewCell *remarksCell;


@property (strong, nonatomic) UIToolbar *accessoryView;

@end

@implementation CourtDiaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareUI {
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
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (void) saveDiary {
    NSDictionary* data = @{
                           @"attendedStatus": @{
                                   @"code": @"",
                                   @"description": @"Postponed"
                                   },
                           @"coram":
                               @{
                                   @"code": @""},
                           @"counselAssigned": self.councilAssigned.text,
                           @"counselAttended": @"",
                           @"court": @"",
                           @"courtDecision": @"",
                           @"enclosureDetails": self.details.text,
                           @"enclosureNo": self.enclosureNo.text,
                           @"fileNo1": self.fileNo.text,
                           @"hearingDate": [NSString stringWithFormat:@"%@ %@", self.startDate.text, self.startTime.text],
                           @"hearingType": selectedNatureOfHearing,
                           @"nextDate": [NSString stringWithFormat:@"%@ %@", self.endDate.text, self.endTime.text],
                           @"nextDateType": @{
                                   @"code": @"0",
                                   @"description":@"Yes, set next appointment"
                                   },
                           @"previousDate": @"2016-12-09 00:00:00",
                           @"remark": self.Remarks.text
                           };
    if (isLoading) return;
    isLoading = YES;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] saveCourtDiaryWithData:data WithCompletion:^(EditCourtModel * _Nonnull result, NSError * _Nonnull error) {
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
    
    return 11;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
        self.councilAssignedCell.leftUtilityButtons = [self leftButtons];
        self.councilAssignedCell.delegate = self;
        return self.councilAssignedCell;
    } else if (indexPath.row == 9) {
        self.detailsCell.leftUtilityButtons = [self leftButtons];
        self.detailsCell.delegate = self;
        return self.detailsCell;
    } else if (indexPath.row == 10) {
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

    if (indexPath.row == 0) {
        self.fileNo.text = @"";
    } else if (indexPath.row == 1) {
        self.caseNo.text = @"";
    } else if (indexPath.row == 2) {
        self.caseName.text = @"";
    } else if (indexPath.row == 5) {
        self.place.text = @"";
    } else if (indexPath.row == 6) {
        self.enclosureNo.text = @"";
    } else if (indexPath.row == 7) {
        self.natureOfHearing.text = @"";
    } else if (indexPath.row == 8) {
        self.councilAssigned.text = @"";
    } else if (indexPath.row == 9) {
        self.details.text = @"";
    } else if (indexPath.row == 10) {
        self.Remarks.text = @"";
    }
}

- (void) showPopup: (UIViewController*) vc {
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:vc];
    [STPopupNavigationBar appearance].barTintColor = [UIColor colorWithRed:0.20f green:0.60f blue:0.86f alpha:1.0f];
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

- (void) showTimePicker {
    [self.view endEditing:YES];
    
    TimePickerViewController *timeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TimePickerView"];
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
    
    BirthdayCalendarViewController *calendarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        if ([nameOfField isEqualToString:@"startDate"]) {
            self.startDate.text = date;
        } else {
            self.endDate.text = date;
        }
    };
    [self showPopup:calendarViewController];
}

- (void) showDetailAutocomplete {
    [self.view endEditing:YES];
    
    DetailWithAutocomplete *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailWithAutocomplete"];
    vc.url = COURT_HEARINGDETAIL_GET_URL;
    vc.updateHandler =  ^(CodeDescription* model) {
        self.details.text = model.descriptionValue;
    };
    [self showPopup:vc];
}


#pragma mark - ContactListWithCodeSelectionDelegate
- (void) didSelectList:(UIViewController *)listVC name:(NSString*) name withModel:(CodeDescription *)model
{
    if ([name isEqualToString:@"natureOfHearing"]) {
        self.natureOfHearing.text = model.descriptionValue;
        selectedNatureOfHearing = model.codeValue;
    }
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:kMatterLitigationSegue sender:nil];
    } else if (indexPath.row == 5) {
        [self performSegueWithIdentifier:kCourtDiarySegue sender:nil];
    } else if (indexPath.row == 7) {
        titleOfList = @"List of Hearing Type";
        nameOfField = @"natureOfHearing";
        [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_HEARINGTYPE_GET_URL];
    } else if (indexPath.row == 8) {
        [self performSegueWithIdentifier:kStaffSegue sender:@"attest"];
    } if (indexPath.row == 9) {
        [self showDetailAutocomplete];
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
            self.caseNo.text = model.primaryClient.IDNo;
            self.caseName.text = model.primaryClient.name;
        };
    }
    
    if ([segue.identifier isEqualToString:kCourtDiarySegue]) {
        CourtDiaryListViewController* courtVC = segue.destinationViewController;
        courtVC.updateHandler = ^(CourtDiaryModel *model) {
            self.place.text = model.typeE;
            selectedCourtDiaryCode = model.courtDiaryCode;
        };
    }
    
    if ([segue.identifier isEqualToString:kStaffSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        StaffViewController* staffVC = navVC.viewControllers.firstObject;
        staffVC.typeOfStaff = sender;
        staffVC.updateHandler = ^(NSString* typeOfStaff, StaffModel* model) {
            self.councilAssigned.text = model.name;
        };
    }
    
    if ([segue.identifier isEqualToString:kListWithCodeSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        ListWithCodeTableViewController *listCodeVC = navVC.viewControllers.firstObject;
        listCodeVC.delegate = self;
        listCodeVC.titleOfList = titleOfList;
        listCodeVC.name = nameOfField;
        listCodeVC.url = sender;
    }
}


@end
