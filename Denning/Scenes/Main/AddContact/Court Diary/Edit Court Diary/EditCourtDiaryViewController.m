//
//  EditCourtDiaryViewController.m
//  Denning
//
//  Created by DenningIT on 08/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "EditCourtDiaryViewController.h"
#import "FloatingTextCell.h"
#import "StaffViewController.h"
#import "BirthdayCalendarViewController.h"
#import "ListWithCodeTableViewController.h"
#import "CoramListViewController.h"

@interface EditCourtDiaryViewController ()
<UIDocumentInteractionControllerDelegate, UITableViewDelegate, UITableViewDataSource, ContactListWithDescSelectionDelegate, ContactListWithCodeSelectionDelegate, UITextFieldDelegate>
{
    NSString *titleOfList;
    NSString* nameOfField;
    __block NSString *isRental;
    __block NSString* issueToFirstCode;
    __block BOOL isLoading;
    __block BOOL isSaved;
    
    NSInteger selectedRow;
    NSInteger selectedIndexPath;
    
    NSString* selectedCoramCode;
    NSString* attendedStatusCode;
    NSString* nextDateTypeCode;
    NSInteger selectedSection;
}

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) NSMutableArray *contents;
@property (strong, nonatomic) NSArray* addOn;
@property (nonatomic, strong) NSMutableArray *headers;

@property (strong, nonatomic)
NSMutableDictionary* keyValue;
@end

@implementation EditCourtDiaryViewController
@synthesize courtModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNib];
}
- (void) prepareUI {
    self.keyValue = [@{@(0): @(1), @(1): @(0)} mutableCopy];
    _addOn = @[@[@"Next date", @""], @[@"Next Time", @""], @[@"Enclosure No", @""], @[@"Next Nature of Hearing", @""], @[@"Next Details.", @""], @[@"Next Remarks.", @""]];
    
    _contents = [@[@[@[@"File No", courtModel.fileNo1], @[@"Previous Date", courtModel.previousDate], @[@"Present Hearing Date", courtModel.hearingStartDate], @[@"Enclosure No", self.courtModel.enclosureNo], @[@"Hearing Type", self.courtModel.hearingType], @[@"Details",self.courtModel.enclosureDetails], @[@"Counsel Assigned", self.courtModel.counselAssigned], @[@"Attendant Type", self.courtModel.attendedStatus.descriptionValue], @[@"Counsel Attended", courtModel.counselAttended], @[@"Coram", courtModel.coram.name], @[@"Opponent's Counsel", @""], @[@"Court Decision", courtModel.courtDecision], @[@"Select Next Date Type", courtModel.nextDateType.descriptionValue]], @[]] mutableCopy];
    
    _headers = [@[@"Court Diary", @"Next Date"
                  ] mutableCopy];

    if ([courtModel.nextDateType.codeValue isEqualToString:@"0"]) {
        [self addNextDate];
    }
    
    selectedCoramCode = courtModel.coram.coramCode;
    attendedStatusCode = courtModel.attendedStatus.codeValue;
    nextDateTypeCode = courtModel.nextDateType.codeValue	;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
//        [self.tableView scrollRectToVisible:activeField.frame animated:YES];
//    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void) removeNextDate {
    NSMutableArray* newArray = [NSMutableArray new];
    for (int i = 0; i < self.tableView.numberOfSections; i++) {
        newArray[i] = [NSMutableArray new];
        for (int j = 0; j < [_contents[i] count]; j++) {
            newArray[i][j]  = [NSMutableArray new];
            [newArray[i][j] addObject:_contents[i][j][0]];
            [newArray[i][j] addObject:_contents[i][j][1]];
        }
    }
    
     _contents = newArray;
   _headers = [@[@"Court Diary"
       ] mutableCopy];
    self.keyValue = [@{ @(0): @(1)} mutableCopy];
}

- (void) addNextDate {
    NSMutableArray* newArray = [NSMutableArray new];
    for (int i = 0; i < self.tableView.numberOfSections; i++) {
        newArray[i] = [NSMutableArray new];
        for (int j = 0; j < [_contents[i] count]; j++) {
            newArray[i][j]  = [NSMutableArray new];
            [newArray[i][j] addObject:_contents[i][j][0]];
            [newArray[i][j] addObject:_contents[i][j][1]];
        }
    }
    newArray[1] = [NSMutableArray new];
    for (int j = 0; j < [_addOn count]; j++) {
        newArray[1][j] = [NSMutableArray new];
        [newArray[1][j] addObject:_addOn[j][0]];
        [newArray[1][j] addObject:_addOn[j][1]];
    }
    
    _contents = newArray;
    
    _headers = [@[@"Court Diary", @"Next Date Details"
       ] mutableCopy];
    
    self.keyValue = [@{ @(0): @(1), @(1): @(1)} mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    
    TimePickerViewController *timeViewController = [[UIStoryboard storyboardWithName:@
                                                     "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"TimePickerView"];
    timeViewController.updateHandler =  ^(NSString* date) {
        if ([nameOfField isEqualToString:@"nextTime"]) {
            [self replaceContentForSection:1 InRow:1 withValue:date];
        }
    };
    
    [self showPopup:timeViewController];
}

- (void) showCalendar {
    [self.view endEditing:YES];
    
    BirthdayCalendarViewController *calendarViewController = [[UIStoryboard storyboardWithName:@
                                                               "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        if ([nameOfField isEqualToString:@"nextDate"]) {
            [self replaceContentForSection:1 InRow:0 withValue:date];
        }
    };
    [self showPopup:calendarViewController];
}

- (NSString*) getValidValue: (NSString*) value
{
    if (value == nil) {
        return @"";
    }
    else {
        return value;
    }
    
    return value;
}

- (IBAction)updateCourtDiary:(id)sender {
    NSString* nextDate = @"", *enclosureDetails = @"", *remark = courtModel.remarks;
    if ([_contents[0][12][1] isEqualToString:@"0"]) {
        nextDate = [DIHelpers convertDateToMySQLFormat:[NSString stringWithFormat:@"%@ %@", _contents[1][0][1], _contents[1][1][1]]];
        enclosureDetails = _contents[1][3][1];
        remark = _contents[1][5][1];
    }
    NSDictionary* data = @{
                           @"code":courtModel.courtCode,
                           @"attendedStatus": @{
                               @"code": attendedStatusCode,
                               @"description": _contents[0][7][1]
                           },
                           @"coram":
                               @{
                                   @"code": selectedCoramCode},
                           @"counselAssigned": _contents[0][6][1],
                           @"counselAttended": _contents[0][8][1],
                           @"court": @"",
                           @"courtDecision": _contents[0][11][1],
                           @"enclosureDetails": @"Hearing Type 1",
                           @"enclosureNo": courtModel.enclosureNo,
                           @"enclosureDetails": enclosureDetails,
                           @"fileNo1": courtModel.fileNo1,
                           @"hearingDate": courtModel.hearingStartDate,
                           @"hearingType": _contents[0][4][1],
                           @"nextDate": nextDate,
                           @"nextDateType": @{
                               @"code": nextDateTypeCode,
                               @"description": _contents[0][12][1]
                           },
                           @"opponentCounsel": _contents[0][10][1],
                           @"previousDate": courtModel.previousDate,
                           @"remark": remark
                           };
    if (isLoading) return;
    isLoading = YES;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] updateCourtDiaryWithData:data WithCompletion:^(EditCourtModel * _Nonnull model, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully updated" duration:1.0];
            self->isSaved = YES;
//            [self updateWholeData:model];
            
        } else {
            [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}

- (void) registerNib {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    
    self.tableView.allowMultipleSectionsOpen = YES;
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(1), @(0), nil];
      // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [FloatingTextCell registerForReuseInTableView:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contents[section] count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void) updateWholeData: (NSDictionary*) result {
    NSString* relatedDocumentNo = [result objectForKeyNotNull:@"relatedDocumentNo"];
    isRental =  [result objectForKeyNotNull:@"isRental"];
    issueToFirstCode =  [result objectForKeyNotNull:@"issueTo1stCode"];
    NSString* issueToName =  [result objectForKeyNotNull:@"issueToName"];
    NSString* documentNo = [result objectForKeyNotNull:@"documentNo"];
    NSString* fileNo = [result objectForKeyNotNull:@"fileNo"];
    NSString* matterCode = [result objectForKeyNotNull:@"matter"];
    NSString* presetCode = [result objectForKeyNotNull:@"presetCode"];
    NSString* rentalMonth = [result objectForKeyNotNull:@"rentalMonth"];
    NSString* rentalPrice = [result objectForKeyNotNull:@"rentalPrice"];
    NSString* spaLoan = [result objectForKeyNotNull:@"spaLoan"];
    NSString* spaPrice = [result objectForKeyNotNull:@"spaPrice"];
    
    [self replaceContentForSection:0 InRow:0 withValue:relatedDocumentNo];
    [self replaceContentForSection:0 InRow:1 withValue:documentNo];
    [self replaceContentForSection:0 InRow:2 withValue:fileNo];
    [self replaceContentForSection:0 InRow:3 withValue:matterCode];
    [self replaceContentForSection:0 InRow:4 withValue:issueToName];
    [self replaceContentForSection:0 InRow:5 withValue:presetCode];
    [self replaceContentForSection:0 InRow:6 withValue:spaPrice];
    [self replaceContentForSection:0 InRow:7 withValue:spaLoan];
    [self replaceContentForSection:0 InRow:8 withValue:rentalMonth];
    [self replaceContentForSection:0 InRow:9 withValue:rentalPrice];
    
    [self updateBelowViewWithData:[result objectForKeyNotNull:@"analysis"]];
}

- (void) updateBelowViewWithData: (NSDictionary*) result {
    NSString* iFee = [result objectForKeyNotNull:@"iFee"];
    NSString* iDisbTax = [result objectForKeyNotNull:@"iDisbTax"];
    NSString* iDisbOnly = [result objectForKeyNotNull:@"iDisbOnly"];
    NSString* iGST = [result objectForKeyNotNull:@"iGST"];
    NSString* iTotal = [result objectForKeyNotNull:@"iTotal"];
    
    [self replaceContentForSection:1 InRow:0 withValue:iFee];
    [self replaceContentForSection:1 InRow:1 withValue:iDisbTax];
    [self replaceContentForSection:1 InRow:2 withValue:iDisbOnly];
    [self replaceContentForSection:1 InRow:3 withValue:iGST];
    [self replaceContentForSection:1 InRow:4 withValue:iTotal];
}


- (NSInteger) calcTag: (NSIndexPath*) indexPath {
    NSInteger tag = 0;
    for (int i = 0; i < [_contents count]; i++) {
        if (i < indexPath.section) {
            tag += [_contents[i] count];
        }
    }
    
    tag += indexPath.row;
    
    return tag;
}

- (NSArray*) calcSectionNumber: (NSInteger) tag {
    NSInteger section = 0;
    NSInteger remain = tag;
    for (int i = 0; i < self.tableView.numberOfSections; i++) {
        section = i;
        if (remain - (NSInteger)[_contents[i] count] < 0) {
            break;
        }
        remain = (remain - (NSInteger)[_contents[i] count]);
    }
    
    return @[@(section), @(remain)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    
    FloatingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[FloatingTextCell cellIdentifier] forIndexPath:indexPath];
    
    int rows = (int)indexPath.row;
    cell.floatingTextField.placeholder = self.contents[indexPath.section][rows][0];
    cell.floatingTextField.text = [NSString stringWithFormat:@"%@", self.contents[indexPath.section][rows][1]];
    cell.floatingTextField.floatLabelActiveColor = cell.floatingTextField.floatLabelPassiveColor = [UIColor redColor];
    cell.floatingTextField.delegate = self;
    cell.floatingTextField.inputAccessoryView = accessoryView;
    cell.floatingTextField.tag = [self calcTag:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.floatingTextField.userInteractionEnabled = YES;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 8 || indexPath.row == 9 || indexPath.row == 11 || indexPath.row == 12) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.floatingTextField.userInteractionEnabled = NO;
        }
        
        if (indexPath.row == 0) {
            cell.floatingTextField.userInteractionEnabled = NO;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0 || indexPath.row == 1 ||indexPath.row == 3 || indexPath.row == 4) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.floatingTextField.userInteractionEnabled = NO;
        }
    }
 
    return cell;
}

- (void)handleTap {
    [self.view endEditing:YES];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSArray* info = [self calcSectionNumber:textField.tag];
    [self replaceContentForSection:[info[0] integerValue] InRow:[info[1] integerValue] withValue:textField.text];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kDefaultAccordionHeaderViewHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (void)reloadHeaders {
    for (NSInteger i = 0; i < [self numberOfSectionsInTableView:self.tableView]; i++) {
        AccordionHeaderView *headerView = (AccordionHeaderView *)[self.tableView headerViewForSection:i];
        if ([self.keyValue[[NSNumber numberWithInteger:i]] integerValue] == 0) {
            [UIView animateWithDuration:0.1f animations:^{
                
                headerView.expandImage.image = [UIImage imageNamed:@"expandableImage"];
                
            } completion:nil];
        } else {
            [UIView animateWithDuration:0.1f animations:^{
                
                headerView.expandImage.image = [UIImage imageNamed:@"expandableImage_reverse"];
                
            } completion:nil];
        }
    }
}

- (AccordionHeaderView*) updateCustomSectionHeaderInSection:(NSInteger) section withTableView:(UITableView*) tableView {
    AccordionHeaderView* headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kAccordionHeaderViewReuseIdentifier];
    headerView.headerTitle.text = self.headers[section];
    
    if ([self.keyValue[[NSNumber numberWithInteger:section]] integerValue] == 0) {
        [UIView animateWithDuration:0.1f animations:^{
            
            headerView.expandImage.image = [UIImage imageNamed:@"expandableImage"];
            
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.1f animations:^{
            
            headerView.expandImage.image = [UIImage imageNamed:@"expandableImage_reverse"];
            
        } completion:nil];
    }
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self updateCustomSectionHeaderInSection:section withTableView:tableView];
}

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedRow = indexPath.row;
    selectedSection = indexPath.section;

    if (indexPath.section == 0) {
        if (indexPath.row == 4) {
            titleOfList = @"Select Hearing Type";
            nameOfField = @"natureOfHearing";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_HEARINGTYPE_GET_URL];
        } else if (indexPath.row == 6 || indexPath.row == 8) {
            [self performSegueWithIdentifier:kStaffSegue sender:@"attest"];
        } else if (indexPath.row == 7) {
            titleOfList = @"Select Attendant Type";
            nameOfField = @"attendantType";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_ATTENDED_STATUS_GET_URL];
        } else if (indexPath.row == 9) {
            [self performSegueWithIdentifier:kCoramListSegue sender:nil];
        } else if (indexPath.row == 11) {
            titleOfList = @"Select Court Decision";
            nameOfField = @"CourtDecision";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_DECISION_GET_URL];
        } else if (indexPath.row == 12) {
            titleOfList = @"Select NEXTDATE TYPE";
            nameOfField = @"NextDateType";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_NEXTDATE_TYPE_GET_URL];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            nameOfField = @"nextDate";
            [self showCalendar];
        } else if (indexPath.row == 1) {
            nameOfField = @"nextTime";
            [self showTimePicker];
        } else if (indexPath.row == 3) {
            titleOfList = @"Select Hearing Type";
            nameOfField = @"nextNatureOfHearing";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_HEARINGTYPE_GET_URL];
        } else if ( indexPath.row == 4) {
            titleOfList = @"Select Hearing Details";
            nameOfField = @"nextDetails";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:COURT_HEARINGDETAIL_GET_URL];
        }
    }
}

#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    self.keyValue[[NSNumber numberWithInteger:section]] = @(1);
    [self reloadHeaders];
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
    self.keyValue[[NSNumber numberWithInteger:section]] = @(0);
    [self reloadHeaders];
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

#pragma mark - ContactListWithDescriptionDelegate
- (void) didSelectListWithDescription:(UIViewController *)listVC name:(NSString*) name withString:(NSString *)description
{
    for (int i = 0; i < self.tableView.numberOfSections; i ++) {
        for (int j = 0; j < [_contents[i] count]; j++) {
            if ([name isEqualToString:_contents[i][j][0]]) {
                [self replaceContentForSection:i InRow:j withValue:description];
            }
        }
    }
}

- (void) replaceContentForSection:(NSInteger) section InRow:(NSInteger) row withValue:(NSString*) value{
    if (value == nil) {
        value = @"";
    }
    
    NSMutableArray *newArray = [NSMutableArray new];
    for (int i = 0; i < self.tableView.numberOfSections; i++) {
        newArray[i] = [NSMutableArray new];
        
        for (int j = 0; j < [_contents[i] count]; j++) {
            newArray[i][j] = [NSMutableArray new];
            [newArray[i][j] addObject:_contents[i][j][0]];
            if (i == section && j == row) {
                [newArray[i][j] addObject:value];
            } else {
                [newArray[i][j] addObject:_contents[i][j][1]];
            }
        }
    }
    
    self.contents = [newArray copy];
    [self.tableView reloadData];
}


#pragma mark - ContactListWithCodeSelectionDelegate
- (void) didSelectList:(UIViewController *)listVC name:(NSString*) name withModel:(CodeDescription *)model
{
    if ([name isEqualToString:@"natureOfHearing"]) {
        [self replaceContentForSection:0 InRow:5 withValue:model.descriptionValue];
    } else if ([name isEqualToString:@"CourtDecision"]) {
        [self replaceContentForSection:0 InRow:11 withValue:model.descriptionValue];
    } else if ([name isEqualToString:@"NextDateType"]) {
        [self replaceContentForSection:0 InRow:12 withValue:model.descriptionValue];
        nextDateTypeCode = model.codeValue;
        if ([nextDateTypeCode isEqualToString:@"0"]) {
            [self addNextDate];
            [self.tableView reloadData];
        } else if ([nextDateTypeCode isEqualToString:@"1"]) {
            [self removeNextDate];
            [self.tableView reloadData];
        } else {
            [self removeNextDate];
            [self.tableView reloadData];
        }
    } else if ([name isEqualToString:@"attendantType"]) {
        [self replaceContentForSection:0 InRow:7 withValue:model.descriptionValue];
        attendedStatusCode = model.codeValue;
    } else if ([name isEqualToString:@"nextNatureOfHearing"]) {
        [self replaceContentForSection:1 InRow:3 withValue:model.descriptionValue];
    } else if ([name isEqualToString:@"nextDetails"]) {
        [self replaceContentForSection:1 InRow:4 withValue:model.descriptionValue];
    }
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
    }
    
    if ([segue.identifier isEqualToString:kStaffSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        StaffViewController* staffVC = navVC.viewControllers.firstObject;
        staffVC.typeOfStaff = sender;
        staffVC.updateHandler = ^(NSString* typeOfStaff, StaffModel* model) {
            if (selectedRow == 6) {
                [self replaceContentForSection:0 InRow:6 withValue:model.name];
            } else if (selectedRow == 8) {
                [self replaceContentForSection:0 InRow:8 withValue:model.name];
            }
            
        };
    }
    
    if ([segue.identifier isEqualToString:kCoramListSegue]) {
        CoramListViewController* coramVC = segue.destinationViewController;
        coramVC.updateHandler = ^(CoramModel *model) {
            [self replaceContentForSection:0 InRow:9 withValue:model.name];
            selectedCoramCode = model.coramCode;
        };
    }
}


@end
