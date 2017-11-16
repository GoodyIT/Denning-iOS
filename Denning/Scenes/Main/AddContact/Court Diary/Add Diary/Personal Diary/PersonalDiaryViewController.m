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
<UITextFieldDelegate, SWTableViewCellDelegate>
{
    NSString* titleOfList;
    NSString* nameOfField;
    
    NSString* selectedNatureOfHearing;
    NSString* selectedDetails;
    
    CGFloat autocompleteCellHeight;
    
    __block BOOL isLoading;
    NSString* serverAPI;
}

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *startDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *startTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endDate;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endTime;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *place;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *staffAssigned;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *details;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *Remarks;

@property (strong, nonatomic) UIToolbar *accessoryView;

@property (weak, nonatomic) IBOutlet SWTableViewCell *detailsCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *startDateCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *endDateCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *placeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *staffAssignedCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *remarksCell;

@end

@implementation PersonalDiaryViewController

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

- (void) saveDiary {
    NSString* endDate = [NSString stringWithFormat:@"%@ %@", self.endDate.text, self.endTime.text];
    NSString* startDate = [NSString stringWithFormat:@"%@ %@", self.startDate.text, self.startTime];
    NSDictionary* data = @{
                           @"appointmentDetails":self.details.text,
                           @"attendedStatus": @{
                                   @"code": @"",
                            },
                           @"endDate":endDate,
                           @"startDate": startDate,
                           @"staffAssigned": @{
                                   @"code":_staffAssigned.text
                                   },
                           @"place": _place.text,
                           @"enclosureDetails": self.details.text,
                           
                           @"remark": self.Remarks.text
                           };
    if (isLoading) return;
    isLoading = YES;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] savePersonalDiaryWithData:data WithCompletion:^(EditCourtModel * _Nonnull result, NSError * _Nonnull error) {
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
    
    return 6;
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
        self.staffAssignedCell.leftUtilityButtons = [self leftButtons];
        self.staffAssignedCell.delegate = self;
        return self.staffAssignedCell;
    } else if (indexPath.row == 4) {
        self.detailsCell.leftUtilityButtons = [self leftButtons];
        self.detailsCell.delegate = self;
        return self.detailsCell;
    } else if (indexPath.row == 5) {
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
        self.staffAssigned.text = @"";
    } else if (indexPath.row == 4) {
        self.details.text = @"";
    } else if (indexPath.row == 5) {
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
    vc.url = COURT_PERSONAL_DETAIL_GET_LIST_URL;
    vc.updateHandler =  ^(CodeDescription* model) {
        self.details.text = model.descriptionValue;
    };
    [self showPopup:vc];
}

- (void) showAutocomplete:(NSString*) url {
    [self.view endEditing:YES];
    
    SimpleAutocomplete *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SimpleAutocomplete"];
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
        [self performSegueWithIdentifier:kStaffSegue sender:@"attest"];
    } if (indexPath.row == 4) {
        nameOfField = @"Details";
        [self showAutocomplete:COURT_PERSONAL_DETAIL_GET_LIST_URL];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kStaffSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        StaffViewController* staffVC = navVC.viewControllers.firstObject;
        staffVC.typeOfStaff = sender;
        staffVC.updateHandler = ^(NSString* typeOfStaff, StaffModel* model) {
            self.staffAssigned.text = model.name;
        };
    }
}


@end
