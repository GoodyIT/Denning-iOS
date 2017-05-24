//
//  AddMatterViewController.m
//  Denning
//
//  Created by DenningIT on 08/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddMatterViewController.h"
#import "FloatingTextCell.h"
#import "PropertyContactListViewController.h"
#import "ListWithDescriptionViewController.h"
#import "ListWithCodeTableViewController.h"
#import "ListOfMatterViewController.h"
#import "StaffViewController.h"
#import "PropertyListViewController.h"
#import "BranchListViewController.h"
#import "SolicitorListViewController.h"
#import "PropertyViewController.h"
#import "ContactViewController.h"
#import "BankViewController.h"
#import "AddLastOneButtonCell.h"
#import "AddMatterCell.h"
#import "BirthdayCalendarViewController.h"
#import "CommonTextCell.h"

@interface AddMatterViewController ()<UITableViewDelegate, UITableViewDataSource,
ContactListWithCodeSelectionDelegate,UITextFieldDelegate, SWTableViewCellDelegate>
{
    NSString *titleOfList;
    NSString* nameOfField;
    __block BOOL isLoading;
    __block BOOL isSaved;
    
    NSNumber* selectedFileStatusCode;
    NSNumber* selectedPartnerCode;
    NSNumber* selectedLACode;
    NSNumber* selectedClerkCode;
    NSNumber* selectedPrimaryClientCode;
    NSNumber* selectedMatterCode;
    
    NSMutableArray* partyVendorCodeList, *partyVendorNameList;
    NSMutableArray* partyPurchaserCodeList, *partyPurchaserNameList;
    NSMutableArray* partyCustomerGroup3CodeList, *partyCustomerGroup3NameList;
    NSMutableArray* partyCustomerGroup4CodeList, *partyCustomerGroup4NameList;
    
    NSMutableArray *bankCodeList, *bankNameList;
    
    NSMutableArray* solicitorCodeList, *solicitorNameList, *solicitorRefList;
    NSMutableArray *propertyCodeList, *propertyFullTitleList, *propertyAdressList;
    
    NSString* newLabel, *newValue;
    NSInteger selectedContactRow, selectedSection;
    __block BOOL isAddNew;
}
@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSArray *headers;
@property (strong, nonatomic)
NSMutableDictionary* keyValue;

@end

@implementation AddMatterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNib];
}

- (void) prepareUI {
    self.keyValue = [@{
                       @(0): @(1), @(1):@(0),
                       @(2):@(0),
                       @(3):@(0),
                       @(4):@(0), @(5):@(0), @(6):@(0)
                       } mutableCopy];
    NSArray* temp = @[
                      @[@[@"File No", @""], @[@"Primary Client", @""], @[@"File Status", @""], @[@"Partner-in-Charge", @""], @[@"LA-in-Charge", @""], @[@"Clert-in-Charge", @""], @[@"Matter", @""], @[@"Physical File", @""], @[@"Box", @""], @[@"Remarks", @""],
                          @[@"Save", @""]
                        ],
                      @[@[@"Vendor", @""],@[@"Purchaser", @""], @[@"Customer Group3", @""], @[@"Customer Group4", @""]],
                      @[@[@"Vendor's Solicitor", @""], @[@"Purchaser's Solicitor", @""], @[@"Customer Group3's Solicitor", @""], @[@"Customer Group4's Solicitor", @""]],
                      @[@[@"Property1", @""], @[@"Property2", @""], @[@"Property3", @""], @[@"Property4", @""], @[@"Property5", @""]],
                      @[@[@"Vendor's Bank", @""], @[@"Purchaser's Bank", @""], @[@"Customer Group3's Bank", @""]],
                      @[@[@"Purchase Price (A)", @""], @[@"Earnest Deposit  (B)", @""], @[@"Balance (C)", @""], @[@"Total Deposit (D) = B + C", @""], @[@"Balance Purchase Price (A)", @""], @[@"Purchase Price (A)", @""], @[@"Purchase Price (A - D)", @""], @[@"GST Amount", @""], @[@"Redemption Sum", @""], @[@"Term Loan Amt", @""], @[@"OD Loan Amt", @""], @[@"+ MRTA", @""], @[@"+ Legal Fee", @""], @[@"+ Other", @""], @[@"Total Loan", @""]],
                      @[@[@"SPA Date", @""], @[@"CP Fulfillment Date", @""], @[@"Completion Date", @""], @[@"Extended Completion date", @""], @[@"Redemption Date", @""], @[@"Bank Instruction Date", @""], @[@"Letter of Offer Date", @""]]
                      ];
    _contents = [temp mutableCopy];
    
    _headers = @[
                 @"Matter Information", @"Parties Group", @"Solicitors", @"Properties", @"Banks", @"Important RM", @"Important Date"
                 ];
    
    partyVendorCodeList = [NSMutableArray new];
    partyVendorNameList = [NSMutableArray new];
    partyPurchaserCodeList = [NSMutableArray new];
    partyPurchaserNameList = [NSMutableArray new];
    partyCustomerGroup3CodeList = [NSMutableArray new];
    partyCustomerGroup3NameList = [NSMutableArray new];
    partyCustomerGroup4CodeList = [NSMutableArray new];
    partyCustomerGroup4NameList = [NSMutableArray new];
    propertyCodeList = [NSMutableArray new];
    for (int i = 0; i < 5; i++) {
        [propertyCodeList addObject:@(0)];
    }
    propertyFullTitleList = [NSMutableArray new];
    for (int i = 0; i < 5; i++) {
        [propertyFullTitleList addObject:@""];
    }
    propertyAdressList = [NSMutableArray new];
    for (int i = 0; i < 5; i++) {
        [propertyAdressList addObject:@""];
    }
    bankCodeList = [NSMutableArray new];
    for (int i = 0; i < 3; i++) {
        [bankCodeList addObject:@(0)];
    }
    bankNameList = [NSMutableArray new];
    for (int i = 0; i < 3; i++) {
        [bankNameList addObject:@""];
    }
    solicitorCodeList = [NSMutableArray new];
    for (int i = 0; i < 4; i++) {
        [solicitorCodeList addObject:@(0)];
    }
    solicitorNameList = [NSMutableArray new];
    for (int i = 0; i < 4; i++) {
        [solicitorNameList addObject:@""];
    }
    solicitorRefList = [NSMutableArray new];
    for (int i = 0; i < 4; i++) {
        [solicitorRefList addObject:@""];
    }
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
}

- (void) addPartyToContents: (NSString*)name code:(NSNumber*) code
{
    NSInteger index = 0;
    NSInteger vendorCount = partyVendorCodeList.count;
    NSInteger purchaserCount = partyPurchaserCodeList.count;
    NSInteger customerGroup3Count = partyCustomerGroup3CodeList.count;
    if (selectedContactRow == 0) { // add party to vendor
        [partyVendorCodeList addObject:code];
        [partyVendorNameList addObject:name];
        index += 1;
    } else if (selectedContactRow == vendorCount+1) {
        index = vendorCount + 2;
        [partyPurchaserCodeList addObject:code];
        [partyPurchaserNameList addObject:name];
    } else if (selectedContactRow == vendorCount+purchaserCount+2) {
        index = vendorCount+purchaserCount+3;
        [partyCustomerGroup3CodeList addObject:code];
        [partyCustomerGroup3NameList addObject:name];
    } else if (selectedContactRow == vendorCount+purchaserCount+ customerGroup3Count + 3) {
        index = vendorCount+purchaserCount+ customerGroup3Count + 4;
        [partyCustomerGroup4CodeList addObject:code];
        [partyCustomerGroup4NameList addObject:name];
    }
    
    BOOL isAdded  = NO;
    NSMutableArray *newArray = [NSMutableArray new];
    for (int i = 0; i < self.tableView.numberOfSections; i++) {
        newArray[i] = [NSMutableArray new];
        int yMax = (int)[_contents[i] count];
        if (i == 1) {
            yMax += 1;
        } else {
            isAdded = NO;
        }
        for (int j = 0; j < yMax; j++) {
            newArray[i][j] = [NSMutableArray new];
            NSInteger yIdx = j;
            if (isAdded) {
                yIdx = j - 1;
            }
            if (j == index && i == 1) {
                [newArray[i][j] addObject:name];
                [newArray[i][j] addObject:code];
                isAdded = YES;
            } else {
                [newArray[i][j] addObject:_contents[i][yIdx][0]];
                [newArray[i][j] addObject:_contents[i][yIdx][1]];
            }
        }
    }
    
    self.contents = [newArray copy];
    [self.tableView reloadData];
}

- (void) removePartyFromContent {
    NSInteger index;
    NSInteger vendorCount = partyVendorCodeList.count;
    NSInteger purchaserCount = partyPurchaserCodeList.count;
    NSInteger customerGroup3Count = partyCustomerGroup3CodeList.count;
    NSInteger customerGroup4Count = partyCustomerGroup4CodeList.count;
    if (selectedContactRow <= vendorCount) {
        index = vendorCount - selectedContactRow;
        [partyVendorCodeList removeObjectAtIndex:index];
        [partyVendorNameList removeObjectAtIndex:index];
    } else if (selectedContactRow == vendorCount+purchaserCount) {
        index = selectedContactRow - vendorCount - purchaserCount -  1;
        [partyPurchaserCodeList removeObjectAtIndex:index];
        [partyPurchaserNameList removeObjectAtIndex:index];
    } else if (selectedContactRow == vendorCount+purchaserCount+ customerGroup3Count ) {
        index = selectedContactRow - vendorCount - purchaserCount - customerGroup3Count - 2;
        [partyCustomerGroup3CodeList removeObjectAtIndex:index];
        [partyCustomerGroup3NameList removeObjectAtIndex:index];
    } else if (selectedContactRow == vendorCount+purchaserCount + customerGroup3Count + customerGroup4Count) {
        index = selectedContactRow - vendorCount - purchaserCount - customerGroup3Count - customerGroup4Count - 3;
        [partyCustomerGroup4CodeList removeObjectAtIndex:index];
        [partyCustomerGroup4NameList removeObjectAtIndex:index];
    }
    
    NSMutableArray *newArray = [NSMutableArray new];
    for (int i = 0; i < self.tableView.numberOfSections; i++) {
        newArray[i] = [NSMutableArray new];
        int yMax = (int)[_contents[i] count];
        if (i == 1) {
            yMax -= 1;
        }
        
        for (int j = 0; j < yMax; j++) {
            newArray[i][j] = [NSMutableArray new];
            NSInteger yIdx = j;
            
            if (i == 1 && j >= selectedContactRow) {
                yIdx = j + 1;
            }
            [newArray[i][j] addObject:_contents[i][yIdx][0]];
            [newArray[i][j] addObject:_contents[i][yIdx][1]];
        }
    }
    
    self.contents = [newArray copy];
    [self.tableView reloadData];
}


- (void) replaceContentForSection:(NSInteger) section InRow:(NSInteger) row withValue:(NSString*) value{
    NSMutableArray *newArray = [NSMutableArray new];
    if (value == nil) {
        value = @"";
    }
    
    for (int i = 0; i < self.tableView.numberOfSections; i++) {
        newArray[i] = [NSMutableArray new];
        
        int jMax = (int)[_contents[i] count];
        if (isAddNew && i == selectedSection) {
            jMax = (int)MAX([_contents[i] count], row);
        }
        
        for (int j = 0; j < jMax; j++) {
            newArray[i][j] = [NSMutableArray new];
            if (isAddNew) {
                if (i == selectedSection && j == jMax - 1) {
                    [newArray[i][j] addObject:newLabel];
                    [newArray[i][j] addObject:value];
                    isAddNew = NO;
                } else {
                    [newArray[i][j] addObject:_contents[i][j][0]];
                    [newArray[i][j] addObject:_contents[i][j][1]];
                }
            } else {
                [newArray[i][j] addObject:_contents[i][j][0]];
                if (i == section && j == row) {
                    [newArray[i][j] addObject:value];
                } else {
                    
                    [newArray[i][j] addObject:_contents[i][j][1]];
                }
            }
            
            
        }
    }
    
    self.contents = [newArray copy];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) registerNib {
    self.tableView.allowMultipleSectionsOpen = YES;
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(0), @(1), nil];
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [CommonTextCell registerForReuseInTableView:self.tableView];
    [FloatingTextCell registerForReuseInTableView:self.tableView];
    [AddLastOneButtonCell registerForReuseInTableView:self.tableView];
    [AddMatterCell registerForReuseInTableView:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"AccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];
    
    [self.tableView reloadData];
}

- (void) showCalendar {
    [self.view endEditing:YES];
    
    BirthdayCalendarViewController *calendarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        
        [self replaceContentForSection:6 InRow:selectedContactRow withValue:date];
    };
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:calendarViewController];
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

#pragma mark - Table view data source

//- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 10;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.contents[section] count];
}

- (NSNumber*) getValidValue: (NSNumber*) value
{
    if (value == nil) {
        return @(0);
    }
    else {
        return value;
    }
    
    return value;
}

- (IBAction)saveMatter:(id)sender {
    NSDictionary* data = @{
                           @"primaryClient": @{
                                   @"code": [self getValidValue:selectedPrimaryClientCode]
                                   },
                           @"matter": @{
                                   @"code": [self getValidValue:selectedMatterCode]
                                   },
                           @"partner": @{
                                   @"code": [self getValidValue:selectedPartnerCode]                                   },
                           @"LA": @{
                                   @"code": [self getValidValue:selectedLACode]
                                   },
                           @"clerk": @{
                                   @"code": [self getValidValue:selectedClerkCode]
                                   },
                           @"fileStatus": @{
                                   @"code": [self getValidValue:selectedFileStatusCode]
                                   },
                           @"locationBox": _contents[0][8][1],
                           @"locationPhysical": _contents[0][7][1],
                           @"remarks": _contents[0][9][1]
                           };
    if (isLoading) return;
    isLoading = YES;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] saveMatterWithParams:data inURL:MATTER_SAVE_URL WithCompletion:^(RelatedMatterModel * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
            
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
    }];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
   
    return YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == [_contents[indexPath.section] count] -1) {
        AddLastOneButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastOneButtonCell cellIdentifier] forIndexPath:indexPath];
        cell.calculateHandler = ^{
            [self saveMatter:nil];
        };
        
        [cell.calculateBtn setTitle:_contents[indexPath.section][indexPath.row][0] forState:UIControlStateNormal];
        return cell;
    }
    
    if (indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4) {
      
        if (indexPath.section == 1) {
            if (indexPath.row == 0 || indexPath.row == partyVendorCodeList.count+1 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+2 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + 3 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + partyCustomerGroup4CodeList.count + 4 ) {
                AddMatterCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddMatterCell cellIdentifier] forIndexPath:indexPath];
                
                cell.label.text = _contents[indexPath.section][indexPath.row][0];
                cell.subLabel.hidden = YES;
                cell.lastLabel.hidden = YES;
                cell.addNew = ^{
                    
                };
                
                return cell;
            } else {
                CommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[CommonTextCell cellIdentifier] forIndexPath:indexPath];
                [cell configureCellWithValue:_contents[1][indexPath.row][0]];
                cell.valueLabel.font = [UIFont fontWithName:@"SFUIText-Light" size:13];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.leftUtilityButtons = [self leftButtons];
                cell.delegate = self;
                return cell;
            }
        } else {
            AddMatterCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddMatterCell cellIdentifier] forIndexPath:indexPath];
            cell.label.text = _contents[indexPath.section][indexPath.row][0];
            cell.subLabel.hidden = YES;
            cell.lastLabel.hidden = YES;
            if (indexPath.section == 2) {
                if ([solicitorCodeList[indexPath.row] stringValue].length != 0) {
                    
                    cell.subLabel.text = ((NSString*)solicitorNameList[indexPath.row]).uppercaseString;
                    if (cell.subLabel.text.length > 0) {
                        cell.subLabel.hidden = NO;
                    }
                    cell.lastLabel.text = ((NSString*)solicitorRefList[indexPath.row]).uppercaseString;
                    if (cell.lastLabel.text.length > 0) {
                        cell.lastLabel.hidden = NO;
                    }
                }
                
                cell.rightUtilityButtons = [self rightButtons];
                cell.leftUtilityButtons = [self leftButtons];
                cell.delegate = self;
                cell.tag = 2;
                
                cell.addNew = ^{
                    
                };
                
                return cell;
            } else if (indexPath.section == 3) {
                if ([propertyCodeList[indexPath.row] stringValue].length != 0) {
                    cell.subLabel.text = ((NSString*)propertyFullTitleList[indexPath.row]).uppercaseString;
                    if (cell.subLabel.text.length > 0) {
                        cell.subLabel.hidden = NO;
                    }
                    cell.lastLabel.text = ((NSString*)propertyAdressList[indexPath.row]).uppercaseString;
                    if (cell.lastLabel.text.length > 0) {
                        cell.lastLabel.hidden = NO;
                    }
                }
                cell.rightUtilityButtons = [self rightButtons];
                cell.leftUtilityButtons = [self leftButtons];
                cell.delegate = self;
                cell.tag = 3;
                
                cell.addNew = ^{
                    
                };
                
                return cell;
            } else if (indexPath.section == 4) {
                if ([bankCodeList[indexPath.row] stringValue].length != 0) {
                    cell.subLabel.text = ((NSString*)bankNameList[indexPath.row]).uppercaseString;
                    if (cell.subLabel.text.length > 0) {
                        cell.subLabel.hidden = NO;
                    }
                }
                cell.rightUtilityButtons = [self rightButtons];
                cell.delegate = self;
                cell.leftUtilityButtons = [self leftButtons];
                cell.tag = 4;
                
                cell.addNew = ^{
                    
                };
                
                return cell;
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
  
    int rows = (int)indexPath.row;
  
    cell.floatingTextField.placeholder = self.contents[indexPath.section][rows][0];
    cell.floatingTextField.text = self.contents[indexPath.section][rows][1];
    cell.floatingTextField.floatLabelActiveColor = cell.floatingTextField.floatLabelPassiveColor = [UIColor redColor];
    
    cell.floatingTextField.inputAccessoryView = accessoryView;
    cell.floatingTextField.delegate = self;
    cell.floatingTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    cell.floatingTextField.tag = indexPath.row;
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.floatingTextField.userInteractionEnabled = YES;
    if (indexPath.section == 0) {
        if (indexPath.row > 0 && indexPath.row < 7) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.floatingTextField.userInteractionEnabled = NO;
        }
        if (indexPath.row == 0) {
            cell.floatingTextField.userInteractionEnabled = NO;
        }
    } else if (indexPath.section == 5) {
        if (indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 12) {
            cell.floatingTextField.userInteractionEnabled = NO;
        }
        cell.floatingTextField.keyboardType = UIKeyboardTypeDecimalPad;
    } else if (indexPath.section == 6) {
        cell.floatingTextField.userInteractionEnabled = NO;
    }
    
    return cell;
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    UIFont *font = [UIFont fontWithName:@"SFUIText-Medium" size:15.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    NSAttributedString* delteString = [[NSAttributedString alloc] initWithString:@"Detail" attributes:attributes];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                      attributedTitle:delteString];
    
    return rightUtilityButtons;
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    switch (index) {
        case 0:
        {
            // detail button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            switch (cell.tag) {
                case 2:
                    [self loadSolicitor:cellIndexPath.row];
                    break;
                case 3:
                    [self loadProperty:cellIndexPath.row];
                    break;
                case 4:
                    [self loadBank:cellIndexPath.row];
                    break;
                    
                default:
                    break;
            }
            
            break;
        }
        default:
            break;
    }
}


- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    UIFont *font = [UIFont fontWithName:@"SFUIText-Medium" size:15.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    NSAttributedString* clearString = [[NSAttributedString alloc] initWithString:@"Clear" attributes:attributes];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] attributedTitle:clearString];
    
    return leftUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    selectedContactRow = indexPath.row;
    [cell hideUtilityButtonsAnimated:YES];
    if (indexPath.section == 1) {
        selectedContactRow = indexPath.row;
        [self removePartyFromContent];
    } else if (indexPath.section == 2) {
        solicitorCodeList[selectedContactRow] = @(0);
        solicitorNameList[selectedContactRow] = @"";
    } else if (indexPath.section == 3) {
        propertyCodeList[selectedContactRow] = @(0);
        propertyAdressList[selectedContactRow] = @"";
        propertyFullTitleList[selectedContactRow] = @"";
    } else if (indexPath.section == 4) {
        bankCodeList[selectedContactRow] = @(0);
        bankNameList[selectedContactRow] = @"";
    } else {
        [self replaceContentForSection:indexPath.section InRow:indexPath.row withValue:@""];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITextField Delegate

- (void) calculateImportantRM {
    CGFloat totalDeposit = [_contents[5][1][1] floatValue] + [_contents[5][2][1] floatValue];
    [self replaceContentForSection:5 InRow:3 withValue:[NSString stringWithFormat:@"%lf", totalDeposit]];
    
    CGFloat balancePurchase = [_contents[5][0][1] floatValue] + totalDeposit;
    [self replaceContentForSection:5 InRow:4 withValue:[NSString stringWithFormat:@"%lf", balancePurchase]];
    CGFloat totalLoan = 0;
    
    
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSArray* info = [self calcSectionNumber:textField.tag];
    [self replaceContentForSection:[info[0] integerValue] InRow:[info[1] integerValue] withValue:textField.text];
    [self calculateImportantRM];   
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kDefaultAccordionHeaderViewHeight;
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

- (void) loadContact: (NSInteger) number {
    NSString* code = [NSString stringWithFormat:@"%@", _contents[1][number][1]];
    if (isLoading) return;
    isLoading = YES;
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] loadContactFromSearchWithCode:code completion:^(ContactModel * _Nonnull contactModel, NSError * _Nonnull error) {
        
        @strongify(self);
        self->isLoading = false;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
            [self performSegueWithIdentifier:kContactSearchSegue sender:contactModel];
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
    }];
}

- (void) loadSolicitor: (NSInteger) number {
    if (solicitorCodeList.count == 0) {
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:@"Couldn't get the detail" duration:1.0];
        
    } else {
        if (isLoading) return;
        isLoading = YES;
        NSString* code = [NSString stringWithFormat:@"%@", solicitorCodeList[number]];
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        __weak UINavigationController *navigationController = self.navigationController;
        @weakify(self);
        [[QMNetworkManager sharedManager] loadLegalFirmWithCode:code completion:^(LegalFirmModel * _Nonnull legalFirmModel, NSError * _Nonnull error) {
            @strongify(self);
            self->isLoading = false;
            if (error == nil) {
                [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
                [self performSegueWithIdentifier:kLegalFirmSearchSegue sender:legalFirmModel];
            } else {
                [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
            }
        }];
    }
}

- (void) loadProperty: (NSInteger) number {
    if (propertyCodeList.count == 0) {
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:@"Couldn't get the detail" duration:1.0];
        
    } else {
        if (isLoading) return;
        isLoading = YES;
        
        NSString* code = [NSString stringWithFormat:@"%@", propertyCodeList[number]];
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        __weak UINavigationController *navigationController = self.navigationController;
        @weakify(self);
        [[QMNetworkManager sharedManager] loadPropertyfromSearchWithCode:code completion:^(PropertyModel * _Nonnull propertyModel, NSError * _Nonnull error) {
            
            @strongify(self);
            self->isLoading = false;
            if (error == nil) {
                [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
                [self performSegueWithIdentifier:kPropertySearchSegue sender:propertyModel];
            } else {
                [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
            }
        }];
    }
    
}


- (void) loadBank: (NSInteger) number {
    if (bankCodeList.count == 0) {
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:@"Couldn't get the detail" duration:1.0];
        
    } else {
        if (isLoading) return;
        isLoading = YES;
        NSString* code = [NSString stringWithFormat:@"%@", bankCodeList[number]];
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        __weak UINavigationController *navigationController = self.navigationController;
        @weakify(self);
        [[QMNetworkManager sharedManager] loadBankFromSearchWithCode:code completion:^(BankModel * _Nonnull bankModel, NSError * _Nonnull error) {
            
            @strongify(self);
            self->isLoading = false;
            if (error == nil) {
                [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
                [self performSegueWithIdentifier:kBankSearchSegue sender:bankModel];
            } else {
                [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
            }
        }];
    }
}

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedContactRow = -1;
    selectedSection = indexPath.section;
    if (indexPath.section == 0) {
        isAddNew = NO;
        if (indexPath.row == 1) {
            selectedContactRow = indexPath.row;
            [self performSegueWithIdentifier:kContactGetListSegue sender:CONTACT_GETLIST_URL];
        } else if (indexPath.row == 2) {
            titleOfList = @"Select File Status";
            nameOfField = self.contents[indexPath.section][indexPath.row][0];
            [self performSegueWithIdentifier:kListWithCodeSegue sender:MATTER_FILE_STATUS_GET_LIST_URL];
        } else if (indexPath.row == 3) {
            [self performSegueWithIdentifier:kStaffSegue sender:@"partner"];
        } else if (indexPath.row == 4) {
            [self performSegueWithIdentifier:kStaffSegue sender:@"la"];
        } else if (indexPath.row == 5) {
            [self performSegueWithIdentifier:kStaffSegue sender:@"clerk"];
        } else if (indexPath.row == 6)  {
            [self performSegueWithIdentifier:kMatterCodeSegue sender:MATTER_LIST_GET_URL];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0 || indexPath.row == partyVendorCodeList.count+1 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+2 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + 3 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + partyCustomerGroup4CodeList.count + 4 ) {
            isAddNew = YES;
            selectedContactRow = indexPath.row;
            selectedSection = indexPath.section;
            [self performSegueWithIdentifier:kContactGetListSegue sender:CONTACT_GETLIST_URL];
        } else {
            [self loadContact:indexPath.row];
        }
        
    } else if (indexPath.section == 2) {
        isAddNew = NO;
        selectedContactRow = indexPath.row;
        [self performSegueWithIdentifier:kSolicitorListSegue sender:nil];
    } else if (indexPath.section == 3) {
        isAddNew = NO;
        selectedContactRow = indexPath.row;
        [self performSegueWithIdentifier:kPropertyListSegue sender:PROPERTY_GET_LIST_URL];
    } else if (indexPath.section == 4) {
        isAddNew = NO;
        selectedContactRow = indexPath.row;
        [self performSegueWithIdentifier:kBankBranchSegue sender:nil];
    } else if (indexPath.section == 5) {
        
    } else if (indexPath.section == 6) {
        isAddNew = NO;
        selectedContactRow = indexPath.row;
        [self showCalendar];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    self.keyValue[[NSNumber numberWithInteger:section]] = @(1);
    [self reloadHeaders];
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
//    NSIndexPath* indexPath = [NSIndexPath indexPathForRow: ([self.tableView numberOfRowsInSection:section]-1) inSection:section];
//    
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
    self.keyValue[[NSNumber numberWithInteger:section]] = @(0);
    [self reloadHeaders];
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}


#pragma mark - ContactListWithCodeSelectionDelegate
- (void) didSelectList:(UIViewController *)listVC name:(NSString*) name withModel:(CodeDescription *)model
{
    if ([name isEqualToString:@"File Status"]) {
        [self replaceContentForSection:0 InRow:2 withValue:model.descriptionValue];
        selectedFileStatusCode = [NSNumber numberWithLong:[model.codeValue longLongValue]];
    } 
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kContactGetListSegue]) {
        PropertyContactListViewController* contactVC = segue.destinationViewController;
        contactVC.updateHandler = ^(StaffModel *model) {
            newLabel = @"Name";
            
            if (selectedSection == 0) {
                selectedPrimaryClientCode =[NSNumber numberWithInteger: [model.staffCode integerValue]];
                [self replaceContentForSection:selectedSection InRow:selectedContactRow withValue:model.name];
            } else {
                [self addPartyToContents:model.name code:[NSNumber numberWithInteger: [model.staffCode integerValue]]];
            }
            
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
    
    if ([segue.identifier isEqualToString:kMatterCodeSegue]) {
        ListOfMatterViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterCodeModel *model) {
            selectedMatterCode = [NSNumber numberWithInteger: [model.matterCode integerValue]];
            [self replaceContentForSection:0 InRow:6 withValue:model.matterCode];
        };
    }
    
    if ([segue.identifier isEqualToString:kStaffSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        StaffViewController* staffVC = navVC.viewControllers.firstObject;
        staffVC.typeOfStaff = sender;
        staffVC.updateHandler = ^(NSString* typeOfStaff, StaffModel* model) {
            if ([typeOfStaff isEqualToString:@"partner"]) {
                [self replaceContentForSection:0 InRow:3 withValue:model.name];
                selectedPartnerCode = [NSNumber numberWithInteger: [model.staffCode integerValue]];
            } else if ([typeOfStaff isEqualToString:@"la"]) {
                [self replaceContentForSection:0 InRow:4 withValue:model.name];
                selectedLACode = [NSNumber numberWithInteger: [model.staffCode integerValue]];
            } else if ([typeOfStaff isEqualToString:@"clerk"]) {
                [self replaceContentForSection:0 InRow:5 withValue:model.name];
                selectedClerkCode = [NSNumber numberWithInteger: [model.staffCode integerValue]];
            }
        };
    }
    
    if ([segue.identifier isEqualToString:kPropertyListSegue]) {
        PropertyListViewController* propertyVC = segue.destinationViewController;
        propertyVC.updateHandler = ^(FullPropertyModel *model) {
            
            if (propertyCodeList.count > selectedContactRow) {
                propertyAdressList[selectedContactRow] = [NSNumber numberWithInteger: [model.propertyCode integerValue]];
                propertyFullTitleList[selectedContactRow] = model.fullTitle;
                propertyAdressList[selectedContactRow] = model.address.fullAddress;
            } else {
                [propertyCodeList addObject:[NSNumber numberWithInteger: [model.propertyCode integerValue]]];
                [propertyFullTitleList addObject:model.fullTitle];
                [propertyAdressList addObject:model.address.fullAddress];
            }
            [self replaceContentForSection:selectedSection InRow:selectedContactRow withValue:model.projectName];
        };
    }

    if ([segue.identifier isEqualToString:kBankBranchSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        BranchListViewController *listVC = navVC.viewControllers.firstObject;
        listVC.updateHandler = ^(BankBranchModel *model) {
            newLabel = model.name;
            
            if (bankCodeList.count > selectedContactRow) {
                bankCodeList[selectedContactRow] = [NSNumber numberWithInteger: [model.bankBranchCode integerValue]];
                bankNameList[selectedContactRow] = model.name;
            } else {
                [bankCodeList addObject:[NSNumber numberWithInteger: [model.bankBranchCode integerValue]]];
                [bankNameList addObject:model.name];
            }
            [self replaceContentForSection:selectedSection InRow:selectedContactRow withValue:model.HQ.name];
        };
    }
    
    if ([segue.identifier isEqualToString:kSolicitorListSegue]) {
        SolicitorListViewController *listVC = segue.destinationViewController;
        listVC.updateHandler = ^(SoliciorModel *model) {
            newLabel = [NSString stringWithFormat:@"SolicitorGroup%ld", selectedContactRow-1];
            solicitorCodeList[selectedContactRow] = [NSNumber numberWithInteger: [model.solicitorCode integerValue]];
            solicitorNameList[selectedContactRow] = model.name;
            solicitorRefList[selectedContactRow] = model.reference;
//            if (solicitorCodeList.count > selectedContactRow) {
//                
//            } else {
//                [solicitorCodeList addObject:[NSNumber numberWithInteger: [model.solicitorCode integerValue]]];
//                [solicitorNameList addObject:model.name];
//                [solicitorRefList addObject:model.reference];
//            }
            [self replaceContentForSection:selectedSection InRow:selectedContactRow withValue:model.name];
        };
    }
    
    if ([segue.identifier isEqualToString:kPropertySearchSegue]){
        PropertyViewController* propertyVC = segue.destinationViewController;
        propertyVC.propertyModel = sender;
        propertyVC.previousScreen = @"Back";
    }
    
    if ([segue.identifier isEqualToString:kBankSearchSegue]){
        BankViewController* bankVC = segue.destinationViewController;
        bankVC.bankModel = sender;
        bankVC.previousScreen = @"Back";
    }
    
    if ([segue.identifier isEqualToString:kContactSearchSegue]){
        ContactViewController* contactVC = segue.destinationViewController;
        contactVC.contactModel = sender;
        contactVC.previousScreen = @"Back";
    }
}
@end
