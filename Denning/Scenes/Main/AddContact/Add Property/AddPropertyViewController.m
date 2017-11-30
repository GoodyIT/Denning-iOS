//
//  AddPropertyViewController.m
//  Denning
//
//  Created by DenningIT on 11/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddPropertyViewController.h"
#import "FloatingTextCell.h"
#import "FloatingTextTwoColumnCell.h"
#import "FloatingTextTwoColumnReversedCell.h"
#import "ListWithDescriptionViewController.h"
#import "ListWithCodeTableViewController.h"
#import "BirthdayCalendarViewController.h"
#import "ProjectHousingViewController.h"
#import "PropertyContactListViewController.h"
#import "PropertyTypeListViewController.h"
#import "SimpleAutocomplete.h"
#import "PropertyAutoComplete.h"
#import "DetailWithAutocomplete.h"
#import "MukimValueList.h"
#import "MasterTitleView.h"

enum  {
    HEADER_SECTION,
    MAIN_SECTION,
    TITLE_DETAILS_SECTION,
    MORE_STRATA_SECTION,
    UNITE_PARCEL_SECTION,
    PROJECT_SECTION
};

@interface AddPropertyViewController ()<UITableViewDelegate, UITableViewDataSource, ContactListWithDescSelectionDelegate,ContactListWithCodeSelectionDelegate, UITextFieldDelegate, SWTableViewCellDelegate>
{
    NSString *titleOfList;
    NSString* nameOfField;
    NSString* selectedPropertyType;
    NSString* selectedTitleIssuedCode;
    NSString* selectedAreaTypeCode;
    NSString* selectedRestrictionCode;
    NSString* selectedPropertyCode;
    NSString* selectedProjectCode;
    __block BOOL isLoading;
    __block BOOL isHeaderOpening;
    NSInteger selectedContactRow;
    
    NSString* propertyID;
}

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSArray *headers;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (strong, nonatomic)
NSMutableDictionary* keyValue;
@end

@implementation AddPropertyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self registerNib];
}

- (void) prepareUI {
    self.keyValue = [@{
                       @(0): @(1), @(1):@(1),
                       @(2):@(0),
                       @(3):@(0),
                       @(4):@(0)
                       } mutableCopy];

    _headers = @[
                 @"", @"Title Details (if issued)", @"More Strata Title Details (if issued)", @"Unit / Parcel Details (Per Principal SPA)", @"Project"
                 ];
    
    if ([self.viewType isEqualToString:@"view"]) {
        selectedRestrictionCode = _propertyModel.restrictionInInterest.codeValue;
        selectedPropertyType = _propertyModel.propertyType.codeValue;
        selectedAreaTypeCode = _propertyModel.area.type;
        selectedTitleIssuedCode = _propertyModel.titleIssued.codeValue;
        NSArray* temp = @[
                          @[@[@"Property Type", _propertyModel.propertyType.descriptionValue], @[@"Individual / Strata Title", _propertyModel.titleIssued.descriptionValue], @[@"ID (System assinged)", _propertyModel.propertyID]],
                          @[@[@"Title Type", _propertyModel.title.type], @[@"Title No.", _propertyModel.title.value], @[@"Lot Type", _propertyModel.lotPT.type], @[@"Lot / PT No.", _propertyModel.lotPT.value], @[@"Mukim Type", _propertyModel.mukim.type], @[@"Mukim", _propertyModel.mukim.value], @[@"Daerah", _propertyModel.daerah], @[@"Negeri", _propertyModel.negeri],  @[@"Area Value", _propertyModel.area.value], @[@"Area Type", _propertyModel.area.type], @[@"Tenure", _propertyModel.tenure],@[@"Lease Expiry Date", [DIHelpers convertDateToCustomFormat:_propertyModel.leaseExpiryDate]], @[@"Address / Place", _propertyModel.address],  @[@"Restriction in Interest", _propertyModel.restrictionInInterest.descriptionValue], @[@"Restriction Against", _propertyModel.restrictionAgainst], @[@"Approving Authority", _propertyModel.approvingAuthority], @[@"Category of Land Use", _propertyModel.landUse]
                            ],
                          @[@[@"Parcel No.", _propertyModel.parcelNo], @[@"Storey No.", _propertyModel.storeyNo], @[@"Building No", _propertyModel.buildingNo], @[@"Accessory Parcel No.", _propertyModel.accParcelNo], @[@"Accessory Storey No.", _propertyModel.accStoreyNo], @[@"Accessory Building No.", _propertyModel.accBuildingNo], @[@"Units of Shares", _propertyModel.unitShare], @[@"Total Shares", _propertyModel.totalShare]],
                          @[@[@"Parcel Type", _propertyModel.spaParcel.type], @[@"Unit/Parcel No.", _propertyModel.spaParcel.value], @[@"Storey No.", _propertyModel.storeyNo], @[@"Building/Block No.", _propertyModel.buildingNo], @[@"Apt/Condo name", _propertyModel.spaCondoName], @[@"Accessory Parcel No", _propertyModel.spaAccParcelNo], @[@"SPA Area", _propertyModel.spaArea.value], @[@"Measurement Unit", _propertyModel.spaArea.type]],
                          @[@[@"Project Name", _propertyModel.project], @[@"Developer", _propertyModel.developer], @[@"Proprietor", _propertyModel.proprietor], @[@"Block/Master Title", _propertyModel.masterTitle]],
                          ];
        _contents = [temp mutableCopy];
        if ([_viewType isEqualToString:@"view"]) {
            self.title = @"View Property";
        }
        [self.saveBtn setTitle:@"Update" forState:UIControlStateNormal];
    } else {
        [self clearInput];
        self.title = @"Add Property";
    }
}

- (void) clearInput {
    selectedRestrictionCode = @"";
    selectedPropertyType = @"";
    selectedAreaTypeCode = @"";
    selectedTitleIssuedCode = @"";
    
    NSArray* temp = @[
                      @[@[@"Property Type", @""], @[@"Individual / Strata Title", @""], @[@"ID (System assinged)", @""]],
                      @[@[@"Title Type", @""], @[@"Title No.", @""], @[@"Lot Type", @""], @[@"Lot / PT No.", @""], @[@"Mukim Type", @""], @[@"Mukim", @""], @[@"Daerah", @""], @[@"Negeri", @""],  @[@"Area Value", @""], @[@"Area Type", @""], @[@"Tenure", @""], @[@"Lease Expiry Date", @""], @[@"Address / Place", @""], @[@"Restriction in Interest", @""], @[@"Restriction Against", @""], @[@"Approving Authority", @""], @[@"Category of Land Use", @""]
                        ],
                      @[@[@"Parcel No.", @""], @[@"Storey No.", @""], @[@"Building No", @""], @[@"Accessory Prcel No.", @""], @[@"Accessory Storey No.", @""], @[@"Accessory Building No.", @""], @[@"Units of Shares", @""], @[@"Total Shares", @""]],
                      @[@[@"Parcel Type", @""], @[@"Unit/Parcel No.", @""], @[@"Storey No.", @""], @[@"Building/Block No.", @""], @[@"Apt/Condo name", @""], @[@"Accessory Parcel No", @""], @[@"SPA Area", @""], @[@"Measurement Unit", @""]],
                      @[@[@"Project Name", @""], @[@"Developer", @""], @[@"Proprietor", @""], @[@"Block/Master Title", @""]],
                      ];
    _contents = [temp mutableCopy];
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

- (void) showPropertyAutocomplete: (NSString*) url {
    [self.view endEditing:YES];
    
    PropertyAutoComplete *vc = [[UIStoryboard storyboardWithName:@
                                 "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"PropertyAutoComplete"];
    vc.url = url;
    vc.title = @"";
    vc.updateHandler =  ^(ProjectHousingModel* model) {
        [self didSelectListWithDescription:nil name:nameOfField withString:model.name];
        nameOfField = @"Developer";
        [self didSelectListWithDescription:nil name:nameOfField withString:model.developer];
        nameOfField = @"Proprietor";
        [self didSelectListWithDescription:nil name:nameOfField withString:model.proprietor];
        nameOfField = @"Block/Master Title";
        [self didSelectListWithDescription:nil name:nameOfField withString:model.masterTitle];
    };
    
    [self showPopup:vc];
}

- (void) showDetailAutoComplete: (NSString*) url {
    DetailWithAutocomplete *vc = [[UIStoryboard storyboardWithName:@
                               "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailWithAutocomplete"];
    vc.url = url;
    vc.title = titleOfList;
    vc.updateHandler =  ^(CodeDescription* model) {
        [self didSelectListWithDescription:nil name:nameOfField withString:model.descriptionValue];
    };
    
    [self showPopup:vc];
}

- (void) showAutocomplete:(NSString*) url {
    [self.view endEditing:YES];
    
    SimpleAutocomplete *vc = [[UIStoryboard storyboardWithName:@
                               "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"SimpleAutocomplete"];
    vc.url = url;
    vc.title = titleOfList;
    vc.updateHandler =  ^(NSString* selectedString) {
        [self didSelectListWithDescription:nil name:nameOfField withString:selectedString];
    };
    
    [self showPopup:vc];
}

- (NSMutableDictionary*) buildParams {
    NSMutableDictionary* data = [NSMutableDictionary new];
    
    if (((NSString*)_contents[2][5][1]).length > 0 && ![_contents[2][5][1] isEqualToString:_propertyModel.accBuildingNo]) {
        [data addEntriesFromDictionary:@{@"accBuildingNo":_contents[2][5][1]}];
    }
    
    if (((NSString*)_contents[2][3][1]).length > 0 && ![_contents[2][3][1] isEqualToString:_propertyModel.accParcelNo]) {
        [data addEntriesFromDictionary:@{@"accParcelNo":_contents[2][3][1]}];
    }
    
    if (((NSString*)_contents[2][4][1]).length > 0 && ![_contents[2][4][1] isEqualToString:_propertyModel.accStoreyNo]) {
        [data addEntriesFromDictionary:@{@"accStoreyNo":_contents[2][4][1]}];
    }
    
    if (((NSString*)_contents[1][12][1]).length > 0 && ![_contents[1][12][1] isEqualToString:_propertyModel.accStoreyNo]) {
        [data addEntriesFromDictionary:@{@"address":_contents[1][12][1]}];
    }
    
    if (((NSString*)_contents[1][13][1]).length > 0 && ![_contents[1][13][1] isEqualToString:_propertyModel.approvingAuthority]) {
        [data addEntriesFromDictionary:@{@"approvingAuthority":_contents[1][13][1]}];
    }
    
    NSMutableDictionary* area = [NSMutableDictionary new];
    if (((NSString*)_contents[1][9][1]).length > 0 && ![_contents[1][9][1] isEqualToString:_propertyModel.area.type]) {
        [area addEntriesFromDictionary:@{@"type":_contents[1][9][1]}];
    }
    
    if (((NSString*)_contents[1][8][1]).length > 0 && ![_contents[1][8][1] isEqualToString:_propertyModel.area.value]) {
        [area addEntriesFromDictionary:@{@"value":_contents[1][8][1]}];
    }
    
    [data addEntriesFromDictionary:@{@"area":area}];
    
    if (((NSString*)_contents[1][6][1]).length > 0 && ![_contents[1][6][1] isEqualToString:_propertyModel.daerah]) {
        [data addEntriesFromDictionary:@{@"daerah":_contents[1][6][1]}];
    }
    
    if (((NSString*)_contents[1][16][1]).length > 0 && ![_contents[1][16][1] isEqualToString:_propertyModel.landUse]) {
        [data addEntriesFromDictionary:@{@"landUse":_contents[1][16][1]}];
    }
    
    if (((NSString*)_contents[1][11][1]).length > 0 && ![[DIHelpers convertDateToMySQLFormat:_contents[1][11][1]] isEqualToString:_propertyModel.leaseExpiryDate]) {
        [data addEntriesFromDictionary:@{@"leaseExpiryDate":[DIHelpers convertDateToMySQLFormat:_contents[1][11][1]]}];
    }
    
    NSMutableDictionary* propertyTitle = [NSMutableDictionary new];
    if (((NSString*)_contents[1][0][1]).length > 0 && ![_contents[1][0][1] isEqualToString:_propertyModel.title.type]) {
        [propertyTitle addEntriesFromDictionary:@{@"type":_contents[1][0][1]}];
    }
    
    if (((NSString*)_contents[1][1][1]).length > 0 && ![_contents[1][1][1] isEqualToString:_propertyModel.title.value]) {
        [propertyTitle addEntriesFromDictionary:@{@"value":_contents[1][1][1]}];
    }
    [data addEntriesFromDictionary:@{@"title":propertyTitle}];
    
    NSMutableDictionary* lotPT = [NSMutableDictionary new];
    if (((NSString*)_contents[1][2][1]).length > 0 && ![_contents[1][2][1] isEqualToString:_propertyModel.lotPT.type]) {
        [lotPT addEntriesFromDictionary:@{@"type":_contents[1][2][1]}];
    }
    
    if (((NSString*)_contents[1][3][1]).length > 0 && ![_contents[1][3][1] isEqualToString:_propertyModel.lotPT.value]) {
        [lotPT addEntriesFromDictionary:@{@"value":_contents[1][3][1]}];
    }
    [data addEntriesFromDictionary:@{@"lotPT":lotPT}];
    
    NSMutableDictionary* mukim = [NSMutableDictionary new];
    if (((NSString*)_contents[1][4][1]).length > 0 && ![_contents[1][4][1] isEqualToString:_propertyModel.mukim.type]) {
        [mukim addEntriesFromDictionary:@{@"type":_contents[1][4][1]}];
    }
    
    if (((NSString*)_contents[1][5][1]).length > 0 && ![_contents[1][5][1] isEqualToString:_propertyModel.mukim.value]) {
        [mukim addEntriesFromDictionary:@{@"value":_contents[1][5][1]}];
    }
    [data addEntriesFromDictionary:@{@"mukim":mukim}];
    
    if (((NSString*)_contents[1][7][1]).length > 0 && ![_contents[1][7][1] isEqualToString:_propertyModel.negeri]) {
        [data addEntriesFromDictionary:@{@"negeri":_contents[1][7][1]}];
    }
    
    if (selectedPropertyType.length > 0 && ![selectedPropertyType isEqualToString:_propertyModel.propertyType.codeValue]) {
        [data addEntriesFromDictionary:@{@"propertyType": @{@"code":selectedPropertyType}}];
    }
    
    if (((NSString*)_contents[1][13][1]).length > 0 && ![_contents[1][13][1] isEqualToString:_propertyModel.restrictionAgainst]) {
        [data addEntriesFromDictionary:@{@"restrictionAgainst":_contents[1][13][1]}];
    }
    
    if (selectedRestrictionCode.length > 0 && ![selectedRestrictionCode isEqualToString:_propertyModel.restrictionInInterest.codeValue]) {
        [data addEntriesFromDictionary:@{@"restrictionInInterest": @{@"code":selectedRestrictionCode}}];
    }
    
    if (((NSString*)_contents[2][4][1]).length > 0 && ![_contents[2][4][1] isEqualToString:_propertyModel.spaAccParcelNo]) {
        [data addEntriesFromDictionary:@{@"spaAccParcelNo":_contents[2][4][1]}];
    }
    
    NSMutableDictionary* spaArea = [NSMutableDictionary new];
    if (((NSString*)_contents[3][6][1]).length > 0 && ![_contents[3][6][1] isEqualToString:_propertyModel.spaArea.type]) {
        [spaArea addEntriesFromDictionary:@{@"type":_contents[3][6][1]}];
    }
    
    if (((NSString*)_contents[3][7][1]).length > 0 && ![_contents[3][7][1] isEqualToString:_propertyModel.spaArea.value]) {
        [spaArea addEntriesFromDictionary:@{@"value":_contents[3][7][1]}];
    }
    [data addEntriesFromDictionary:@{@"spaArea":spaArea}];
    
    if (((NSString*)_contents[3][3][1]).length > 0 && ![_contents[3][3][1] isEqualToString:_propertyModel.spaBuildingNo]) {
        [data addEntriesFromDictionary:@{@"spaBuildingNo":_contents[3][3][1]}];
    }
    
    if (((NSString*)_contents[3][4][1]).length > 0 && ![_contents[3][4][1] isEqualToString:_propertyModel.spaCondoName]) {
        [data addEntriesFromDictionary:@{@"spaCondoName":_contents[3][4][1]}];
    }
    
    NSMutableDictionary* spaParcel = [NSMutableDictionary new];
    if (((NSString*)_contents[3][0][1]).length > 0 && ![_contents[3][0][1] isEqualToString:_propertyModel.spaParcel.type]) {
        [spaParcel addEntriesFromDictionary:@{@"type":_contents[3][0][1]}];
    }
    
    if (((NSString*)_contents[3][1][1]).length > 0 && ![_contents[3][1][1] isEqualToString:_propertyModel.spaParcel.value]) {
        [spaParcel addEntriesFromDictionary:@{@"value":_contents[3][1][1]}];
    }
    [data addEntriesFromDictionary:@{@"spaParcel":spaParcel}];
    
    if (((NSString*)_contents[3][2][1]).length > 0 && ![_contents[3][2][1] isEqualToString:_propertyModel.spaStoreyNo]) {
        [data addEntriesFromDictionary:@{@"spaStoreyNo":_contents[3][2][1]}];
    }
    
    if (((NSString*)_contents[1][10][1]).length > 0 && ![_contents[1][10][1] isEqualToString:_propertyModel.tenure]) {
        [data addEntriesFromDictionary:@{@"tenure":_contents[1][10][1]}];
    }
    
    if (selectedTitleIssuedCode.length > 0 && ![selectedTitleIssuedCode isEqualToString:_propertyModel.titleIssued.codeValue]) {
        [data addEntriesFromDictionary:@{@"titleIssued": @{@"code":selectedTitleIssuedCode}}];
    }
    
    if (((NSString*)_contents[2][7][1]).length > 0 && ![_contents[2][7][1] isEqualToString:_propertyModel.totalShare]) {
        [data addEntriesFromDictionary:@{@"totalShare":_contents[2][7][1]}];
    }
    
    if (((NSString*)_contents[2][6][1]).length > 0 && ![_contents[2][6][1] isEqualToString:_propertyModel.tenure]) {
        [data addEntriesFromDictionary:@{@"unitShare":_contents[2][6][1]}];
    }
    
    return data;
}

- (void) _save:(NSDictionary*) params {
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] savePropertyWithParams:params inURL:PROPERTY_SAVE_URL WithCompletion:^(AddPropertyModel * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully saved" duration:2.0];
            _viewType = @"view";
            _propertyModel = result;
            [self prepareUI];
            [self.tableView reloadData];
//            [self performSegueWithIdentifier:kAddPropertySegue sender:result];
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:2.0];
        }
    }];
}

- (void) _update:(NSDictionary*) params {
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] updatePropertyWithParams:params inURL:PROPERTY_SAVE_URL WithCompletion:^(AddPropertyModel * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully updated" duration:2.0];
            _viewType = @"view";
            _propertyModel = result;
            [self prepareUI];
            [self.tableView reloadData];
            
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:2.0];
        }
    }];
}

- (BOOL) checkValidation {
    if (((NSString*)_contents[0][0][1]).length == 0) {
        [QMAlert showAlertWithMessage:@"Please Select Property Type" actionSuccess:NO inViewController:self];
        return NO;
    }
    if (((NSString*)_contents[0][1][1]).length == 0) {
        if ([_contents[0][1][1] isEqualToString:@"Issued"]) {
            if (((NSString*)_contents[1][0][1]).length == 0) {
                [QMAlert showAlertWithMessage:@"Please Select Title Type" actionSuccess:NO inViewController:self];
                return NO;
            }
            if (((NSString*)_contents[1][1][1]).length == 0) {
                [QMAlert showAlertWithMessage:@"Please Select Title No" actionSuccess:NO inViewController:self];
                return NO;
            }
            if (((NSString*)_contents[1][2][1]).length == 0) {
                [QMAlert showAlertWithMessage:@"Please Select Lot Type" actionSuccess:NO inViewController:self];
                return NO;
            }
            if (((NSString*)_contents[1][3][1]).length == 0) {
                [QMAlert showAlertWithMessage:@"Please Select Lot No" actionSuccess:NO inViewController:self];
                return NO;
            }
        } else {
            if (((NSString*)_contents[3][0][1]).length == 0) {
                [QMAlert showAlertWithMessage:@"Please Select Parcel Type" actionSuccess:NO inViewController:self];
                return NO;
            }
            if (((NSString*)_contents[2][0][1]).length == 0) {
                [QMAlert showAlertWithMessage:@"Please Select Parcel No" actionSuccess:NO inViewController:self];
                return NO;
            }
            if (((NSString*)_contents[2][1][1]).length == 0) {
                [QMAlert showAlertWithMessage:@"Please Select Storey No" actionSuccess:NO inViewController:self];
                return NO;
            }
        }
    } else {
        [QMAlert showAlertWithMessage:@"Please Select Individual/Strata Title" actionSuccess:NO inViewController:self];
        return NO;
    }
    
    return YES;
}

- (IBAction)saveProperty:(id)sender {
    NSMutableDictionary* params = [self buildParams];
    if ([_viewType isEqualToString:@"view"]) {
        [params addEntriesFromDictionary:@{@"code":_propertyModel.propertyCode}];
        [QMAlert showConfirmDialog:@"Do you want to update contact?" inViewController:self completion:^(UIAlertAction * _Nonnull action) {
            if  ([action.title isEqualToString:@"OK"]) {
                if ([self checkValidation]) {
                    [self _update:params];
                }
            }
        }];
    } else {
        if ([self checkValidation]) {
            [self _save:params];
        }
    }
}

- (void) registerNib {
    self.tableView.allowMultipleSectionsOpen = YES;
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(0), @(1), nil];
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [FloatingTextCell registerForReuseInTableView:self.tableView];
    [FloatingTextTwoColumnReversedCell registerForReuseInTableView:self.tableView];
    [FloatingTextTwoColumnCell registerForReuseInTableView:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"AccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return [self.contents[section] count] - 4;
    }
    if (section == 3) {
        return [self.contents[section] count] - 2;
    }
    return [self.contents[section] count];
}

- (NSInteger) calcPrevRowCount: (NSInteger) curSection
{
    NSInteger count = 0;
    
    for (int i = 0; i < curSection; i++) {
        count += [_contents[i] count];
    }
    return count;
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
    
    if ((indexPath.section == 3 && indexPath.row == 0 ) || (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2))) {
        NSInteger rows = indexPath.row;

        FloatingTextTwoColumnCell *cell = [tableView dequeueReusableCellWithIdentifier:[FloatingTextTwoColumnCell cellIdentifier] forIndexPath:indexPath];
        if (indexPath.section == 1) {
            if (indexPath.row == 1) {
                rows += 1;
            }
            
            if (indexPath.row == 2) {
                rows += 2;
            }
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.rightFloatingText.tag = [self calcPrevRowCount:indexPath.section] + rows+1; // consider section 0
        cell.delegate = self;
        cell.leftUtilityButtons = [self leftButtons];
        cell.leftFloatingText.placeholder = self.contents[indexPath.section][rows][0];
        cell.rightFloatingText.placeholder = self.contents[indexPath.section][rows+1][0];
        cell.leftFloatingText.text = self.contents[indexPath.section][rows][1];
        cell.rightFloatingText.text = self.contents[indexPath.section][rows+1][1];
        cell.rightFloatingText.floatLabelActiveColor = cell.rightFloatingText.floatLabelPassiveColor = cell.leftFloatingText.floatLabelActiveColor = cell.leftFloatingText.floatLabelPassiveColor = [UIColor redColor];
        
        cell.leftFloatingText.inputAccessoryView = accessoryView;
        cell.rightFloatingText.inputAccessoryView = accessoryView;
        cell.leftFloatingText.keyboardType = UIKeyboardTypeDefault;
        if (indexPath.section == 3 && indexPath.row == 0) {
            cell.rightFloatingText.keyboardType = UIKeyboardTypeDefault;
        }
        
        cell.rightFloatingText.delegate = self;
        cell.leftFloatingText.userInteractionEnabled = NO;
//        if (![_viewType isEqualToString:@"view"]) {
//            cell.rightFloatingText.userInteractionEnabled = YES;
//        } else {
//            cell.rightFloatingText.userInteractionEnabled = NO;
//        }
        
        cell.rightDetailDisclosure.hidden = YES;
        if (indexPath.section == 1 ) {
            if (indexPath.row == 2) {
                cell.rightDetailDisclosure.hidden = NO;
                cell.rightDetailDisclosure.hidden = NO;
                cell.leftFloatingText.delegate = self;
                cell.leftFloatingText.userInteractionEnabled = YES;
                cell.leftFloatingText.tag = 104;
                cell.rightFloatingText.tag = 105;
//                if (![_viewType isEqualToString:@"view"]) {
//                    cell.leftFloatingText.userInteractionEnabled = YES;
//                } else {
//                    cell.rightFloatingText.userInteractionEnabled = NO;
//                }
            }
        }
        
        return cell;
    }
    
    if ((indexPath.section == 1 && indexPath.row == 5) || (indexPath.section == 3 && indexPath.row == 5)) {
        FloatingTextTwoColumnReversedCell *cell = [tableView dequeueReusableCellWithIdentifier:[FloatingTextTwoColumnReversedCell cellIdentifier] forIndexPath:indexPath];
        NSInteger rows = indexPath.row;
        if (indexPath.section == 1) {
            rows += 3;
//            if (![_viewType isEqualToString:@"view"]) {
//                cell.rightType.userInteractionEnabled = YES;
//            } else {
//                cell.rightType.userInteractionEnabled = NO;
//            }
            if (indexPath.row == 5) {
                cell.rightType.userInteractionEnabled = NO;
            }
        }
        if (indexPath.section == 3) {
            rows += 1;
            cell.rightType.userInteractionEnabled = NO;
        }
        cell.delegate = self;
        cell.leftUtilityButtons = [self leftButtons];
        cell.leftValue.delegate = self;
        cell.leftValue.keyboardType = UIKeyboardTypeDecimalPad;
        cell.leftValue.tag = [self calcPrevRowCount:indexPath.section] + rows;
        cell.leftValue.delegate = self;
        
        cell.leftValue.placeholder = self.contents[indexPath.section][rows][0];
        cell.rightType.placeholder = self.contents[indexPath.section][rows+1][0];
        cell.leftValue.text = self.contents[indexPath.section][rows][1];
        cell.rightType.text = self.contents[indexPath.section][rows+1][1];
        cell.rightType.floatLabelActiveColor = cell.rightType.floatLabelPassiveColor = cell.leftValue.floatLabelActiveColor = cell.leftValue.floatLabelPassiveColor = [UIColor redColor];
        
        cell.leftValue.inputAccessoryView = accessoryView;
        cell.rightType.inputAccessoryView = accessoryView;
        return cell;
    }
    
    FloatingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[FloatingTextCell cellIdentifier] forIndexPath:indexPath];
    
    NSInteger rows = [self calcRow:indexPath];
    
    cell.floatingTextField.tag = [self calcPrevRowCount:indexPath.section] + rows;
    
    if ([self.contents[indexPath.section][rows][0] isKindOfClass:[NSDictionary class]]) {
        cell.floatingTextField.placeholder = self.contents[indexPath.section][rows][0];
    } else {
        cell.floatingTextField.placeholder = self.contents[indexPath.section][rows][0];
        cell.floatingTextField.text = self.contents[indexPath.section][rows][1];
    }
    
    
    cell.floatingTextField.floatLabelActiveColor = cell.floatingTextField.floatLabelPassiveColor = [UIColor redColor];
    
    cell.floatingTextField.inputAccessoryView = accessoryView;
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;

    cell.accessoryType = UITableViewCellAccessoryNone;
//    if (![_viewType isEqualToString:@"view"]) {
//        cell.floatingTextField.userInteractionEnabled = YES;
//    } else {
//        cell.floatingTextField.userInteractionEnabled = NO;
//    }
    cell.floatingTextField.delegate = self;
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 2) {
           cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.floatingTextField.userInteractionEnabled = NO;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 6 || indexPath.row == 7 || (indexPath.row >= 9  && indexPath.row <= 12)) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.floatingTextField.userInteractionEnabled = NO;
        }
        
        cell.floatingTextField.keyboardType = UIKeyboardTypeDefault;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 6 || indexPath.row == 7) {
            cell.floatingTextField.keyboardType = UIKeyboardTypeNumberPad;
        } else {
            cell.floatingTextField.keyboardType = UIKeyboardTypeDefault;
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 5) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.floatingTextField.userInteractionEnabled = NO;
        }
        if (indexPath.row == 4) {
            cell.floatingTextField.keyboardType = UIKeyboardTypeDefault;
        } else {
            cell.floatingTextField.keyboardType = UIKeyboardTypeDefault;
        }
    } else if (indexPath.section == 4) {
        if (indexPath.row == 0 || indexPath.row == 3) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.floatingTextField.userInteractionEnabled = NO;
    }
    
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

- (NSInteger) calcRow:(NSIndexPath*) indexPath {
    NSInteger rows = indexPath.row;
    if (indexPath.section == 1) {
        if (indexPath.row > 2 && indexPath.row < 5) {
            rows += 3;
        }
        else if (indexPath.row > 5) {
            rows += 4;
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row > 0) {
            rows += 1;
        }
    }
    return rows;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    [cell hideUtilityButtonsAnimated:YES];
    NSInteger rows = [self calcRow:indexPath];
    BOOL isTwoColumn = NO;
    if (indexPath.section == 1) {
        if (indexPath.row > 2 && indexPath.row < 5) {
            rows += 3;
            isTwoColumn = YES;
        }
        else if (indexPath.row > 5) {
            rows += 4;
            isTwoColumn = YES;
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row > 0) {
            rows += 1;
            isTwoColumn = YES;
        }
    }
    if (isTwoColumn) {
        [self replaceContentForSection:indexPath.section InRow:rows withValue:@""];
        [self replaceContentForSection:indexPath.section InRow:rows+1 withValue:@""];
    } else {
        [self replaceContentForSection:indexPath.section InRow:rows withValue:@""];
    }
}

#pragma mark - UITextField Delegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 104) {
        titleOfList = @"Mukim Type";
        nameOfField = self.contents[1][4][0];
//        [self performSegueWithIdentifier:kListWithDescriptionSegue sender:PROPERTY_MUKIM_TYPE_GET_URL];
        [self showAutocomplete:PROPERTY_MUKIM_TYPE_GET_URL];
        return NO;
    } else if (textField.tag == 105) {
        [self performSegueWithIdentifier:kMukimValueSegue sender:nil];
        return NO;
    }
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSArray* obj = [self calcSectionNumber:textField.tag];
    
    if ([obj[0] integerValue] == 2 && ([obj[1] integerValue] == 6 || [obj[1] integerValue] == 7))
    {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [DIHelpers addThousandsSeparator:text];;
        return NO;
    }
    
    if (([obj[0] integerValue] == 3 && [obj[1] integerValue] == 6)) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [DIHelpers formatDecimal:text];;
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0) {
        return;
    }
    NSMutableString* string = [[DIHelpers capitalizedString:textField.text] mutableCopy];
    NSArray* obj = [self calcSectionNumber:textField.tag];
    if ([obj[0] integerValue] == 3 && ([obj[1] integerValue] == 2 || [obj[1] integerValue] == 3)) {
        string = [string.localizedUppercaseString mutableCopy];
    }
    if ([obj[0] integerValue] == 2) {
        string = [string.localizedUppercaseString mutableCopy];
    }
    [self replaceContentForSection:[obj[0] integerValue] InRow:[obj[1] integerValue] withValue:string];
    textField.text = string;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
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
    if (section == 0) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor lightGrayColor];
        return view;
    }
 
    return [self updateCustomSectionHeaderInSection:section withTableView:tableView];
}

- (void) showCalendar {
    [self.view endEditing:YES];
    
    BirthdayCalendarViewController *calendarViewController = [[UIStoryboard storyboardWithName:@
                                                               "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        [self replaceContentForSection:1 InRow:11 withValue:date];
    };
    [self showPopup:calendarViewController];
}

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if ([_viewType isEqualToString:@"view"]) {
//        return;
//    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            titleOfList = @"Select Property Type";
            nameOfField = self.contents[indexPath.section][indexPath.row][0];
            [self performSegueWithIdentifier:kListWithCodeSegue sender:PROPERTY_TYPE_GET_LIST_URL];
        } else if (indexPath.row == 1) {
            titleOfList = @"Issued Title of Property";
            nameOfField = self.contents[indexPath.section][indexPath.row][0];
            [self performSegueWithIdentifier:kListWithCodeSegue sender:PROPERTY_TITLE_ISSUED_GET_URL];
        }
    } else if (indexPath.section == 1) {
        NSInteger rows = indexPath.row;
        if (indexPath.row == 1) {
            rows += 1;
        }
        if (indexPath.row == 2) {
            rows += 2;
        }
        if (indexPath.row > 2 && indexPath.row <= 5) {
            rows += 3;
        }
        else if (indexPath.row > 5) {
            rows += 4;
        }
        if (indexPath.row == 0) {
            titleOfList = @"Title Type";
            nameOfField = self.contents[indexPath.section][rows][0];
            [self showAutocomplete:PROPERTY_TITLE_TYPE_GET_URL];
        } else if (indexPath.row == 1) {
            titleOfList = @"Lot Type";
            nameOfField = self.contents[indexPath.section][rows][0];
            [self showAutocomplete:PROPERTY_LOT_TYPE_GET_URL];
        } else if (indexPath.row == 3) {
            
        } else if (indexPath.row == 5) {
            titleOfList = @"Area Type";
            nameOfField = self.contents[indexPath.section][rows+1][0];
            [self performSegueWithIdentifier:kListWithDescriptionSegue sender:PROPERTY_AREA_TYPE_GET_URL];
        } else if (indexPath.row == 6) {
            titleOfList = @"Tenure Type";
            nameOfField = self.contents[indexPath.section][rows][0];
            [self performSegueWithIdentifier:kListWithDescriptionSegue sender:PROPERTY_TENURE_TYPE_GET_URL];
        } else if (indexPath.row == 7) {
            [self showCalendar];
        } else if (indexPath.row == 9) {
            titleOfList = @"Restriction in Interest";
            nameOfField = self.contents[indexPath.section][rows][0];
            [self performSegueWithIdentifier:kListWithCodeSegue sender:PROPERTY_RESTRICTION_GET_URL];
        } else if (indexPath.row == 10) {
            titleOfList = @"Restriction Against";
            nameOfField = self.contents[indexPath.section][rows][0];
//            [self performSegueWithIdentifier:kListWithDescriptionSegue sender:PROPERTY_RESTRICTION_AGAINST_GET_URL];
            [self showAutocomplete:PROPERTY_RESTRICTION_AGAINST_GET_URL];
        }else if (indexPath.row == 11) {
            titleOfList = @"Approving Authority";
            nameOfField = self.contents[indexPath.section][rows][0];
//            [self performSegueWithIdentifier:kListWithCodeSegue sender:PROPERTY_APPROVING_AUTHORITY_GET_URL];
            [self showDetailAutoComplete:PROPERTY_APPROVING_AUTHORITY_GET_URL];
        } else if (indexPath.row == 12) {
            titleOfList = @"Category of Land Use";
            nameOfField = self.contents[indexPath.section][rows][0];
//            [self performSegueWithIdentifier:kListWithDescriptionSegue sender:PROPERTY_LANDUSE_GET_URL];
            [self showAutocomplete:PROPERTY_LANDUSE_GET_URL];
        }
    } else if (indexPath.section == 3) {
        NSInteger rows = indexPath.row;
        if (rows > 0) {
            rows += 1;
        }
       
        if (indexPath.row == 0) {
            titleOfList = @"Parcel Type";
            nameOfField = self.contents[indexPath.section][rows][0];
            [self showAutocomplete:PROPERTY_PARCEL_TYPE_GETLIST_URL];
//            [self performSegueWithIdentifier:kListWithDescriptionSegue sender:PROPERTY_PARCEL_TYPE_GETLIST_URL];
        } else if (indexPath.row == 5) {
            titleOfList = @"Measurement Type of Property";
            nameOfField = self.contents[indexPath.section][rows+1][0];
            [self performSegueWithIdentifier:kListWithDescriptionSegue sender:PROPERTY_AREA_TYPE_GET_URL];
        }
    } else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            nameOfField = self.contents[indexPath.section][indexPath.row][0];
            [self showPropertyAutocomplete:PROPERTY_PROJECT_HOUSING_GET_URL];
        } else if (indexPath.row == 3) {
            nameOfField = self.contents[indexPath.section][indexPath.row][0];
            [self performSegueWithIdentifier:kMasterTitleSegue sender:PROPERTY_MASTER_TITLE_GETLIST_URL];
        }
    }
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
    if ([name isEqualToString:@"Property Type"]) {
        [self replaceContentForSection:0 InRow:0 withValue:model.descriptionValue];
        selectedPropertyType = model.codeValue;
    }else if ([name isEqualToString:@"Individual / Strata Title"]) {
        [self replaceContentForSection:0 InRow:1 withValue:model.descriptionValue];
        selectedTitleIssuedCode = model.codeValue;
    } else if ([name isEqualToString:@"Restriction in Interest"]) {
        [self replaceContentForSection:1 InRow:13 withValue:model.descriptionValue];
        selectedRestrictionCode = model.codeValue;
    } else if ([name isEqualToString:@"Approving Authority"]) {
        [self replaceContentForSection:1 InRow:15 withValue:model.descriptionValue];
        selectedRestrictionCode = model.codeValue;
    }
}

#pragma mark - ContactListWithDescriptionDelegate
- (void) didSelectListWithDescription:(UIViewController *)listVC name:(NSString*) name withString:(NSString *)description
{
    if ([name isEqualToString:@"Area Type"]) {
        [self replaceContentForSection:1 InRow:9 withValue:description];
    } else {
        for (int i = 0; i < self.tableView.numberOfSections; i ++) {
            for (int j = 0; j < [_contents[i] count]; j++) {
                NSLog(@"(%d, %d)", i, j);
                if ([name isEqualToString:_contents[i][j][0]]) {
                    [self replaceContentForSection:i InRow:j withValue:description];
                }
            }
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kListWithDescriptionSegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        ListWithDescriptionViewController* vc = navVC.viewControllers.firstObject;
        vc.url = sender;
        vc.titleOfList = titleOfList;
        vc.name = nameOfField;
        vc.contactDelegate = self;
    }
    
    if ([segue.identifier isEqualToString:kListWithCodeSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        ListWithCodeTableViewController *listCodeVC = navVC.viewControllers.firstObject;
        listCodeVC.delegate = self;
        listCodeVC.titleOfList = titleOfList;
        listCodeVC.name = nameOfField;
        listCodeVC.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kContactGetListSegue]) {
        PropertyContactListViewController* contactVC = segue.destinationViewController;
        contactVC.updateHandler = ^(StaffModel *model) {
            [self replaceContentForSection:4 InRow:selectedContactRow withValue:model.name];
        };
    }
    
    if ([segue.identifier isEqualToString:kMukimValueSegue]) {
        MukimValueList* vc = segue.destinationViewController;
        vc.updateHandler = ^(MukimModel *model) {
            [self replaceContentForSection:1 InRow:5 withValue:model.mukim];
            [self replaceContentForSection:1 InRow:6 withValue:model.daerah];
            [self replaceContentForSection:1 InRow:7 withValue:model.negeri];
        };
    }
    
    if ([segue.identifier isEqualToString:kMasterTitleSegue]) {
        MasterTitleView* vc = segue.destinationViewController;
        vc.updateHandler = ^(MasterTitleModel *model) {
            [self replaceContentForSection:4 InRow:3 withValue:model.masterCode];
        };
    }
}


@end
