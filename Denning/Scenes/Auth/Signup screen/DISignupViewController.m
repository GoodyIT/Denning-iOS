//
//  DISignupViewController.m
//  Denning
//
//  Created by DenningIT on 24/01/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DISignupViewController.h"
#import "FirmListViewController.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"

@interface DISignupViewController ()<FirmListDelegate, UITextFieldDelegate>
{
    __block BOOL isLoading;
    NSArray *countriesList;
    NSMutableArray *countriesNameList;
    NSString* selectedCountryCallingCode;
    NSString* selectedCountryCode;
    NSString* myPhoneNumber;
}
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *countryBtn;
@property (weak, nonatomic) IBOutlet UISwitch *isLayerControl;
@property (weak, nonatomic) IBOutlet UILabel *youLawyerLabel;
@property (weak, nonatomic) IBOutlet UIButton *firmBtn;

@property (weak, nonatomic) IBOutlet UIButton *firmListSelectionBtn;
@property (strong, nonatomic) NSNumber* firmCode;

@property (strong, nonatomic) NSArray* firmList;
@property (strong, nonatomic) NSMutableArray* firmNameList;

@end

@implementation DISignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self addTapGesture];
    [self parseJSON];
    [self setDefaultCountryCode];
}

- (void) prepareUI
{
    self.firmCode = @(0);
    [self.usernameField becomeFirstResponder];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [DIHelpers drawWhiteBorderToTextField:self.emailField];
    [DIHelpers drawWhiteBorderToTextField:self.phoneField];
    [DIHelpers drawWhiteBorderToTextField:self.usernameField];
    
    [DIHelpers drawWhiteBorderToButton:self.firmListSelectionBtn];
    [DIHelpers drawWhiteBorderToButton:self.countryBtn];
    
    [DIHelpers drawWhiteBorderToButton:_firmBtn];
    
    [DIHelpers drawBorderBottom:_youLawyerLabel];
}

- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (void)parseJSON {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"]];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        NSLog(@"%@", [localError userInfo]);
    }
    countriesList = (NSArray *)parsedObject;
    countriesNameList = [NSMutableArray new];
    for (id obj in countriesList) {
        NSString* countryNameAndCode = [NSString stringWithFormat:@"%@ (%@)",[obj objectForKey:kCountryName],  [obj objectForKey:kCountryCallingCode]];
        [countriesNameList addObject:countryNameAndCode];
    }
}

- (void) setDefaultCountryCode
{
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSString *buttonTitle;
    for (id obj in countriesList) {
        if ([[obj objectForKey:kCountryCode] isEqualToString:countryCode]) {
            buttonTitle = [NSString stringWithFormat:@"(%@)", [obj objectForKey:kCountryCallingCode]];
            selectedCountryCallingCode = [obj objectForKey:kCountryCallingCode];
            selectedCountryCode = [obj objectForKey:kCountryCode];
        }
    }
    
    [self.countryBtn setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self addKeyboardObservers];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeKeyboardObservers];
    [SVProgressHUD dismiss];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addKeyboardObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification*) notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (keyboardSize.height != 0.0f && !self.usernameField.isFirstResponder && !self.emailField.isFirstResponder)
    {
        CGFloat y = -keyboardSize.height/2;
        CGRect frame = CGRectMake(self.view.frame.origin.x, y, self.view.frame.size.width, self.view.frame.size.height);
        [self.view setFrame:frame];
        [self.view layoutIfNeeded];
    }
}

- (void)keyboardWillHide:(NSNotification*) notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (keyboardSize.height != 0.0f)
    {
        CGFloat y = 0;
        CGRect frame = CGRectMake(self.view.frame.origin.x, y, self.view.frame.size.width, self.view.frame.size.height);
        [self.view setFrame:frame];
        [self.view layoutIfNeeded];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *) __unused textField {
    if ([self.usernameField isFirstResponder]) {
        [self.emailField becomeFirstResponder];
    } else if ([self.emailField isFirstResponder]) {
        [self.phoneField becomeFirstResponder];
    } else if ([self.phoneField isFirstResponder]) {
        [self.view endEditing:YES];
        [self selectFirmList:nil];
    }
    
    return YES;
}

- (BOOL) checkValidation
{
    BOOL isValid = NO;
    if (self.usernameField.text.length == 0 || self.emailField.text.length == 0 || self.phoneField.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please fill out all the fields" actionSuccess:NO inViewController:self];
        return isValid;
    }
    
    // Phone number validation
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    myPhoneNumber = [selectedCountryCallingCode stringByAppendingString:self.phoneField.text];
    NBPhoneNumber *myNumber = [phoneUtil parse:self.phoneField.text
                                 defaultRegion:selectedCountryCode error:&anError];
    if (![phoneUtil isValidNumber:myNumber]) {
        [QMAlert showAlertWithMessage:@"Please input valid phone number" actionSuccess:NO inViewController:self];
        return isValid;
    }
    
    isValid = YES;
    return isValid;
}

- (IBAction)didTapCountryCode:(id)sender {
    [self showCountryCodeList];
}


- (IBAction)done:(id)sender {
    [self.view endEditing:YES];
    if (![self checkValidation]) {
        return;
    }
    
    NSNumber* isLawyer = self.isLayerControl.isOn ? @1 : @0;
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_SIGNING_UP", nil)];
    [[QMNetworkManager sharedManager] userSignupWithUsername:self.usernameField.text phone:myPhoneNumber email:self.emailField.text isLayer:isLawyer firmCode:self.firmCode withCompletion:^(BOOL success, NSString * _Nonnull error) {
        if  (success)
        {
            QBUUser *user = [QBUUser user];
            user.email = self.emailField.text;
            user.login = _emailField.text;
            user.password = kQBPassword;
            user.fullName = self.usernameField.text;
            user.tags = [@[@"Public"] mutableCopy];
            
            [[[QMCore instance].authService signUpAndLoginWithUser:user] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull QBtask) {
                
                if (!QBtask.isFaulted) {
                    [self dismissScreen:nil];
                } else {
                    [SVProgressHUD showErrorWithStatus:QBtask.error.localizedDescription];
                }
                
                return nil;
            }];
            
        } else {
            [SVProgressHUD showErrorWithStatus:error];
        }
    }];
}

- (IBAction)selectLaywer:(UISwitch* )sender {
    
}

- (void) extractFirmNameList {
    self.firmNameList = [[NSMutableArray alloc]init];
    for (FirmModel *firm in self.firmList) {
        [self.firmNameList addObject:firm.name];
    }
}

- (void) showCountryCodeList
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Contry Code"
                                            rows:countriesNameList
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           selectedCountryCode = [countriesList[selectedIndex] objectForKey:kCountryCode];
                                        selectedCountryCallingCode = [countriesList[selectedIndex] objectForKey:kCountryCallingCode];
                                           NSString *buttonTitle = [NSString stringWithFormat:@"(%@)",selectedCountryCallingCode];
                                         [self.countryBtn setTitle: buttonTitle forState:UIControlStateNormal];
                                       }
     
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:self.countryBtn];
}

- (IBAction)selectFirmList:(id)sender {
    if (isLoading) return;
    isLoading = YES;
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self)
    [[QMNetworkManager sharedManager] getFirmListWithPage: @(0) completion:^(NSArray * _Nonnull resultArray, NSError* _Nonnull error) {
        @strongify(self)
        [SVProgressHUD dismiss];
        self->isLoading = NO;
        if (error == nil) {
            if (resultArray.count > 0) {
                [self performSegueWithIdentifier:kFirmListSegue sender:resultArray];
            } else {
                [QMAlert showAlertWithMessage:@"There is no firm yet" actionSuccess:NO inViewController:self];
            }
        } else {
            [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:self];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kFirmListSegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        FirmListViewController* firmListVC = navVC.viewControllers.firstObject;
        firmListVC.firmDelegate = self;
        firmListVC.firmList = sender;
    }
}


#pragma mark - FirmDelegate
- (void) didSelectFirm:(FirmListViewController *)signupVC withFirmModel:(FirmModel *)firmModel
{
    [self.firmListSelectionBtn setTitle: firmModel.name forState:UIControlStateNormal];
    self.firmCode = firmModel.firmCode;
}

@end
