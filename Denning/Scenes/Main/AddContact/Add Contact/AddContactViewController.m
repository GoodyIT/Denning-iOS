//
//  AddContactViewController.m
//  Denning
//
//  Created by DenningIT on 20/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddContactViewController.h"
#import "ListWithCodeTableViewController.h"
#import "ListWithDescriptionViewController.h"

#import "BirthdayCalendarViewController.h"
#import "ContactViewController.h"
#import "BranchListViewController.h"
#import "SimpleAutocomplete.h"
#import "PostCodeAutoComplete.h"
#import "DetailWithAutocomplete.h"
#import "CountryAutoCompleteViewController.h"
#import "PhoneNumberAutoComplete.h"
#import <NBPhoneNumberUtil.h>
#import <NBPhoneNumber.h>

@interface AddContactViewController() <SWTableViewCellDelegate>
{
    __block BOOL isIDChecking, isNameChecking;
    __block BOOL isIDDuplicated, isNameDuplicated;
    NSInteger selectedRow;
    
    NSString* titleOfList;
    NSString* nameOfField;
    NSString* selectedIDTypeCode;
    NSString* selectedCitizenCode;
    NSString* selectedIRDBranchCode;
    NSString* selectedTitleCode;
    NSString* selectedOccupationCode;
    
    NSArray *countriesList;
    NSMutableArray *countriesNameList;
    NSString* homeCountryCallingCode;
    NSString* homeCountryCode;
    
    NSString* mobileCountryCallingCode;
    NSString* mobileCountryCode;
    
    NSString* officeCountryCallingCode;
    NSString* officeCountryCode;
    
    NSString* faxCountryCallingCode;
    NSString* faxCountryCode;
    
    NSString* selectedPhoneHome;
    NSString* selectedPhoneMobile;
    NSString* selectedPhoneOffice;
    NSString* selectedPhoneFax;
    
    NSInteger phoneTag;
    
    NSArray* headers;
}

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *IDType;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *IDNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *oldIC;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *name;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *contactTitle;

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *address1;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *address2;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *address3;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *town;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *state;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *postcode;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *email;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *phoneHome;
@property (weak, nonatomic) IBOutlet UIButton *phoneHomeBtn;

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *phoneMobile;
@property (weak, nonatomic) IBOutlet UIButton *phoneMobileBtn;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *phoneOffice;
@property (weak, nonatomic) IBOutlet UIButton *phoneOfficeBtn;
@property (weak, nonatomic) IBOutlet UIButton *faxBtn;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *country;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *fax;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *contactPerson;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *website;

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *citizenship;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *dateOfBirth;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *occupation;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *taxFileNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *IRDBranch;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *registeredOffice;
@property (weak, nonatomic) IBOutlet UISwitch *inviteDenning;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet SWTableViewCell *IDTypeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *IDNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *OldICCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *titleCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *address1Cell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *address2Cell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *address3Cell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *townCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *stateCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *postCodeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *phoneHomeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *phoneMobileCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *phoneOfficeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *countryCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *faxCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *contactPersonCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *websiteCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *citizenshipCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *dateOfBirthCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *occupationCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *taxFileNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *IRDBranchCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *registeredOfficeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *inviteDenningCell;

@end

@implementation AddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self setDefaultCountryCode];
}

- (void) setDefaultCountryCode
{
    NSString* selectedCountryCallingCode, *selectedCountryCode;
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSString *buttonTitle;
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"]];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        NSLog(@"%@", [localError userInfo]);
    }
    
    countriesList = (NSArray *)parsedObject;
    for (id obj in countriesList) {
        if ([[obj objectForKey:kCountryCode] isEqualToString:countryCode]) {
            buttonTitle = [NSString stringWithFormat:@"(%@)", [obj objectForKey:kCountryCallingCode]];
            selectedCountryCallingCode = [obj objectForKey:kCountryCallingCode];
            selectedCountryCode = [obj objectForKey:kCountryCode];
        }
    }
    
    [self.phoneHomeBtn setTitle:buttonTitle forState:UIControlStateNormal];
    [self.phoneMobileBtn setTitle:buttonTitle forState:UIControlStateNormal];
    [self.phoneOfficeBtn setTitle:buttonTitle forState:UIControlStateNormal];
    [self.faxBtn setTitle:buttonTitle forState:UIControlStateNormal];
    
    homeCountryCode = mobileCountryCode = officeCountryCode = faxCountryCode= selectedCountryCode;
    homeCountryCallingCode = mobileCountryCallingCode = officeCountryCallingCode = faxCountryCallingCode= selectedCountryCallingCode;
}

- (IBAction)didTapHomeBtn:(id)sender {
    phoneTag = 1;
    [self showCountryCodeList:_phoneHomeBtn];
}

- (IBAction)didTapMobileBtn:(id)sender {
    phoneTag = 2;
   [self showCountryCodeList:_phoneMobileBtn];
}

- (IBAction)didTapOfficeBtn:(id)sender {
    phoneTag = 2;
    [self showCountryCodeList:_phoneOfficeBtn];
}

- (IBAction)didTapFaxbtn:(id)sender {
    phoneTag = 3;
    [self showCountryCodeList:_faxBtn];
}

- (void) showCountryCodeList:(UIButton*) countryBtn {
    PhoneNumberAutoComplete *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PhoneNumberAutoComplete"];
    
    vc.updateHandler =  ^(NSString* countryCode, NSString* countryCallingCode) {
        switch (phoneTag) {
            case 1:
                homeCountryCode = countryCode;
                homeCountryCallingCode = countryCallingCode;
                break;
            case 2:
                mobileCountryCode = countryCode;
                mobileCountryCallingCode = countryCallingCode;
                break;
            case 3:
                officeCountryCode = countryCode;
                officeCountryCallingCode = countryCallingCode;
                break;
            case 4:
                faxCountryCode = countryCode;
                faxCountryCallingCode = countryCallingCode;
                break;
                
            default:
                break;
        }
        
        NSString *buttonTitle = [NSString stringWithFormat:@"(%@)",countryCallingCode];
        [countryBtn setTitle: buttonTitle forState:UIControlStateNormal];
    };
    [self showPopup:vc];
}

- (void) checkIDValidation:(NSString*) value url:(NSString*) url message:(NSString*) message withCompletion:(void(^)(void)) completion withFinalCompletion:(void(^)(void)) finalCompletion{
  
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"Checking", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    [[QMNetworkManager sharedManager] checkIDorNameDuplication:value url:url WithCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        
        if (finalCompletion!= nil) {
            finalCompletion();
        }
        
        if (error == nil) {
            if (result.count == 0) {
                [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Done" duration:1.0];
            } else {
                [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:message duration:2.0];
                
                if (completion != nil) {
                    completion();
                }
            }
            
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];

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

- (void) showCountryAutocomplete:(NSString*) url {
    [self.view endEditing:YES];
    
    CountryAutoCompleteViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CountryAutoCompleteViewController"];

    vc.updateHandler =  ^(NSString* model) {
        self.country.text = model;
    };
    [self showPopup:vc];
}

- (void) showDetailAutocomplete:(NSString*) url {
    [self.view endEditing:YES];
    
    DetailWithAutocomplete *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailWithAutocomplete"];
    vc.url = url;
    vc.updateHandler =  ^(CodeDescription* model) {
        if ([nameOfField isEqualToString:@"Occupation"]) {
            self.occupation.text = model.descriptionValue;
            selectedOccupationCode = model.codeValue;
        } else {
            self.citizenship.text = model.descriptionValue;
            selectedCitizenCode = model.codeValue;
        }
    };
    [self showPopup:vc];
}

- (void) showSimpleAutocomplete:(NSString*) url {
    [self.view endEditing:YES];
    
    SimpleAutocomplete *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SimpleAutocomplete"];
    vc.url = url;
    vc.title = titleOfList;
    vc.updateHandler =  ^(NSString* selectedString) {
        [self didSelectListWithDescription:nil name:nameOfField withString:selectedString];
    };
    
    [self showPopup:vc];
}

- (void) showPostcodeAutocomplete: (NSString*) url {
    [self.view endEditing:YES];
    
    PostCodeAutoComplete *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PostCodeAutoComplete"];
    vc.url = url;
    vc.title = @"Postcode";
    vc.updateHandler =  ^(CityModel* city) {
        self.postcode.text = city.postcode;
        self.town.text = city.city;
        self.state.text = city.state;
        self.country.text = city.country;
    };
    
    [self showPopup:vc];
}


- (BOOL) checkPhoneValidation:(NSString*) selectedCountryCallingCode selectedCountryCode:(NSString*)selectedCountryCode textfield:(UITextField*)phoneField
{
    if (phoneField.text.length == 0) {
        return YES;
    }
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    selectedPhoneHome = [selectedCountryCallingCode stringByAppendingString:phoneField.text];
    NBPhoneNumber *myPhoneNumber = [phoneUtil parse:phoneField.text
                                 defaultRegion:selectedCountryCode error:&anError];
    if (![phoneUtil isValidNumber:myPhoneNumber]) {
        [QMAlert showAlertWithMessage:@"Please input valid phone number" actionSuccess:NO inViewController:self];
        return NO;
    }
    
    return YES;
}

- (BOOL) checkValidation {
    if (selectedIDTypeCode.length == 0) {
        [QMAlert showAlertWithMessage:@"ID Type is must" actionSuccess:NO inViewController:self];
        return NO;
    }
    
    if ([selectedIDTypeCode integerValue] == 1 && self.oldIC.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please input the Old IC" actionSuccess:NO inViewController:self];
        return NO;
    }

    if (self.name.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Name is must" actionSuccess:NO inViewController:self];
        return NO;
    }
    
    if (self.IDNo.text.length == 0) {
        [QMAlert showAlertWithMessage:@"ID No is must" actionSuccess:NO inViewController:self];
        return NO;
    }
    
    if (![self checkPhoneValidation:homeCountryCallingCode selectedCountryCode:homeCountryCode textfield:self.phoneHome]) {
        return NO;
    }
    
    if (![self checkPhoneValidation:mobileCountryCallingCode selectedCountryCode:mobileCountryCode textfield:self.phoneMobile]) {
        return NO;
    }
    
    if (![self checkPhoneValidation:officeCountryCallingCode selectedCountryCode:officeCountryCode textfield:self.phoneOffice]) {
        return NO;
    }
    
    return YES;
}

- (NSString*) getNotNull: (NSString*) value {
    if (value == nil) {
        return @"";
    }
    else {
        return value;
    }
    return value;
}

- (id) getValidValue: (NSString*) value
{
    if (value == nil || value.length == 0) {
        return @"";
    }
    else {
        return value;
    }

    return @"";
}

- (IBAction)saveContact:(id)sender {
    if (![self checkValidation]) {
        return;
    }
    
    if (isIDChecking || isNameChecking) {
        return;
    }
    
    if (isIDDuplicated) {
        [QMAlert showAlertWithMessage:@"ID Duplicated" actionSuccess:NO inViewController:self];
        return;
    }
    
    if (isNameDuplicated) {
        // informing
    }
  
    selectedPhoneHome = @"";
    if (self.phoneHome.text.length > 0) {
        selectedPhoneHome = [homeCountryCallingCode stringByAppendingString: self.phoneHome.text];
    }
    selectedPhoneMobile = @"";
    if (self.phoneMobile.text.length > 0) {
        selectedPhoneMobile = [mobileCountryCallingCode stringByAppendingString: self.phoneMobile.text];
    }
    selectedPhoneOffice = @"";
    if (self.phoneOffice.text.length > 0) {
        selectedPhoneOffice = [officeCountryCallingCode stringByAppendingString: self.phoneOffice.text];
    }
    
    selectedPhoneFax = @"";
    if (self.fax.text.length > 0) {
        selectedPhoneFax = [faxCountryCallingCode stringByAppendingString: self.fax.text];
    }
    
    if (self.viewType == nil || self.viewType.length == 0) {
        [self _save];
    } else {
        [self _update];
    }
}

- (void) clearInput {
  self.IDType.text =  self.contactTitle.text = self.oldIC.text = self.IDNo.text = self.name.text = self.address1.text = self.address2.text = self.address3.text = self.registeredOffice.text = self.postcode.text = self.town.text = self.state.text = self.country.text = self.phoneMobile.text = self.phoneOffice.text = self.phoneHome.text = self.fax.text = self.contactTitle.text = self.IDType.text = self.email.text = self.website.text = self.contactPerson.text = self.dateOfBirth.text = self.occupation.text =  self.citizenship.text = self.taxFileNo.text = self.IRDBranch.text = self.registeredOffice.text = @"";
    
    self.IDType.placeholder = @"ID Type *";
    _IDNo.placeholder = @"ID No *";
    self.inviteDenning.on = NO;
    selectedIDTypeCode = @"";
    selectedTitleCode = @"";
    selectedOccupationCode = @"";
    selectedIRDBranchCode = @"";
}

- (NSMutableDictionary*) buildParams {
    NSMutableDictionary* address = [NSMutableDictionary new];
    if (_town.text.length > 0 && ![_town.text isEqualToString:_contactModel.address.city]) {
        [address addEntriesFromDictionary:@{@"city": [self getValidValue:self.town.text]}];
    }
    
    if (_state.text.length > 0 && ![_state.text isEqualToString:_contactModel.address.state]) {
        [address addEntriesFromDictionary:@{@"state": [self getNotNull:self.state.text]}];
    }
    
    if (_country.text.length > 0 && ![_country.text isEqualToString:_contactModel.address.country]) {
        [address addEntriesFromDictionary:@{@"country": [self getNotNull:self.country.text]}];
    }
    
    if (_postcode.text.length > 0 && ![_postcode.text isEqualToString:_contactModel.address.postCode]) {
        [address addEntriesFromDictionary:@{@"postcode": [self getNotNull:_postcode.text]}];
    }
    
    NSString* fullAddress = [NSString stringWithFormat:@"%@%@%@", _address1.text, _address2.text, _address3.text];
    if (fullAddress.length > 0 && ![fullAddress isEqualToString:_contactModel.address.fullAddress]) {
        [address addEntriesFromDictionary:@{@"fullAddress": [self getNotNull:fullAddress]}];
    }
    
    if (_address1.text.length > 0 && ![_address1.text isEqualToString:_contactModel.address.line1]) {
        [address addEntriesFromDictionary:@{@"line1": [self getNotNull:self.address1.text]}];
    }
    
    if (_address2.text.length > 0 && ![_address1.text isEqualToString:_contactModel.address.line2]) {
        [address addEntriesFromDictionary:@{@"line2": [self getNotNull:self.address2.text]}];
    }
    
    if (_address3.text.length > 0 && ![_address1.text isEqualToString:_contactModel.address.line3]) {
        [address addEntriesFromDictionary:@{@"line3": [self getNotNull:self.address3.text]}];
    }

    NSMutableDictionary* data = [NSMutableDictionary new];
    [data addEntriesFromDictionary:@{@"address":address}];
    if (_IDNo.text.length > 0 && ![_IDNo.text isEqualToString:_contactModel.IDNo]){
        [data addEntriesFromDictionary:@{@"IDNo": _IDNo.text}];
    }
    
    if (selectedIDTypeCode.length > 0 && ![selectedIDTypeCode isEqualToString:_contactModel.idType.codeValue]) {
        [data addEntriesFromDictionary:@{@"idType": @{
                                                 @"code":[self getValidValue:selectedIDTypeCode]
                                                 }}];
    }
    
    if (_name.text.length > 0 && ![_name.text isEqualToString:_contactModel.name]) {
        [data addEntriesFromDictionary:@{@"name": [self getNotNull:self.name.text]}];
    }
    
    if (_email.text.length > 0 && ![_email.text isEqualToString:_contactModel.email]) {
        [data addEntriesFromDictionary:@{@"emailAddress": [self getNotNull:_email.text]}];
    }
    
    if (_phoneMobile.text.length > 0 && ![_phoneMobile.text isEqualToString:_contactModel.mobilePhone]) {
        [data addEntriesFromDictionary:@{@"phoneMobile": [mobileCountryCallingCode stringByAppendingString: [self getNotNull:_phoneMobile.text]]}];
    }
    
    if (_phoneHome.text.length > 0 && ![_phoneHome.text isEqualToString:_contactModel.homePhone]) {
        [data addEntriesFromDictionary:@{@"phoneHome": [homeCountryCallingCode stringByAppendingString:[self getNotNull:_phoneHome.text]]}];
    }
    
    if (_phoneOffice.text.length > 0 && ![_phoneOffice.text isEqualToString:_contactModel.officePhone]) {
        [data addEntriesFromDictionary:@{@"phoneOffice":[officeCountryCallingCode stringByAppendingString:[self getNotNull:_phoneOffice.text]]}];
    }
    
    if (_fax.text.length > 0 && ![_fax.text isEqualToString:_contactModel.fax]) {
        [data addEntriesFromDictionary:@{@"phoneFax": [faxCountryCallingCode stringByAppendingString:[self getNotNull:_fax.text]]}];
    }
    
    if (_dateOfBirth.text.length > 0 && ![[DIHelpers convertDateToMySQLFormat:self.dateOfBirth.text] isEqualToString:_contactModel.dateOfBirth]) {
        [data addEntriesFromDictionary:@{@"dateBirth": [DIHelpers convertDateToMySQLFormat:self.dateOfBirth.text]}];
    }
    
    if (_contactTitle.text.length > 0 && ![_contactTitle.text isEqualToString:_contactModel.contactTitle]) {
        [data addEntriesFromDictionary:@{@"title": [self getNotNull:_contactTitle.text]}];
    }
    
    if (_website.text.length > 0 && ![_website.text isEqualToString:_contactModel.website]) {
        [data addEntriesFromDictionary:@{@"webSite": [self getNotNull:_website.text]}];
    }
    
    if (_contactPerson.text.length > 0 && ![_contactPerson.text isEqualToString:_contactModel.contactPerson]) {
        [data addEntriesFromDictionary:@{@"contactPerson": [self getNotNull:_contactPerson.text]}];
    }
    
    if (selectedIRDBranchCode.length > 0 && ![selectedIRDBranchCode isEqualToString:_contactModel.IRDBranch.codeValue]) {
        [data addEntriesFromDictionary:@{@"irdBranch": @{
                                                 @"code":[self getValidValue:selectedIRDBranchCode]
                                                 }}];
    }
    
    if (selectedOccupationCode.length > 0 && ![selectedOccupationCode isEqualToString:_contactModel.occupation.codeValue]) {
        [data addEntriesFromDictionary:@{@"occupation": @{
                                                 @"code":[self getValidValue:selectedOccupationCode]
                                                 }}];
    }

    if (_registeredOffice.text.length > 0 && ![_registeredOffice.text isEqualToString:_contactModel.registeredOffice]) {
        [data addEntriesFromDictionary:@{@"registeredOffice": [self getNotNull:_registeredOffice.text]}];
    }
    
    if (_taxFileNo.text.length > 0 && ![_taxFileNo.text isEqualToString:_contactModel.tax]) {
        [data addEntriesFromDictionary:@{@"taxFileNo": [self getNotNull:_taxFileNo.text]}];
    }
    
    if (_oldIC.text.length > 0 && ![_oldIC.text isEqualToString:_contactModel.KPLama]) {
        [data addEntriesFromDictionary:@{@"oldIC": [self getNotNull:_oldIC.text]}];
    }
    
    
    NSNumber* inviteToDenning = @(0);
    if (self.inviteDenning.isOn) {
        inviteToDenning = @(1);
    }
    if (inviteToDenning && ![inviteToDenning isEqual:_contactModel.InviteDennig]) {
        [data addEntriesFromDictionary:@{@"inviteToDenning": inviteToDenning}];
    }

    return data;
}

- (void) _save {
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"Saving", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self)
    [[QMNetworkManager sharedManager] saveContactWithData:[self buildParams] withCompletion:^(ContactModel * _Nonnull contactModel, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        if (error == nil) {
            [self clearInput];
            
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully Saved" duration:1.0];
            [self performSegueWithIdentifier:kContactSearchSegue sender:contactModel];
            return;
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}

- (void) _update {
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    NSMutableDictionary* data = [self buildParams];
    [data addEntriesFromDictionary:@{@"code":self.contactModel.contactCode}];
    [[QMNetworkManager sharedManager] updateContactWithData:data withCompletion:^(ContactModel * _Nonnull contactModel, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully Saved" duration:2.0];
            [self performSegueWithIdentifier:kContactSearchSegue sender:contactModel];
            return;
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:2.0];
        }
    }];
}

- (void) prepareUI {
    headers = @[@"Personal Info.", @"Contact Info", @"Other Info.", @"Company Info", @"Invitation"];
    
    if (self.viewType.length == 0) {
        self.contactModel = [ContactModel new];
        [self.saveBtn setTitle:@"Save" forState:UIControlStateNormal];
        self.title = @"Add Contact";
    } else {
        self.IDType.text = [((NSDictionary*)self.contactModel.idType) objectForKeyNotNull:@"description"];
        selectedIDTypeCode = [((NSDictionary*)self.contactModel.idType) objectForKeyNotNull:@"code"];
        [self applyValidateRuleOfID];
        self.IDNo.text = self.contactModel.IDNo;
        self.oldIC.text = self.contactModel.KPLama;
        self.name.text = self.contactModel.name;
        self.contactTitle.text = self.contactModel.contactTitle;
        self.address1.text = self.contactModel.address.line1;
        self.address2.text = self.contactModel.address.line2;
        self.address3.text = self.contactModel.address.line3;
        self.town.text = self.contactModel.address.city;
        self.state.text = self.contactModel.address.state;
        self.country.text = self.contactModel.address.country;
        self.postcode.text = self.contactModel.address.postCode;
        self.email.text = self.contactModel.email;
        self.phoneHome.text = self.contactModel.homePhone;
        self.phoneMobile.text = self.contactModel.mobilePhone;
        self.phoneOffice.text = self.contactModel.officePhone;
        self.fax.text = self.contactModel.fax;
        self.contactPerson.text = self.contactModel.contactPerson;
        self.citizenship.text = self.contactModel.citizenShip;
        self.dateOfBirth.text = [DIHelpers convertDateToCustomFormat:self.contactModel.dateOfBirth];
        self.occupation.text = self.contactModel.occupation.descriptionValue;
        self.taxFileNo.text = self.contactModel.tax;
        self.IRDBranch.text = self.contactModel.IRDBranch.descriptionValue;
        self.website.text = self.contactModel.website;
        if ([self.contactModel.InviteDennig isEqualToString:@"1"]) {
            [self.inviteDenning setOn:YES];
        } else {
            [self.inviteDenning setOn:NO];
        }
        
        [self.saveBtn setTitle:@"Update" forState:UIControlStateNormal];
        self.title = @"Update Contact";
    }
    
    self.IDType.floatLabelPassiveColor = self.IDType.floatLabelActiveColor = [UIColor redColor];
    self.IDNo.floatLabelActiveColor = self.IDNo.floatLabelPassiveColor = [UIColor redColor];
    self.oldIC.floatLabelActiveColor = self.oldIC.floatLabelPassiveColor = [UIColor redColor];
    self.name.floatLabelActiveColor = self.name.floatLabelPassiveColor = [UIColor redColor];
    self.contactTitle.floatLabelActiveColor = self.contactTitle.floatLabelPassiveColor = [UIColor redColor];
    self.address1.floatLabelActiveColor = self.address1.floatLabelPassiveColor = [UIColor redColor];
    self.address2.floatLabelActiveColor = self.address2.floatLabelPassiveColor = [UIColor redColor];
    self.address3.floatLabelActiveColor = self.address3.floatLabelPassiveColor = [UIColor redColor];
    self.town.floatLabelActiveColor = self.town.floatLabelPassiveColor = [UIColor redColor];
    self.state.floatLabelActiveColor = self.state.floatLabelPassiveColor = [UIColor redColor];
    self.postcode.floatLabelActiveColor = self.postcode.floatLabelPassiveColor = [UIColor redColor];
    self.email.floatLabelActiveColor = self.email.floatLabelPassiveColor = [UIColor redColor];
    self.phoneHome.floatLabelActiveColor = self.phoneHome.floatLabelPassiveColor = [UIColor redColor];
    self.phoneMobile.floatLabelActiveColor = self.phoneMobile.floatLabelPassiveColor = [UIColor redColor];
    self.phoneOffice.floatLabelActiveColor = self.phoneOffice.floatLabelPassiveColor = [UIColor redColor];
    self.country.floatLabelActiveColor = self.country.floatLabelPassiveColor = [UIColor redColor];
    self.fax.floatLabelActiveColor = self.fax.floatLabelPassiveColor = [UIColor redColor];
    self.contactPerson.floatLabelActiveColor = self.contactPerson.floatLabelPassiveColor = [UIColor redColor];
    self.website.floatLabelActiveColor = self.website.floatLabelPassiveColor = [UIColor redColor];
    self.citizenship.floatLabelActiveColor = self.citizenship.floatLabelPassiveColor = [UIColor redColor];
    self.dateOfBirth.floatLabelActiveColor = self.dateOfBirth.floatLabelPassiveColor = [UIColor redColor];
    self.occupation.floatLabelActiveColor = self.occupation.floatLabelPassiveColor = [UIColor redColor];
    self.taxFileNo.floatLabelActiveColor = self.taxFileNo.floatLabelPassiveColor = [UIColor redColor];
    self.IRDBranch.floatLabelActiveColor = self.IRDBranch.floatLabelPassiveColor = [UIColor redColor];
    self.registeredOffice.floatLabelActiveColor = self.registeredOffice.floatLabelPassiveColor = [UIColor redColor];
 
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    
    self.IDType.inputAccessoryView = accessoryView;
    self.IDNo.inputAccessoryView = accessoryView;
    self.oldIC.inputAccessoryView = accessoryView;
    self.name.inputAccessoryView = accessoryView;
    self.contactTitle.inputAccessoryView = accessoryView;
    self.address1.inputAccessoryView = accessoryView;
    self.address2.inputAccessoryView = accessoryView;
    self.address3.inputAccessoryView = accessoryView;
    self.postcode.inputAccessoryView = accessoryView;
    self.town.inputAccessoryView = accessoryView;
    self.state.inputAccessoryView = accessoryView;
    self.country.inputAccessoryView = accessoryView;
    self.citizenship.inputAccessoryView = accessoryView;
    self.dateOfBirth.inputAccessoryView = accessoryView;
    self.occupation.inputAccessoryView = accessoryView;
    self.IRDBranch.inputAccessoryView = accessoryView;
    self.email.inputAccessoryView = accessoryView;
    self.phoneHome.inputAccessoryView = accessoryView;
    self.phoneMobile.inputAccessoryView = accessoryView;
    self.phoneOffice.inputAccessoryView = accessoryView;
    self.fax.inputAccessoryView = accessoryView;
    self.taxFileNo.inputAccessoryView = accessoryView;
    self.contactPerson.inputAccessoryView = accessoryView;
    self.website.inputAccessoryView = accessoryView;
    self.registeredOffice.inputAccessoryView = accessoryView;
    
    self.oldIC.delegate = self.IDNo.delegate = self.name.delegate = self.address1.delegate = self.address2.delegate = self.address3.delegate = self.registeredOffice.delegate = self.postcode.delegate = self.town.delegate = self.state.delegate = self.country.delegate = self.phoneMobile.delegate = self.phoneOffice.delegate = self.phoneHome.delegate = self.fax.delegate = self.contactTitle.delegate = self.IDType.delegate = self.contactPerson.delegate = self.citizenship.delegate = self.taxFileNo.delegate = self.IRDBranch.delegate = self.registeredOffice.delegate = self;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0) {
        return;
    }
    
    NSMutableString* string = [[DIHelpers capitalizedString:textField.text] mutableCopy];
    if (textField.tag > 19 && textField.tag < 23) {
        string = [[string stringByReplacingOccurrencesOfString:@"," withString:@""] mutableCopy];
        
        string = [[[string stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceCharacterSet]] stringByAppendingString:@","] mutableCopy];
    }
    
    if (textField.tag == 2) {
        if ([selectedIDTypeCode integerValue] == 1 || [selectedIDTypeCode integerValue] == 2) {
            string = [[[string stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]mutableCopy];
            if (string.length > 12) {
                [QMAlert showAlertWithMessage:@"ID is wrong" actionSuccess:NO inViewController:self];
                return;
            }
            if (string.length > 6) {
                NSString* birth = [string substringToIndex:6];
                NSString* _year = [birth substringToIndex:2];
                if ([_year integerValue] < 50) {
                    _year = [@"20" stringByAppendingString:_year];
                } else {
                    _year = [@"19" stringByAppendingString:_year];
                }
                NSString* _month = [birth substringWithRange:NSMakeRange(2, 2)];
                NSString* _day = [birth substringWithRange:NSMakeRange(4, 2)];
                if ([_month integerValue] > 12 || [_day integerValue] > 31) {
                    [QMAlert showAlertWithMessage:@"Please input valid ID No." actionSuccess:NO inViewController:self];
                    return;
                } else {
                    birth = [NSString stringWithFormat:@"%@-%@-%@ 00:00:00", _year, _month, _day];
                    self.dateOfBirth.text = [DIHelpers getDateInShortFormWithoutTime:birth];
                }
                
                [string insertString:@"-" atIndex:6];
            }
            if (string.length > 9) {
                [string insertString:@"-" atIndex:9];
            }
        }
        
        if (self.viewType.length == 0) {
            if (isIDChecking) {
                return;
            }
            isIDChecking = YES;
            [self checkIDValidation:string url:CONTACT_ID_DUPLICATE message:@"ID Duplication " withCompletion:^{
                self->isIDDuplicated = YES;
            } withFinalCompletion:^{
                self->isIDChecking = NO;
            }];
        }
    }
    
    if (textField.tag == 3) {
        if (self.viewType.length == 0) {
            if (isIDChecking) {
                return;
            }
            isIDChecking = YES;
            [self checkIDValidation:string url:CONTACT_ID_DUPLICATE message:@"ID Duplication " withCompletion:^{
                self->isIDDuplicated = YES;
            } withFinalCompletion:^{
                self->isIDChecking = NO;
            }];
        }
    }
    
    if (textField.tag == 4) {
        if (self.viewType.length == 0) {
            if (isNameChecking) {
                return;
            }
            isNameChecking = YES;
            [self checkIDValidation:string url:CONTACT_NAME_DUPLICATE message:@"Name Duplication" withCompletion:^{
                self->isNameDuplicated = YES;
            } withFinalCompletion:^{
                self->isNameChecking = NO;
            }];
        }
    }
    
    if (textField.tag == 25 || textField.tag == 26 || textField.tag == 27) {
        string = [[[string stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]mutableCopy];
        if (string.length > 1) {
            [string insertString:@"-" atIndex:1];
        }
        
        if (string.length > 6) {
            [string insertString:@"-" atIndex:6];
        }
    }
    
    if (textField.tag == 24) {
        string = [[[string stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]mutableCopy];
        if (string.length > 2) {
            [string insertString:@"-" atIndex:2];
        }
        
        if (string.length > 6) {
            [string insertString:@"-" atIndex:7];
        }
    }
    
    if (textField.tag == 34) {
        string = [string.uppercaseString mutableCopy];
    }
    
    textField.text = [string copy];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL editable;
    if (textField == self.IDType || textField == self.contactTitle || textField == self.postcode || textField == self.town || textField == self.state || textField == self.state || textField == self.country || textField == self.citizenship || textField == self.dateOfBirth || textField == self.occupation || textField == self.IRDBranch) {
        editable = NO;
    } else {
        editable = YES;
    }
    
    return editable;
}

#pragma mark - UITableView

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    if (section == 3) {
        UIButton* headerBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-120, 5, 100, 33)];
        headerBtn.backgroundColor = [UIColor clearColor];
        headerBtn.titleLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:13];
        [headerBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [headerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        [headerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateFocused];
        headerBtn.tag = section;
        [headerBtn setTitle:@"Same as Above" forState:UIControlStateNormal];
        [headerBtn addTarget:self action:@selector(sameAsAbove:) forControlEvents:UIControlEventTouchUpInside];
        [customView addSubview:headerBtn];
    }
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 30)];
    label.font = [UIFont fontWithName:@"SFUIText-Medium" size:15];
    label.text = headers[section];
    [customView addSubview:label];
    return customView;
}

- (void) sameAsAbove: (id) sender {
    self.registeredOffice.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@, %@, %@", self.address1.text, self.address2.text, self.address3.text,  self.postcode.text, self.town.text, self.state.text, self.country.text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.IDTypeCell.leftUtilityButtons = [self leftButtons];
            self.IDTypeCell.delegate = self;
            return self.IDTypeCell;
        } else if (indexPath.row == 1) {
            
            return self.IDNoCell;
        } else if (indexPath.row == 2) {
            return self.OldICCell;
        } else if (indexPath.row == 3) {
            return self.nameCell;;
        } else if (indexPath.row == 4) {
            self.titleCell.leftUtilityButtons = [self leftButtons];
            self.titleCell.delegate = self;
            return self.titleCell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return self.address1Cell;
        } else if (indexPath.row == 1) {
            return self.address2Cell;
        } else if (indexPath.row == 2) {
            return self.address3Cell;
        } else if (indexPath.row == 3) {
            self.postCodeCell.leftUtilityButtons = [self leftButtons];
            self.postCodeCell.delegate = self;
            return self.postCodeCell;
        } else if (indexPath.row == 4) {
            self.townCell.leftUtilityButtons = [self leftButtons];
            self.townCell.delegate = self;
            return self.townCell;;
        } else if (indexPath.row == 5) {
            self.stateCell.leftUtilityButtons = [self leftButtons];
            self.stateCell.delegate = self;
            return self.stateCell;
        } else if (indexPath.row == 6) {
            self.countryCell.leftUtilityButtons = [self leftButtons];
            self.countryCell.delegate = self;
            return self.countryCell;
        } else if (indexPath.row == 7) {
            return self.phoneMobileCell;
        } else if (indexPath.row == 8) {
            self.phoneHome.delegate = self;
            return self.phoneHomeCell;
        } else if (indexPath.row == 9) {
            self.phoneOffice.delegate = self;
            return self.phoneOfficeCell;;
        } else if (indexPath.row == 10) {
            return self.faxCell;
        } else if (indexPath.row == 11) {
            return self.emailCell;
        } else if (indexPath.row == 12) {
            return self.websiteCell;
        } else if (indexPath.row == 13) {
            return self.contactPersonCell;
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            self.citizenshipCell.leftUtilityButtons = [self leftButtons];
            self.citizenshipCell.delegate = self;
            return self.citizenshipCell;
        } else if (indexPath.row == 1) {
            self.dateOfBirthCell.leftUtilityButtons = [self leftButtons];
            self.dateOfBirthCell.delegate = self;
            return self.dateOfBirthCell;
        } else if (indexPath.row == 2) {
            self.occupationCell.leftUtilityButtons = [self leftButtons];
            self.occupationCell.delegate = self;
            return self.occupationCell;
        } else if (indexPath.row == 3) {
            return self.taxFileNoCell;;
        } else if (indexPath.row == 4) {
            self.IRDBranchCell.leftUtilityButtons = [self leftButtons];
            self.IRDBranchCell.delegate = self;
            return self.IRDBranchCell;
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            return self.registeredOfficeCell;
        }
    } else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            return self.inviteDenningCell;
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
            self.IDType.text = @"";
        } else if (indexPath.row == 4) {
            self.contactTitle.text = @"";
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 3) {
            self.postcode.text = @"";
        } else if (indexPath.row == 4) {
            self.town.text = @"";
        } else if (indexPath.row == 5) {
            self.state.text = @"";
        } else if (indexPath.row == 6) {
            self.country.text = @"";
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 1) {
            self.citizenship.text = @"";
        } else if (indexPath.row == 2) {
            self.dateOfBirth.text = @"";
        } else if (indexPath.row == 3) {
            self.occupation.text = @"";
        } else if (indexPath.row == 5) {
            self.IRDBranch.text = @"";
        }
    }
}

- (void) showCalendar {
    [self.view endEditing:YES];
    
    BirthdayCalendarViewController *calendarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        self.dateOfBirth.text = date;
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
    
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    } else if (section == 1) {
        return 14;
    } else if (section == 2) {
        return 5;
    } else if (section == 3) {
        return 1;
    }
    
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(![touch.view isMemberOfClass:[UITextField class]]) {
        [touch.view endEditing:YES];
    }
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) { // ID type
            titleOfList = @"Select ID Type";
            nameOfField = @"IDType";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:CONTACT_IDTYPE_URL];
        }
        else if (indexPath.row == 4) { // title
            titleOfList = @"Select Title";
            nameOfField = @"Title";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:CONTACT_TITLE_URL];
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 3) { // Postcode
            [self showPostcodeAutocomplete:CONTACT_POSTCODE_URL];
        } else if (indexPath.row == 4) { // City
            titleOfList = @"Select City";
            nameOfField = @"Town";
            [self showSimpleAutocomplete:CONTACT_CITY_URL];
    
        } else if (indexPath.row == 5) { // State
            titleOfList = @"Select State";
            nameOfField = @"State";
            [self showSimpleAutocomplete:CONTACT_STATE_URL];
        } else if (indexPath.row == 6) { // Postcode
            titleOfList = @"Select Country";
            nameOfField = @"Country";
//            [self performSegueWithIdentifier:kListWithDescriptionSegue sender:CONTACT_COUNTRY_URL];
            [self showCountryAutocomplete: nil];
        }
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) { // Citizenship
            titleOfList = @"Select Citizen";
            nameOfField = @"Citizen";
            [self showDetailAutocomplete:CONTACT_CITIZENSHIP_URL];
//            [self showCountryPicker];
        } else if (indexPath.row == 1) {
            [self showCalendar];
        } else if (indexPath.row == 2) { // Occupation
            titleOfList = @"Select Occupation";
            nameOfField = @"Occupation";
            [self showDetailAutocomplete:CONTACT_OCCUPATION_URL];
        } else if (indexPath.row == 4) { // branch
            titleOfList = @"Select IRDBranch";
            nameOfField = @"IRDBranch";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:CONTACT_IRDBRANCH_URL];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kListWithCodeSegue]) {
        UINavigationController *navVC =segue.destinationViewController;

        ListWithCodeTableViewController *listCodeVC = navVC.viewControllers.firstObject;
        listCodeVC.delegate = self;
        listCodeVC.titleOfList = titleOfList;
        listCodeVC.name = nameOfField;
        listCodeVC.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kListWithDescriptionSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        ListWithDescriptionViewController *listDescVC = navVC.viewControllers.firstObject;
        listDescVC.contactDelegate = self;
        listDescVC.titleOfList = titleOfList;
        listDescVC.name = nameOfField;
        listDescVC.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kBankBranchSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        BranchListViewController *listVC = navVC.viewControllers.firstObject;
        listVC.updateHandler = ^(BankBranchModel *model) {
            self.IRDBranch.text = model.name;
            selectedIRDBranchCode = model.bankBranchCode;
        };
    }
    
    if ([segue.identifier isEqualToString:kContactSearchSegue]){
//        UINavigationController* navVC = segue.destinationViewController;
        ContactViewController* contactVC = segue.destinationViewController;
        contactVC.contactModel = sender;
        contactVC.gotoRelatedMatter = @"";
        contactVC.previousScreen = @"Add Contact";
    }
}

- (void) applyValidateRuleOfID {
    if ( [@[@"5", @"8", @"11"] containsObject:selectedIDTypeCode]) {
        self.citizenship.placeholder = @"Country of Incorporation";
    }
    
    if ( [@[@"1", @"3"] containsObject:selectedIDTypeCode]) {
        self.oldIC.userInteractionEnabled = YES;
    } else {
        self.oldIC.userInteractionEnabled = NO;
    }
}

#pragma mark - ContactListWithCodeSelectionDelegate
- (void) didSelectList:(UIViewController *)listVC name:(NSString*) name withModel:(CodeDescription *)model
{
    if ([name isEqualToString:@"IDType"]) {
        self.IDType.text = model.descriptionValue;
        selectedIDTypeCode = model.codeValue;
        if ([selectedIDTypeCode integerValue] == 1 || [selectedIDTypeCode integerValue] == 2) {
            self.IDNo.keyboardType = UIKeyboardTypeNumberPad;
        } else {
            self.IDNo.keyboardType = UIKeyboardTypeDefault;
        }
        
        [self applyValidateRuleOfID];
    } else if ([name isEqualToString:@"Title"]) {
        self.contactTitle.text = [DIHelpers capitalizedString:model.descriptionValue];
        selectedTitleCode = model.codeValue;
    } else if ([name isEqualToString:@"Citizen"]) {
        self.citizenship.text = [DIHelpers capitalizedString:model.descriptionValue];
        selectedCitizenCode = model.codeValue;
    } else if ([name isEqualToString:@"Occupation"]) {
        self.occupation.text = [DIHelpers capitalizedString:model.descriptionValue];
        selectedOccupationCode = model.codeValue;
    } else if ([name isEqualToString:@"IRDBranch"]) {
        self.IRDBranch.text = [DIHelpers capitalizedString:model.descriptionValue];
        selectedIRDBranchCode = model.codeValue;
    }
}

#pragma mark - ContactListWithDescriptionDelegate
- (void) didSelectListWithDescription:(UIViewController *)listVC name:(NSString*) name withString:(NSString *)description
{
    if ([name isEqualToString:@"Town"]) {
        self.town.text = description;
    } else if ([name isEqualToString:@"State"]) {
        self.state.text = description;
    } else if ([name isEqualToString:@"Country"]) {
        self.country.text = description;
    }
}

@end
