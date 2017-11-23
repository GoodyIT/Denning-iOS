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
#import "LegalFirmViewController.h"
#import "CourtDiaryListViewController.h"
#import "CoramListViewController.h"
#import "CaseTypeViewController.h"
#import "AddPropertyViewController.h"
#import "ListOfCodeStrViewController.h"
#import "CommonTextCell.h"
#import "IncreasingCell.h"
#import "AddMatterPropertyCell.h"

enum SECTIONS {
    MAIN_SECTION,
    REMARKS_SECTION,
    CASEDETAIL_SECTION,
    PROPERTIES_SECTION,
    PARTYGROUP_SECTION,
    SOLICITORS_SECTION,
    BANKS_SECTION,
    IMPORTANT_RM_SECTION,
    IMPORTANT_DATE_SECTION,
    TEXTGROUP_SECTION
};

@interface AddMatterViewController ()
<UITableViewDelegate,
UITableViewDataSource,
ContactListWithCodeSelectionDelegate,
UITextFieldDelegate,
SWTableViewCellDelegate,
UITextViewDelegate,
ContactListWithDescSelectionDelegate>
{
    NSString *titleOfList;
    NSString* nameOfField;
    __block BOOL isLoading;
    __block BOOL isSaveMode;
    __block BOOL isHeaderOpening;
    
    NSString* selectedFileStatusCode;
    NSString* selectedPartnerCode;
    NSString* selectedLACode;
    NSString* selectedClerkCode;
    NSString* selectedPrimaryClientCode;
    NSString* selectedMatterCode;
    NSString* selectedCourtDiaryCode;
    NSString* selectedSARCode, *selectedJudgeCode;
    NSString* selectedCaseTypeCode;
    NSString* selectedBranchCode;
    
    NSMutableArray<NSString*>* partyVendorCodeList, *partyVendorNameList;
    NSMutableArray<NSString*>* partyPurchaserCodeList, *partyPurchaserNameList;
    NSMutableArray<NSString*>* partyCustomerGroup3CodeList, *partyCustomerGroup3NameList;
    NSMutableArray<NSString*>* partyCustomerGroup4CodeList, *partyCustomerGroup4NameList;
    
    NSMutableArray<NSString*> *bankCodeList, *bankNameList;
    NSMutableArray<NSString*>* solicitorCodeList, *solicitorNameList, *solicitorRefList;
    NSMutableArray<NSString*> *propertyCodeList, *propertyFullTitleList, *propertyAdressList;
    
    NSMutableArray<GeneralGroup*> *importantRM, *importantDates, *textGroup;
    
    NSString* newLabel, *newValue;
    NSInteger selectedContactRow, selectedSection;
    __block BOOL isAddNew;
}

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSMutableArray *headers;
@property (strong, nonatomic)
NSMutableDictionary* keyValue;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@end

@implementation AddMatterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self checkStatus];
    [self registerNib];
    [self displayMatter];
}

- (void) displayMatter {
    if (!isSaveMode) {
        [self updateMainInfo];
        [self updateGroups];
    }
}

- (void) prepareUI {
    selectedCourtDiaryCode = selectedSARCode = selectedJudgeCode= selectedCaseTypeCode = @"";
    
    
    self.keyValue = [@{
                       @(0): @(1)
                       } mutableCopy];
    NSArray* temp = @[
                      @[@[@"File No (Auto Assigned)", @""], @[@"Ref 2", @""], @[@"Primary Client", @""], @[@"File Status", @""], @[@"Partner-in-Charge", @""], @[@"LA-in-Charge", @""], @[@"Clerk-in-Charge", @""], @[@"Matter", @""], @[@"Branch", @""], @[@"Location Box", @""], @[@"Location Physical", @""], @[@"Location Pocket No", @""],
                          @[@"Save", @""]
                        ]
                      ];
    _contents = [temp mutableCopy];
    
    // Set the default value @"1" for branch
    selectedBranchCode = @"1";
//    [self replaceContentForSection:MAIN_SECTION InRow:8 withValue:@"Kuala Lumpur"];
    
    _headers = [@[
                 @"Matter Information"
                 ] mutableCopy];
    
    partyVendorCodeList = [NSMutableArray new];
    partyVendorNameList = [NSMutableArray new];
    partyPurchaserCodeList = [NSMutableArray new];
    partyPurchaserNameList = [NSMutableArray new];
    partyCustomerGroup3CodeList = [NSMutableArray new];
    partyCustomerGroup3NameList = [NSMutableArray new];
    partyCustomerGroup4CodeList = [NSMutableArray new];
    partyCustomerGroup4NameList = [NSMutableArray new];
    propertyCodeList = [NSMutableArray new];
    propertyFullTitleList = [NSMutableArray new];
    propertyAdressList = [NSMutableArray new];

    bankCodeList = [NSMutableArray new];
    for (int i = 0; i < 3; i++) {
        [bankCodeList addObject:@""];
    }
    bankNameList = [NSMutableArray new];
    for (int i = 0; i < 3; i++) {
        [bankNameList addObject:@""];
    }
    solicitorCodeList = [NSMutableArray new];
    for (int i = 0; i < 4; i++) {
        [solicitorCodeList addObject:@""];
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

- (void) addPartyToContents: (NSString*)name code:(NSString*) code
{
    if ((partyVendorCodeList.count + partyPurchaserCodeList.count + partyCustomerGroup3CodeList.count + partyCustomerGroup4CodeList.count) > 25) {
        [QMAlert showAlertWithMessage:@"You cannot add more parties" actionSuccess:NO inViewController:self];
        return;
    }
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
    
    [self addContentsAndRefresh:PARTYGROUP_SECTION index:index value1:name value2:code];
}

- (void) addContentsAndRefresh:(NSUInteger) section index:(NSInteger) index value1:(NSString*) value1 value2:(NSString*) value2 {
    BOOL isAdded  = NO;
    NSMutableArray *newArray = [NSMutableArray new];
    for (int i = 0; i < self.tableView.numberOfSections; i++) {
        newArray[i] = [NSMutableArray new];
        int yMax = (int)[_contents[i] count];
        if (i == section) {
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
            if (j == index && i == section) {
                [newArray[i][j] addObject:value1];
                [newArray[i][j] addObject:value2];
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

- (void) addPropertyToContent:(FullPropertyModel*) model {
    [propertyCodeList addObject:model.propertyCode];
    [propertyFullTitleList addObject:model.fullTitle];
    [propertyAdressList addObject:model.address.fullAddress];
    
    [self addContentsAndRefresh:PROPERTIES_SECTION index:propertyCodeList.count value1:model.fullTitle value2:model.propertyCode];
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
    
    [self updateContentsAndRefresh:PARTYGROUP_SECTION];
}

- (void) updateContentsAndRefresh:(NSUInteger) section {
    NSMutableArray *newArray = [NSMutableArray new];
    for (int i = 0; i < self.tableView.numberOfSections; i++) {
        newArray[i] = [NSMutableArray new];
        int yMax = (int)[_contents[i] count];
        if (i == section) {
            yMax -= 1;
        }
        
        for (int j = 0; j < yMax; j++) {
            newArray[i][j] = [NSMutableArray new];
            NSInteger yIdx = j;
            
            if (i == section && j >= selectedContactRow) {
                yIdx = j + 1;
            }
            [newArray[i][j] addObject:_contents[i][yIdx][0]];
            [newArray[i][j] addObject:_contents[i][yIdx][1]];
        }
    }
    
    self.contents = [newArray copy];
    [self.tableView reloadData];
}

- (void) removePropertyFromContents {
    [propertyCodeList removeObjectAtIndex:selectedContactRow-1];
    [propertyAdressList removeObjectAtIndex:selectedContactRow-1];
    [propertyFullTitleList removeObjectAtIndex:selectedContactRow-1];
  
    [self updateContentsAndRefresh:PROPERTIES_SECTION];
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
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(0), nil];
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [CommonTextCell registerForReuseInTableView:self.tableView];
    [IncreasingCell registerForReuseInTableView:self.tableView];
    [FloatingTextCell registerForReuseInTableView:self.tableView];
    [AddLastOneButtonCell registerForReuseInTableView:self.tableView];
    [AddMatterCell registerForReuseInTableView:self.tableView];
    [AddMatterPropertyCell registerForReuseInTableView:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"AccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];
    
    [self.tableView reloadData];
}

- (void) showCalendar {
    [self.view endEditing:YES];
    
    BirthdayCalendarViewController *calendarViewController = [[UIStoryboard storyboardWithName:@"AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        
        [self replaceContentForSection:selectedSection InRow:selectedContactRow withValue:date];
        importantDates[selectedContactRow].value = [DIHelpers convertDateToMySQLFormat:date];
    };
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:calendarViewController];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.contents[section] count];
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

- (void) updateSystemNumber {
    [self replaceContentForSection:MAIN_SECTION InRow:0 withValue:_matterModel.systemNo];
}

- (void) updateMainInfo {
    [self updateSystemNumber];
    [self replaceContentForSection:MAIN_SECTION InRow:1 withValue:_matterModel.ref];
    [self replaceContentForSection:MAIN_SECTION InRow:2 withValue:_matterModel.primaryClient.name];
    selectedPrimaryClientCode = _matterModel.primaryClient.clientCode;
    [self replaceContentForSection:MAIN_SECTION InRow:3 withValue:_matterModel.fileStatus.descriptionValue];
    selectedFileStatusCode = _matterModel.fileStatus.codeValue;
    [self replaceContentForSection:MAIN_SECTION InRow:4 withValue:_matterModel.partner.name];
    selectedPartnerCode = _matterModel.partner.staffCode;
    [self replaceContentForSection:MAIN_SECTION InRow:5 withValue:_matterModel.legalAssistant.name];
    selectedLACode = _matterModel.legalAssistant.staffCode;
    [self replaceContentForSection:MAIN_SECTION InRow:6 withValue:_matterModel.clerk.name];
    selectedClerkCode = _matterModel.clerk.staffCode;
    [self replaceContentForSection:MAIN_SECTION InRow:7 withValue:[NSString stringWithFormat:@"%@ %@", _matterModel.matter.matterCode,  _matterModel.matter.matterDescription]];
    selectedMatterCode =  _matterModel.matter.matterCode;
    [self replaceContentForSection:MAIN_SECTION InRow:8 withValue:_matterModel.branch.city];
    selectedBranchCode = _matterModel.branch.codeValue;
    [self replaceContentForSection:MAIN_SECTION InRow:9 withValue:_matterModel.locationBox];
    [self replaceContentForSection:MAIN_SECTION InRow:10 withValue:_matterModel.locationPhysical];
    [self replaceContentForSection:MAIN_SECTION InRow:11 withValue:_matterModel.locationPocket];
}

- (void) updateGroups {
    NSInteger index = 0;
    NSMutableArray *newArray = [NSMutableArray new];
    newArray[index] = [NSMutableArray new];
    
    // Main info
    for (int j = 0; j < [_contents[0] count]; j++) {
        newArray[index][j] = [NSMutableArray new];
        [newArray[index][j] addObject:_contents[0][j][0]];
        [newArray[index][j] addObject:_contents[0][j][1]];
    }
    index += 1;
    _headers = [@[
                  @"Matter Information"
                  ] mutableCopy];

    // Remarks
    newArray[index] = [NSMutableArray new];
    [newArray[index] addObject:@[@"Notes", _matterModel.remarks]];
    index += 1;
    [_headers addObject:@"Remarks"];
    
    // Case Detail
    newArray[index] = [NSMutableArray new];
    [newArray[index] addObject:@[@"Case NO.", _matterModel.court.caseNumber]];
    [newArray[index] addObject:@[@"Court", _matterModel.court.court]];
    [newArray[index] addObject:@[@"Judge", _matterModel.court.judge]];
    [newArray[index] addObject:@[@"Party Type", _matterModel.court.partyType]];
    [newArray[index] addObject:@[@"Place", _matterModel.court.place]];
    [newArray[index] addObject:@[@"SAR", _matterModel.court.SAR]];
    [newArray[index] addObject:@[@"Type Case", _matterModel.court.partyType]];
    index += 1;
    [_headers addObject:@"Case Detail"];
    
    // Price
    // Nothing
    
    // Properties
    newArray[index] = [NSMutableArray new];
    newArray[index][0] = [NSMutableArray new];
    [newArray[index][0] addObject:@"Add Property"];
    [newArray[index][0] addObject:@""];
    if (_matterModel.propertyGroupArray.count > 0) {
        for (int k = 0; k < _matterModel.propertyGroupArray.count; k++) {
            PropertyModel* model = _matterModel.propertyGroupArray[k];
            newArray[index][k+1] = [NSMutableArray new];
            [newArray[index][k+1] addObject:model.fullTitle];
            [newArray[index][k+1] addObject:model.address];
            [propertyAdressList addObject:model.address];
            [propertyCodeList addObject:model.key];
            [propertyFullTitleList addObject:model.fullTitle];
        }
    }
    index += 1;
    [_headers addObject:@"Properties"];
    [_keyValue addEntriesFromDictionary:@{@(1):@(1)}];
    
    // parties group
    if (_matterModel.partyGroupArray.count > 0) {
        newArray[index] = [NSMutableArray new];
        int k = 0;
        for ( PartyGroupModel* model in _matterModel.partyGroupArray) {
            newArray[index][k] = [NSMutableArray new];
            [newArray[index][k] addObject:model.partyGroupName];
            [newArray[index][k] addObject:@""];
            if ([[model.partyGroupName lowercaseString] isEqualToString:@"vendor"]) {
                for (int m = 0; m < model.partyArray.count; m++) {
                    k++;
                    newArray[index][k] = [NSMutableArray new];
                    [newArray[index][k] addObject:model.partyArray[m].name];
                    [newArray[index][k] addObject:@""];
                    [partyVendorCodeList addObject:model.partyArray[m].clientCode];
                    [partyVendorNameList addObject:model.partyArray[m].name];
                }
            } else if ([[model.partyGroupName lowercaseString] isEqualToString:@"purchaser"]) {
                for (int m = 0; m < model.partyArray.count; m++) {
                    k++;
                    newArray[index][k] = [NSMutableArray new];
                    [newArray[index][k] addObject:model.partyArray[m].name];
                    [newArray[index][k] addObject:@""];
                    [partyPurchaserCodeList addObject:model.partyArray[m].clientCode];
                    [partyPurchaserNameList addObject:model.partyArray[m].name];
                }
            } else if ([[model.partyGroupName lowercaseString] isEqualToString:@"customer group3"]) {
                for (int m = 0; m < model.partyArray.count; m++) {
                    k++;
                    newArray[index][k] = [NSMutableArray new];
                    [newArray[index][k] addObject:model.partyArray[m].name];
                    [newArray[index][k] addObject:@""];
                    [partyCustomerGroup3CodeList addObject:model.partyArray[m].clientCode];
                    [partyCustomerGroup3NameList addObject:model.partyArray[m].name];
                }
            } else if ([[model.partyGroupName lowercaseString] isEqualToString:@"customer group4"]) {
                for (int m = 0; m < model.partyArray.count; m++) {
                    k++;
                    newArray[index][k] = [NSMutableArray new];
                    [newArray[index][k] addObject:model.partyArray[m].name];
                    [newArray[index][k] addObject:@""];
                    [partyCustomerGroup4CodeList addObject:model.partyArray[m].clientCode];
                    [partyCustomerGroup4NameList addObject:model.partyArray[m].name];
                }
            }
            k++;
        }
        [_headers addObject:@"PartyGroup"];
        NSDictionary* temp = @{@(1):@(1)};
        [_keyValue addEntriesFromDictionary:temp];
        
        index += 1;
    }
    
    // solicitors group
    if (_matterModel.solicitorGroupArray.count > 0) {
        newArray[index] = [NSMutableArray new];
        for (int k = 0; k < _matterModel.solicitorGroupArray.count; k++) {
            SolicitorGroup* model = _matterModel.solicitorGroupArray[k];
            newArray[index][k] = [NSMutableArray new];
            [newArray[index][k] addObject:model.solicitorGroupName];
            [newArray[index][k] addObject:model.solicitorName];
            solicitorCodeList[k] = model.solicitorCode;
            solicitorNameList[k] = model.solicitorName;
        }
        
        [_headers addObject:@"Solicitors"];
        [_keyValue addEntriesFromDictionary:@{@(1):@(1)}];
        
        index += 1;
    }
    
    // Banks
    if (_matterModel.bankGroupArray.count > 0) {
        newArray[index] = [NSMutableArray new];
        for (int k = 0; k < _matterModel.bankGroupArray.count; k++) {
            BankGroupModel* model = _matterModel.bankGroupArray[k];
            newArray[index][k] = [NSMutableArray new];
            [newArray[index][k] addObject:model.bankGroupName];
            [newArray[index][k] addObject:model.bankName];
            bankCodeList[k] = model.bankCode;
            bankNameList[k] = model.bankName;
        }
        
        [_headers addObject:@"Banks"];
        [_keyValue addEntriesFromDictionary:@{@(1):@(1)}];
        
        index += 1;
    }
    
    // Important RM
    [_headers addObject:@"Important RM"];
    [_keyValue addEntriesFromDictionary:@{@(1):@(1)}];
    importantRM = [_matterModel.RMGroupArray mutableCopy];
    newArray[index] = [NSMutableArray new];
    for (int i = 0; i < importantRM.count; i++) {
        newArray[index][i] = [NSMutableArray new];
        [newArray[index][i] addObject:importantRM[i].label];
        [newArray[index][i] addObject:importantRM[i].value];
    }
    
    index += 1;
    
    // Important Dates
    [_headers addObject:@"Important Dates"];
    [_keyValue addEntriesFromDictionary:@{@(1):@(1)}];
    newArray[index] = [NSMutableArray new];
    importantDates = [_matterModel.dateGroupArray mutableCopy];
    for (int i = 0; i < importantDates.count; i++) {
        newArray[index][i] = [NSMutableArray new];
        [newArray[index][i] addObject:importantDates[i].label];
        [newArray[index][i] addObject:importantDates[i].value];
    }
    
    index += 1;
    
    // Text Group
    if (_matterModel.textGroupArray.count > 0) {
        [_headers addObject:@"Text Group"];
        [_keyValue addEntriesFromDictionary:@{@(1): @(1)}];
        newArray[index] = [NSMutableArray new];
        textGroup = [_matterModel.textGroupArray mutableCopy];
        for (int i = 0; i < textGroup.count; i++) {
            newArray[index][i] = [NSMutableArray new];
            [newArray[index][i] addObject:textGroup[i].label];
            [newArray[index][i] addObject:textGroup[i].value];
        }
        index += 1;
    }
    
    self.contents = newArray;
}

- (void) updateMatterTable {
    [self updateSystemNumber];
    [self checkStatus];
    [self updateGroups];
    
    [self.tableView reloadData];
}

- (BOOL) checkValidate {
    if (selectedPrimaryClientCode.length == 0) {
        [QMAlert showInformationWithMessage:@"Please input primary client" inViewController:self];
        return NO;
    }
    
    if (selectedPartnerCode.length == 0) {
        [QMAlert showInformationWithMessage:@"Please input partner-in-charge" inViewController:self];
        return NO;
    }

    if (selectedClerkCode.length == 0) {
        [QMAlert showInformationWithMessage:@"Please input clerk-in-charge" inViewController:self];
        return NO;
    }
    
    if (selectedMatterCode.length == 0) {
        [QMAlert showInformationWithMessage:@"Please input matter" inViewController:self];
        return NO;
    }

    return YES;
}

- (void) checkStatus {
    if (_matterModel.systemNo == nil || _matterModel.systemNo.length == 0) {
        isSaveMode = YES;
        [self.saveBtn setTitle:@"Save" forState:UIControlStateNormal];
        self.title = @"Add Matter";
    } else {
        isSaveMode = NO;
        [self.saveBtn setTitle:@"Update" forState:UIControlStateNormal];
        self.title = @"Update Matter";
    }
}

- (NSMutableDictionary*) buildSaveParams {
    NSMutableDictionary* data = [NSMutableDictionary new];
    
    [data addEntriesFromDictionary:@{@"dateOpen": [DIHelpers todayWithTime]}];
    [data addEntriesFromDictionary:@{@"Branch": @{@"code": selectedBranchCode}}];
    
    if (selectedPrimaryClientCode.length > 0 && ![selectedPrimaryClientCode isEqualToString:_matterModel.primaryClient.clientCode]) {
        [data addEntriesFromDictionary:@{@"primaryClient": @{
                                                 @"code": selectedPrimaryClientCode}}];
    }
    
    if (selectedMatterCode.length > 0 && ![selectedMatterCode isEqualToString:_matterModel.matter.matterCode]) {
        [data addEntriesFromDictionary:@{@"matter": @{
                                                 @"code": selectedMatterCode}}];
    }
    if (selectedPartnerCode.length > 0 && ![selectedPartnerCode isEqualToString:_matterModel.partner.staffCode]) {
        [data addEntriesFromDictionary:@{@"partner": @{
                                                 @"code": selectedPartnerCode}}];
    }
    if (selectedLACode.length > 0 && ![selectedLACode isEqualToString:_matterModel.legalAssistant.staffCode]) {
        [data addEntriesFromDictionary:@{@"legalAssistant": @{
                                                 @"code": selectedLACode}}];
    }
    if (selectedClerkCode.length > 0 && ![selectedClerkCode isEqualToString:_matterModel.clerk.staffCode]) {
        [data addEntriesFromDictionary:@{@"clerk": @{
                                                 @"code": selectedClerkCode}}];
    }
    if (selectedFileStatusCode.length > 0 && ![selectedFileStatusCode isEqualToString:_matterModel.fileStatus.codeValue]) {
        [data addEntriesFromDictionary:@{@"fileStatus": @{
                                                 @"code": selectedFileStatusCode}}];
    }
    if (_contents[0][9][1] && ![_contents[0][9][1] isEqualToString:_matterModel.locationBox]) {
        [data addEntriesFromDictionary:@{@"locationBox": _contents[0][9][1]}];
    }
    if (_contents[0][8][1] && ![_contents[0][8][1] isEqualToString:_matterModel.locationPhysical]) {
        [data addEntriesFromDictionary:@{@"locationPhysical": _contents[0][8][1]}];
    }
    if (_contents[0][10][1] && ![_contents[0][10][1] isEqualToString:_matterModel.locationPocket]) {
        [data addEntriesFromDictionary:@{@"locationPocket": _contents[0][10][1]}];
    }
    
    
    return data;
}

- (NSDictionary*) buildUpdateParams {
    NSMutableDictionary* data = [NSMutableDictionary new];
    
    [data addEntriesFromDictionary:@{@"dateOpen": [DIHelpers todayWithTime]}];
    
    [data addEntriesFromDictionary:@{@"Branch": @{@"code": selectedBranchCode}}];
    
    if (selectedPrimaryClientCode.length > 0 && ![selectedPrimaryClientCode isEqualToString:_matterModel.primaryClient.clientCode]) {
        [data addEntriesFromDictionary:@{@"primaryClient": @{
                                                 @"code": selectedPrimaryClientCode}}];
    }
    
    if (selectedPartnerCode.length > 0 && ![selectedPartnerCode isEqualToString:_matterModel.partner.staffCode]) {
        [data addEntriesFromDictionary:@{@"partner": @{
                                                 @"code": selectedPartnerCode}}];
    }
    if (selectedLACode.length > 0 && ![selectedLACode isEqualToString:_matterModel.legalAssistant.staffCode]) {
        [data addEntriesFromDictionary:@{@"legalAssistant": @{
                                                 @"code": selectedLACode}}];
    }
    if (selectedClerkCode.length > 0 && ![selectedClerkCode isEqualToString:_matterModel.clerk.staffCode]) {
        [data addEntriesFromDictionary:@{@"clerk": @{
                                                 @"code": selectedClerkCode}}];
    }
    if (selectedFileStatusCode.length > 0 && ![selectedFileStatusCode isEqualToString:_matterModel.fileStatus.codeValue]) {
        [data addEntriesFromDictionary:@{@"fileStatus": @{
                                                 @"code": selectedFileStatusCode}}];
    }
    if (_contents[0][9][1] && ![_contents[0][9][1] isEqualToString:_matterModel.locationBox]) {
        [data addEntriesFromDictionary:@{@"locationBox": _contents[0][9][1]}];
    }
    if (_contents[0][8][1] && ![_contents[0][8][1] isEqualToString:_matterModel.locationPhysical]) {
        [data addEntriesFromDictionary:@{@"locationPhysical": _contents[0][8][1]}];
    }
    if (_contents[0][10][1] && ![_contents[0][10][1] isEqualToString:_matterModel.locationPocket]) {
        [data addEntriesFromDictionary:@{@"locationPocket": _contents[0][10][1]}];
    }
    
    [data addEntriesFromDictionary:@{@"systemNo":_matterModel.systemNo}];
    
    // Remarks
    if (_contents[1][0][1] && ![_contents[1][0][1] isEqualToString:_matterModel.remarks]) {
        [data addEntriesFromDictionary:@{@"remarks": _contents[1][0][1]}];
    }
    
    [data addEntriesFromDictionary:[self buildCaseDetailParam]];
    
    [data addEntriesFromDictionary:[self buildPropertiesGroupParams]];
    [data addEntriesFromDictionary:[self buildPartyGroupParams]];
    [data addEntriesFromDictionary:[self buildSolicitorsGroupParams]];
    [data addEntriesFromDictionary:[self buildBanksGroupParams]];
    
    [data addEntriesFromDictionary:[self buildImportantRMGroupParam]];
    // Important Dates
    [data addEntriesFromDictionary:[self buildImportantDatesParam]];
    
    // Text Group
    [data addEntriesFromDictionary:[self buildTextGroupParam]];
    
    return [data copy];
}

- (NSDictionary*) buildTextGroupParam {
    NSMutableArray* textGroupParam = [NSMutableArray new];
    
    for (int i = 0; i < textGroup.count; i++) {
        GeneralGroup* group = textGroup[i];
        [textGroupParam addObject:@[@{@"fieldName":group.fieldName}, @{@"value":_contents[TEXTGROUP_SECTION][i][1]}]];
    }
    
    return @{@"textGroup": textGroupParam};
}

- (NSDictionary*) buildCaseDetailParam {
    NSMutableArray* caseDetailParam = [NSMutableArray new];
    
    [caseDetailParam addObject:@{@"CaseNo":_contents[CASEDETAIL_SECTION][0][1]}];
    [caseDetailParam addObject:@{@"Court":_contents[CASEDETAIL_SECTION][1][1]}];
    [caseDetailParam addObject:@{@"Judge":_contents[CASEDETAIL_SECTION][2][1]}];
    [caseDetailParam addObject:@{@"PartyType":_contents[CASEDETAIL_SECTION][3][1]}];
    [caseDetailParam addObject:@{@"Place":_contents[CASEDETAIL_SECTION][4][1]}];
    [caseDetailParam addObject:@{@"SAR":_contents[CASEDETAIL_SECTION][5][1]}];
    [caseDetailParam addObject:@{@"TypeCase":_contents[CASEDETAIL_SECTION][6][1]}];
    
    return @{@"courtInfo":caseDetailParam};
}

- (NSDictionary*) buildImportantRMGroupParam {
    NSMutableArray* importantRMGroupParam = [NSMutableArray new];
    
    for (int i = 0; i < importantRM.count; i++) {
        GeneralGroup* group = importantRM[i];
        if (_contents[IMPORTANT_RM_SECTION][i][1] && ![group.value isEqualToString:_contents[IMPORTANT_RM_SECTION][i][1]]) {
            [importantRMGroupParam addObject:@[@{@"fieldName":group.fieldName}, @{@"value":_contents[IMPORTANT_RM_SECTION][i][1]}]];
        }
    }
    
    return @{@"RMGroup": importantRMGroupParam};
}

- (NSDictionary*) buildImportantDatesParam {
    NSMutableArray* importantDatesParam = [NSMutableArray new];
    
    for (int i = 0; i < importantDates.count; i++) {
        GeneralGroup* group = importantDates[i];
        if (_contents[IMPORTANT_DATE_SECTION][i][1] && ![group.value isEqualToString:_contents[IMPORTANT_DATE_SECTION][i][1]]) {
            [importantDatesParam addObject:@[@{@"fieldName":group.fieldName}, @{@"value":[DIHelpers convertDateToMySQLFormat:_contents[IMPORTANT_DATE_SECTION][i][1]]}]];
        }
    }
    
    return @{@"dateGroup": importantDatesParam};
}

- (NSDictionary*) buildPartyParam:(NSString*) partyName codeList:(NSArray*)codeList {
    NSMutableDictionary *vendor = [NSMutableDictionary new];
    [vendor addEntriesFromDictionary:@{@"PartyName":partyName}];
    NSMutableArray *partyParam = [NSMutableArray new];
    for (int j = 0; j < _matterModel.partyGroupArray.count; j++) {
        PartyGroupModel* partyGroup = _matterModel.partyGroupArray[j];
        if ([partyGroup.partyGroupName isEqualToString:partyName]) {
            for (int i = 0; i < codeList.count; i++) {
                if (codeList[i] && (partyGroup.partyArray.count == 0 || (partyGroup.partyArray > 0 && ![codeList[i] isEqualToString:partyGroup.partyArray[i].clientCode]))){
                    [partyParam addObject:@{@"code":codeList[i]}];
                }
            }
        }
    }
    [vendor addEntriesFromDictionary:@{@"party":partyParam}];
    return [vendor copy];
}

- (NSDictionary*) buildPartyGroupParams {
    NSMutableArray* partyArray = [NSMutableArray new];
    
    [partyArray addObject:[self buildPartyParam:@"Vendor" codeList:partyVendorCodeList]];
    [partyArray addObject:[self buildPartyParam:@"Purchaser" codeList:partyPurchaserCodeList]];
    [partyArray addObject:[self buildPartyParam:@"Customer Group3" codeList:partyCustomerGroup3CodeList]];
    [partyArray addObject:[self buildPartyParam:@"Customer Group4" codeList:partyCustomerGroup4CodeList]];
    
    return @{@"partyGroup":partyArray};
}

- (NSDictionary*) buildSolicitorParam:(NSString*) code groupName:(NSString*) name refList:(NSString*) ref
{
    NSMutableDictionary* solicitor = [NSMutableDictionary new];
    [solicitor addEntriesFromDictionary:@{@"groupName":name}];
    [solicitor addEntriesFromDictionary:@{@"reference":ref}];
    [solicitor addEntriesFromDictionary:@{@"solicitor":@{@"code":code}}];
    
    return solicitor;
}

- (NSDictionary*) buildSolicitorsGroupParams {
    NSMutableArray* solicitorArray = [NSMutableArray new];
    for (int i = 0; i < solicitorCodeList.count; i++) {
        if (solicitorCodeList[i].length > 0 && ![solicitorCodeList[i] isEqualToString:_matterModel.solicitorGroupArray[i].solicitorCode]) {
            [solicitorArray addObject:[self buildSolicitorParam:solicitorCodeList[i] groupName:solicitorNameList[i] refList:solicitorRefList[i]]];
        }
    }
    
    return @{@"solicitorsGroup":solicitorArray};
}

- (NSDictionary*) buildPropertiesGroupParams {
    NSMutableArray* propertyArray = [NSMutableArray new];
    
    for (int i = 0; i < propertyCodeList.count; i++) {
        if (_matterModel.propertyGroupArray.count < i+1 || ![propertyCodeList[i] isEqualToString:_matterModel.propertyGroupArray[i].key]) {
            [propertyArray addObject:@{@"code":propertyCodeList[i]}];
        }
    }
    
    return @{@"propertyGroup":propertyArray};
}

- (NSDictionary*) buildBankParam:(NSString*) code groupName:(NSString*) name
{
    NSMutableDictionary* bank = [NSMutableDictionary new];
    [bank addEntriesFromDictionary:@{@"groupName":name}];
    [bank addEntriesFromDictionary:@{@"bank":@{@"code":code}}];
    
    return bank;
}

- (NSDictionary*) buildBanksGroupParams {
    NSMutableArray* bankArray = [NSMutableArray new];
    for (int i = 0; i < bankCodeList.count; i++) {
        if (bankCodeList[i].length > 0 && ![bankCodeList[i] isEqualToString:_matterModel.bankGroupArray[i].bankCode]) {
            [bankArray addObject:[self buildBankParam:bankCodeList[i] groupName:bankNameList[i]]];
        }
    }
    
    return @{@"bankGroup":bankArray};
}

- (void) updateMatter {
    
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] updateMatterWithParams:[self buildUpdateParams] inURL:MATTER_SAVE_URL WithCompletion:^(RelatedMatterModel * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            _matterModel = result;
            [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
        } else {
//            _matterModel = [RelatedMatterModel new];
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
    }];
}

- (IBAction)saveMatter:(id)sender {
    
    if (![self checkValidate]) {
        return;
    }
    
    [self checkStatus];
    
    if (!isSaveMode) {
        [QMAlert showConfirmDialog:@"Do you want to update contact?" inViewController:self completion:^(UIAlertAction * _Nonnull action) {
            if  ([action.title isEqualToString:@"OK"]) {
                [self updateMatter];
            }
        }];
        
        return;
    }
    
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] saveMatterWithParams:[self buildSaveParams] inURL:MATTER_SAVE_URL WithCompletion:^(RelatedMatterModel * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            _matterModel = result;
            [self updateMatterTable];
            [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
            
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
    }];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger section = [[self calcSectionNumber:textField.tag][0] integerValue];
    if (section == IMPORTANT_RM_SECTION) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        textField.text = [DIHelpers formatDecimal:text];
        return NO;
    } else {
        return YES;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == MAIN_SECTION && indexPath.row == [_contents[MAIN_SECTION] count] -1) {
        AddLastOneButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastOneButtonCell cellIdentifier] forIndexPath:indexPath];
        if(isSaveMode) {
            cell.calculateHandler = ^{
                [self saveMatter:nil];
            };
            [cell.calculateBtn setTitle:@"Save" forState:UIControlStateNormal];
        } else {
            cell.calculateHandler = ^{
                [self updateMatter];
            };
            [cell.calculateBtn setTitle:@"Update" forState:UIControlStateNormal];
        }
        
        return cell;
    }
    
    if (indexPath.section == PARTYGROUP_SECTION) { // Party Group
        if (indexPath.row == 0 || indexPath.row == partyVendorCodeList.count+1 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+2 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + 3 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + partyCustomerGroup4CodeList.count + 4 ) {
            AddMatterCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddMatterCell cellIdentifier] forIndexPath:indexPath];
            
            cell.label.text = _contents[indexPath.section][indexPath.row][0];
            cell.subLabel.hidden = YES;
            cell.lastLabel.hidden = YES;
            cell.addNew = ^{
                [self addParty:indexPath];
            };
            
            return cell;
        } else {
            CommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[CommonTextCell cellIdentifier] forIndexPath:indexPath];
            [cell configureCellWithValue:_contents[indexPath.section][indexPath.row][0]];
            cell.valueLabel.font = [UIFont fontWithName:@"SFUIText-Light" size:13];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.leftUtilityButtons = [self leftButtons];
            cell.delegate = self;
            return cell;
        }
    } else if (indexPath.section == SOLICITORS_SECTION) { // Solicitor
        AddMatterCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddMatterCell cellIdentifier] forIndexPath:indexPath];
        cell.label.text = _contents[indexPath.section][indexPath.row][0];
        cell.subLabel.text = ((NSString*)solicitorNameList[indexPath.row]).uppercaseString;
        if (cell.subLabel.text.length > 0) {
            cell.subLabel.hidden = NO;
        }
        cell.lastLabel.text = ((NSString*)solicitorRefList[indexPath.row]).uppercaseString;
        if (cell.lastLabel.text.length > 0) {
            cell.lastLabel.hidden = NO;
        }
        
        cell.rightUtilityButtons = [self rightButtons];
        cell.leftUtilityButtons = [self leftButtons];
        cell.delegate = self;
        
        cell.addNew = ^{
            
        };
        return cell;
    } else if (indexPath.section == PROPERTIES_SECTION) { // Property
        
        if (indexPath.row == 0) {
            AddMatterCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddMatterCell cellIdentifier] forIndexPath:indexPath];
            cell.label.text = _contents[indexPath.section][indexPath.row][0];
            cell.subLabel.hidden = YES;
            cell.lastLabel.hidden = YES;
            
            cell.addNew = ^{
            };
            
            return cell;
        }
        
        if (indexPath.row > 0 && propertyCodeList[indexPath.row-1].length != 0) {
            AddMatterPropertyCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddMatterPropertyCell cellIdentifier] forIndexPath:indexPath];
            NSInteger row = indexPath.row-1;
            [cell configureCellWithFullTitle:propertyFullTitleList[row] withAddress:propertyAdressList[row] inNumber:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.leftUtilityButtons = [self leftButtons];
            cell.delegate = self;
            return cell;
        }
    } else if (indexPath.section == BANKS_SECTION) { // Bank
        AddMatterCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddMatterCell cellIdentifier] forIndexPath:indexPath];
        cell.label.text = _contents[indexPath.section][indexPath.row][0];
        cell.subLabel.hidden = YES;
        cell.lastLabel.hidden = YES;
        cell.subLabel.text = ((NSString*)bankNameList[indexPath.row]).uppercaseString;
        if (cell.subLabel.text.length > 0) {
            cell.subLabel.hidden = NO;
        }
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
        cell.leftUtilityButtons = [self leftButtons];
        
        cell.addNew = ^{
            
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
    
    int rows = (int)indexPath.row;
    
    if (indexPath.section == REMARKS_SECTION) { // Remarks
        IncreasingCell* cell = [tableView dequeueReusableCellWithIdentifier:[IncreasingCell cellIdentifier] forIndexPath:indexPath];
        cell.increaseTextView.placeholder = self.contents[indexPath.section][rows][0];
        cell.increaseTextView.text = self.contents[indexPath.section][rows][1];
        cell.increaseTextView.inputAccessoryView = accessoryView;
        cell.increaseTextView.tag = [self calcTag:indexPath];
        cell.increaseTextView.delegate = self;
        cell.leftUtilityButtons = [self leftButtons];
        cell.delegate = self;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    FloatingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[FloatingTextCell cellIdentifier] forIndexPath:indexPath];

    cell.floatingTextField.placeholder = self.contents[indexPath.section][rows][0];
    cell.floatingTextField.text = self.contents[indexPath.section][rows][1];
    cell.floatingTextField.floatLabelActiveColor = cell.floatingTextField.floatLabelPassiveColor = [UIColor redColor];
    
    cell.floatingTextField.inputAccessoryView = accessoryView;
    cell.floatingTextField.delegate = self;
    cell.floatingTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    cell.floatingTextField.tag = [self calcTag:indexPath];
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.floatingTextField.userInteractionEnabled = YES;
    if (indexPath.section == MAIN_SECTION) {
        if (indexPath.row > 1 && indexPath.row <= 8) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.floatingTextField.userInteractionEnabled = NO;
        }
        if (indexPath.row == 0) {
            cell.floatingTextField.userInteractionEnabled = NO;
        }
    } else if (indexPath.section == IMPORTANT_RM_SECTION) { // Important RM
        if (indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 12) {
            if (importantRM[rows].formula.length == 0) {
                cell.floatingTextField.userInteractionEnabled = YES;
            } else {
                cell.floatingTextField.userInteractionEnabled =  NO;
            }
        }
        cell.tag = indexPath.section;
        cell.floatingTextField.keyboardType = UIKeyboardTypeDecimalPad;
    } else if (indexPath.section == IMPORTANT_DATE_SECTION) { // Date Group
        cell.floatingTextField.userInteractionEnabled = NO;
    } else if (indexPath.section == CASEDETAIL_SECTION) {
        if  (indexPath.row == 0) {
            cell.floatingTextField.userInteractionEnabled = YES;
        } else {
            cell.floatingTextField.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
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
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    [cell hideUtilityButtonsAnimated:YES];
    switch (index) {
        case 0:
        {
            // detail button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            switch (indexPath.section) {
                case PROPERTIES_SECTION:
                    [self loadProperty:cellIndexPath.row];
                    break;
                case SOLICITORS_SECTION:
                    [self loadSolicitor:cellIndexPath.row];
                    break;
               
                case BANKS_SECTION:
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
    if (indexPath.section == PARTYGROUP_SECTION) {
        selectedContactRow = indexPath.row;
        [self removePartyFromContent];
    } else if (indexPath.section == SOLICITORS_SECTION) {
        solicitorCodeList[selectedContactRow] = @"";
        solicitorNameList[selectedContactRow] = @"";
        solicitorRefList[selectedContactRow] = @"";
    } else if (indexPath.section == PROPERTIES_SECTION) {
        [self removePropertyFromContents];
    } else if (indexPath.section == BANKS_SECTION) {
        bankCodeList[selectedContactRow] = @"";
        bankNameList[selectedContactRow] = @"";
    } else {
        [self replaceContentForSection:indexPath.section InRow:indexPath.row withValue:@""];
        if  (indexPath.section == MAIN_SECTION) {
            if (indexPath.row == 2) {
                selectedPrimaryClientCode = @"";
            } else if (indexPath.row == 3) {
                selectedFileStatusCode = @"";
            } else if (indexPath.row == 4) {
                selectedPartnerCode = @"";
            } else if (indexPath.row == 5) {
                selectedLACode = @"";
            } else if (indexPath.row == 6) {
                selectedClerkCode = @"";
            } else if (indexPath.row == 7) {
                selectedMatterCode = @"";
            } else if (indexPath.row == 8) {
                selectedBranchCode = @"";
            }
                
        }
    }
    
    [self.tableView reloadData];
}

- (NSString*) removeComma: (NSString*) string {
    return [string stringByReplacingOccurrencesOfString:@"," withString:@""];
}

#pragma mark - UITextField Delegate
    
- (NSString*) replaceFormulaWithActualValue:(NSString*) formula fieldName:(NSString*)fieldName section:(NSInteger)section matchString:(NSString*) matchString
{
    NSString* newFormula;
    for (int i = 0; i < importantRM.count; i++) {
        GeneralGroup* group = importantRM[i];
        if ([group.fieldName isEqualToString:fieldName]) {
            NSString* value = _contents[section][i][1];
            if (value.length == 0) {
                value = @"0";
            } else {
                value = [self removeComma:value];
            }
            newFormula = [formula stringByReplacingOccurrencesOfString:matchString withString:value];
            break;
        }
    }
    
    return newFormula;
}

- (void) parseRMGroupFormula: (NSString*) formula position:(NSInteger) position
{
    NSString* pattern = @"\\[\\$\\d+\\]";
    NSError * error;
    NSRegularExpression *regex =  [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];

    NSRange searchRange = NSMakeRange(0, formula.length);
    NSArray *matches = [regex matchesInString:formula options:0 range:searchRange];

    // 6: Iterate through the matches and highlight them
    NSString* _formula = formula;
    for (NSTextCheckingResult *match in matches)
        {
            NSString* matchString = [_formula substringWithRange:match.range];
            NSString* fieldName = [matchString substringWithRange:NSMakeRange(1, matchString.length-2)];
            formula = [self replaceFormulaWithActualValue:formula fieldName:fieldName section:IMPORTANT_RM_SECTION matchString:matchString];
           }

    NSExpression *expression = [NSExpression expressionWithFormat:formula];
    NSNumber *result = [expression expressionValueWithObject:nil context:nil];
    _contents[IMPORTANT_RM_SECTION][position][1] = [DIHelpers addThousandsSeparator:[result stringValue]];
}

- (void) calculateImportantRM {
    for (int i = 0; i < importantRM.count; i++) {
            GeneralGroup* field = _matterModel.RMGroupArray[i];
            if (field.formula.length > 0) {
                    [self parseRMGroupFormula:field.formula position:i];
                }
        }

    [self.tableView reloadData];
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

- (void) updateTableAfterDidEndEditing:(NSString*) string tag:(NSInteger) tag {
    string = [[DIHelpers capitalizedString:string] mutableCopy];
    NSArray* info = [self calcSectionNumber:tag];
    if ([info[0] integerValue] == MAIN_SECTION && ([info[1] integerValue] >= 8 || [info[1] integerValue] <= 10)) {
        string = [[string localizedUppercaseString] mutableCopy];
    }
    [self replaceContentForSection:[info[0] integerValue] InRow:[info[1] integerValue] withValue:string];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSArray* info = [self calcSectionNumber:textView.tag];
    [self replaceContentForSection:[info[0] integerValue] InRow:[info[1] integerValue] withValue:textView.text];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateTableAfterDidEndEditing:textField.text tag:textField.tag];
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

- (void) loadContact:(NSInteger)section number: (NSInteger) number {
    NSString* code;
    if  (number < partyVendorCodeList.count+1) {
        number--;
        code = partyVendorCodeList[number];
    } else if (number < partyVendorCodeList.count+partyPurchaserCodeList.count+2) {
        number -= partyVendorCodeList.count - 2;
        code = partyPurchaserCodeList[number];
    } else if (number < partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + 3) {
        number -= partyVendorCodeList.count+partyPurchaserCodeList.count - 3;
        code = partyCustomerGroup3CodeList[number];
    } else if (partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + partyCustomerGroup4CodeList.count + 4) {
        number -= partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + partyCustomerGroup4CodeList.count + 4;
        code = partyCustomerGroup4CodeList[number];
    }
    if (code.length == 0) {
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:@"Couldn't get the detail" duration:1.0];
        return;
    }
    if (isLoading) return;
    isLoading = YES;
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
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
    if (solicitorCodeList[number].length == 0) {
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:@"Couldn't get the detail" duration:1.0];
        return;
    } else {
        if (isLoading) return;
        isLoading = YES;
        NSString* code = [NSString stringWithFormat:@"%@", solicitorCodeList[number]];
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
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
    if (propertyCodeList[number].length == 0) {
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:@"Couldn't get the detail" duration:1.0];
        return;
    } else {
        if (isLoading) return;
        isLoading = YES;
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
        @weakify(self);
        [[QMNetworkManager sharedManager] loadPropertyfromSearchWithCode:propertyCodeList[number] completion:^(AddPropertyModel * _Nonnull propertyModel, NSError * _Nonnull error) {
            
            @strongify(self);
            self->isLoading = false;
            if (error == nil) {
                [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
                [self performSegueWithIdentifier:kAddPropertySegue sender:propertyModel];
            } else {
                [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
            }
        }];
    }
}

- (void) loadBank: (NSInteger) number {
    if (bankCodeList[number].length == 0) {
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:@"Couldn't get the detail" duration:1.0];
        return;
    } else {
        if (isLoading) return;
        isLoading = YES;
        NSString* code = [NSString stringWithFormat:@"%@", bankCodeList[number]];
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
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

- (void) addParty: (NSIndexPath*) indexPath
{
    if (indexPath.row == 0 || indexPath.row == partyVendorCodeList.count+1 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+2 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + 3 || indexPath.row == partyVendorCodeList.count+partyPurchaserCodeList.count+partyCustomerGroup3CodeList.count + partyCustomerGroup4CodeList.count + 4 ) {
        isAddNew = YES;
        selectedContactRow = indexPath.row;
        selectedSection = indexPath.section;
        [self performSegueWithIdentifier:kContactGetListSegue sender:CONTACT_GETLIST_URL];
    } else {
        [self loadContact:indexPath.section number:indexPath.row];
    }
}

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedContactRow = -1;
    selectedSection = indexPath.section;
    if (indexPath.section == MAIN_SECTION) {
        isAddNew = NO;
        if (indexPath.row == 2) {
            selectedContactRow = indexPath.row;
            [self performSegueWithIdentifier:kContactGetListSegue sender:CONTACT_GETLIST_URL];
        } else if (indexPath.row == 3) {
            titleOfList = @"Select File Status";
            nameOfField = self.contents[indexPath.section][indexPath.row][0];
            [self performSegueWithIdentifier:kListWithCodeSegue sender:MATTER_FILE_STATUS_GET_LIST_URL];
        } else if (indexPath.row == 4) {
            titleOfList = @"Select Partner";
            [self performSegueWithIdentifier:kStaffSegue sender:@"partner"];
        } else if (indexPath.row == 5) {
            titleOfList = @"Select LA";
            [self performSegueWithIdentifier:kStaffSegue sender:@"la"];
        } else if (indexPath.row == 6) {
            titleOfList = @"Select Clerk";
            [self performSegueWithIdentifier:kStaffSegue sender:@"clerk"];
        } else if (indexPath.row == 7)  {
            [self performSegueWithIdentifier:kMatterCodeSegue sender:MATTER_LIST_GET_URL];
        } else if (indexPath.row == 8)  {
            [self performSegueWithIdentifier:kMatterBranchSegue sender:MATTER_BRANCH_GET_URL];
        }
    } else if (indexPath.section == CASEDETAIL_SECTION) {
        if  (indexPath.row == 1 || indexPath.row == 4) {
            [self performSegueWithIdentifier:kCourtDiarySegue sender:nil];
        } else if  (indexPath.row == 2 || indexPath.row == 5) {
            selectedContactRow = indexPath.row;
            [self performSegueWithIdentifier:kCoramListSegue sender:nil];
        } else if (indexPath.row == 3) {
            titleOfList = @"Select Party Type";
            nameOfField = self.contents[CASEDETAIL_SECTION][4][0];
            [self performSegueWithIdentifier:kListWithDescriptionSegue sender:COURT_PARTY_TYPE_GET_URL];
        } else if (indexPath.row == 6) {
            [self performSegueWithIdentifier:kCaseTypeSegue sender:nil];
        }
    }  else if (indexPath.section == PARTYGROUP_SECTION) { // Party Group
        [self addParty:indexPath];
    } else if (indexPath.section == SOLICITORS_SECTION) { // Solicitor
        isAddNew = NO;
        selectedContactRow = indexPath.row;
        [self performSegueWithIdentifier:kSolicitorListSegue sender:nil];
    } else if (indexPath.section == PROPERTIES_SECTION) { // Property Group
        if (indexPath.row == 0) {
            isAddNew = YES;
            selectedContactRow = indexPath.row;
            [self performSegueWithIdentifier:kPropertyListSegue sender:PROPERTY_GET_LIST_URL];
        } else {
            [self loadProperty:indexPath.row-1];
        }
    } else if (indexPath.section == BANKS_SECTION) { // Bank Group
        isAddNew = NO;
        selectedContactRow = indexPath.row;
        [self performSegueWithIdentifier:kBankBranchSegue sender:nil];
    } else if (indexPath.section == IMPORTANT_RM_SECTION) { // Important RM
        
    } else if (indexPath.section == IMPORTANT_DATE_SECTION) { // Date Group
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
    if (isHeaderOpening) {
        return;
    }
    isHeaderOpening = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow: ([self.tableView numberOfRowsInSection:section]-1) inSection:section];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        isHeaderOpening = NO;
    });
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
        [self replaceContentForSection:MAIN_SECTION InRow:3 withValue:model.descriptionValue];
        selectedFileStatusCode = model.codeValue;
    } 
}

#pragma mark - ContactListWithDescriptionDelegate
- (void) didSelectListWithDescription:(UIViewController *)listVC name:(NSString*) name withString:(NSString *)description
{
    for (int i = 0; i < self.tableView.numberOfSections; i ++) {
        for (int j = 0; j < [_contents[i] count]; j++) {
            NSLog(@"(%d, %d)", i, j);
            if ([name isEqualToString:_contents[i][j][0]]) {
                [self replaceContentForSection:i InRow:j withValue:description];
            }
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kContactGetListSegue]) {
        PropertyContactListViewController* contactVC = segue.destinationViewController;
        contactVC.updateHandler = ^(StaffModel *model) {
            newLabel = @"Name";
            
            if (selectedSection == MAIN_SECTION) {
                selectedPrimaryClientCode = model.staffCode;
                [self replaceContentForSection:selectedSection InRow:selectedContactRow withValue:model.name];
            } else {
                [self addPartyToContents:model.name code:model.staffCode];
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
            selectedMatterCode = model.matterCode;
            [self replaceContentForSection:MAIN_SECTION InRow:7 withValue:[NSString stringWithFormat:@"%@ %@", model.matterCode, model.matterDescription]];
        };
    }
    
    if ([segue.identifier isEqualToString:kStaffSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        StaffViewController* staffVC = navVC.viewControllers.firstObject;
        staffVC.typeOfStaff = sender;
        staffVC.title = titleOfList;
        staffVC.updateHandler = ^(NSString* typeOfStaff, StaffModel* model) {
            if ([typeOfStaff isEqualToString:@"partner"]) {
                [self replaceContentForSection:MAIN_SECTION InRow:4 withValue:model.name];
                selectedPartnerCode = model.staffCode;
            } else if ([typeOfStaff isEqualToString:@"la"]) {
                [self replaceContentForSection:MAIN_SECTION InRow:5 withValue:model.name];
                selectedLACode = model.staffCode;
            } else if ([typeOfStaff isEqualToString:@"clerk"]) {
                [self replaceContentForSection:MAIN_SECTION InRow:6 withValue:model.name];
                selectedClerkCode = model.staffCode;
            }
        };
    }
    
    if ([segue.identifier isEqualToString:kPropertyListSegue]) {
        PropertyListViewController* propertyVC = segue.destinationViewController;
        propertyVC.updateHandler = ^(FullPropertyModel *model) {
            
            [self addPropertyToContent:model];
        };
    }

    if ([segue.identifier isEqualToString:kBankBranchSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        BranchListViewController *listVC = navVC.viewControllers.firstObject;
        listVC.updateHandler = ^(BankBranchModel *model) {
            newLabel = model.name;
            
            if (bankCodeList.count > selectedContactRow) {
                bankCodeList[selectedContactRow] = model.bankBranchCode;
                bankNameList[selectedContactRow] = model.name;
            } else {
                [bankCodeList addObject:model.bankBranchCode];
                [bankNameList addObject:model.name];
            }
            [self replaceContentForSection:selectedSection InRow:selectedContactRow withValue:model.HQ.name];
        };
    }
    
    if ([segue.identifier isEqualToString:kSolicitorListSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        SolicitorListViewController *listVC = nav.viewControllers.firstObject;
        listVC.updateHandler = ^(SoliciorModel *model) {
            newLabel = [NSString stringWithFormat:@"SolicitorGroup%ld", selectedContactRow-1];
            solicitorCodeList[selectedContactRow] = model.solicitorCode;
            solicitorNameList[selectedContactRow] = model.name;
            solicitorRefList[selectedContactRow] = model.reference;
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
    }else if ([segue.identifier isEqualToString:kLegalFirmSearchSegue]){
        LegalFirmViewController* legalFirmVC = segue.destinationViewController;
        legalFirmVC.legalFirmModel = sender;
        legalFirmVC.previousScreen = @"Back";
    } else if ([segue.identifier isEqualToString:kCourtDiarySegue]) {
        CourtDiaryListViewController* courtVC = segue.destinationViewController;
        courtVC.updateHandler = ^(CourtDiaryModel *model) {
            [self replaceContentForSection:CASEDETAIL_SECTION InRow:4 withValue:model.typeE];
            [self replaceContentForSection:CASEDETAIL_SECTION InRow:1 withValue:model.place];
            selectedCourtDiaryCode = model.courtDiaryCode;
        };
    } else if ([segue.identifier isEqualToString:kCoramListSegue]) {
        CoramListViewController* coramVC = segue.destinationViewController;
        coramVC.updateHandler = ^(CoramModel *model) {
            if (selectedContactRow == 2) {
                selectedJudgeCode = model.coramCode;
            } else {
                selectedSARCode = model.coramCode;
            }
            [self replaceContentForSection:CASEDETAIL_SECTION InRow:selectedContactRow withValue:model.name];
        };
    } else if ([segue.identifier isEqualToString:kCaseTypeSegue]) {
        CaseTypeViewController *vc = segue.destinationViewController;
        vc.updateHandler = ^(CaseTypeModel *model) {
            [self replaceContentForSection:CASEDETAIL_SECTION InRow:6 withValue:model.strBahasa];
            selectedCaseTypeCode = model.caseCode;
        };
    } else if ([segue.identifier isEqualToString:kListWithDescriptionSegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        ListWithDescriptionViewController* vc = navVC.viewControllers.firstObject;
        vc.url = sender;
        vc.titleOfList = titleOfList;
        vc.name = nameOfField;
        vc.contactDelegate = self;
    } else if ([segue.identifier isEqualToString:kAddPropertySegue]){
        UINavigationController* navC = segue.destinationViewController;
        AddPropertyViewController* propertyVC = [navC viewControllers].firstObject;
        propertyVC.propertyModel = sender;
        propertyVC.viewType = @"view";
    } else if ([segue.identifier isEqualToString:kMatterBranchSegue]){
        ListOfCodeStrViewController* vc = segue.destinationViewController;
        vc.url = sender;
        vc.updateHandler = ^(CodeStrModel *model) {
            selectedBranchCode = model.codeValue;
            [self replaceContentForSection:MAIN_SECTION InRow:8 withValue:model.strCity];
        };
    }
}
@end
