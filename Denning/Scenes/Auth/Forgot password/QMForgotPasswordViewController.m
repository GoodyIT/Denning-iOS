//
//  QMForgotPasswordTVC.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 30.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMForgotPasswordViewController.h"
#import "QMTasks.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"

@interface QMForgotPasswordViewController ()
{
    NSArray *countriesList;
    NSMutableArray *countriesNameList;
    NSString* selectedCountryCallingCode;
    NSString* selectedCountryCode;
    NSString* myPhoneNumber;
}

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *TACTextField;

@property (weak, nonatomic) IBOutlet UIButton *countryBtn;

@property (weak, nonatomic) BFTask *task;

@end

@implementation QMForgotPasswordViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.phoneNumberTextField becomeFirstResponder];
    
    // initialize the number of bad try to log in
    [QMNetworkManager sharedManager].invalidTry = @0;
    
    [self addTapGesture];
    [self parseJSON];
    [self setDefaultCountryCode];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [DIHelpers drawWhiteBorderToTextField:self.emailTextField];
    [DIHelpers drawWhiteBorderToTextField:self.phoneNumberTextField];
    [DIHelpers drawWhiteBorderToButton:self.countryBtn];
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
        NSString* countryNameAndCode = [NSString stringWithFormat:@"%@ (%@)", [obj objectForKey:kCountryName], [obj objectForKey:kCountryCallingCode]];
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


#pragma mark Private

- (IBAction)didTapCountryCode:(id)sender {
    [self showCountryCodeList];
}

- (void) showCountryCodeList
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Contry Code"
                                            rows:countriesNameList
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           selectedCountryCode = [countriesList[selectedIndex] objectForKey:kCountryCode];
                                           selectedCountryCallingCode = [countriesList[selectedIndex] objectForKey:kCountryCallingCode];
                                           NSString *buttonTitle = [NSString stringWithFormat:@"(%@)", selectedCountryCallingCode];
                                           [self.countryBtn setTitle: buttonTitle forState:UIControlStateNormal];
                                           
                                       }
     
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:self.countryBtn];
}


- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (void)addKeyboardObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addKeyboardObservers];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeKeyboardObservers];
    [SVProgressHUD dismiss];
    [self.view endEditing:YES];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification*) notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (keyboardSize.height != 0.0f)
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

#pragma mark - actions

- (void)resetPasswordForMail:(NSString *)emailString {
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    
    @weakify(self);
    self.task = [[QMTasks taskResetPasswordForEmail:emailString] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        @strongify(self);
        if (task.isFaulted) {
            
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_USER_WITH_EMAIL_WASNT_FOUND", nil)];
        }
        else {
            
            [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_MESSAGE_WAS_SENT_TO_YOUR_EMAIL", nil)];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return nil;
    }];
}

- (BOOL) validateInputsWithEmail: (NSString*) email phoneNumber:(NSString*) phoneNumber
{
    if (email.length == 0 || phoneNumber.length == 0) {
        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO inViewController:self];
        return false;
    }
    
    // Phone number validation
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    myPhoneNumber = [selectedCountryCallingCode stringByAppendingString:self.phoneNumberTextField.text];
    NBPhoneNumber *myNumber = [phoneUtil parse:self.phoneNumberTextField.text
                                 defaultRegion:selectedCountryCode error:&anError];
    if (![phoneUtil isValidNumber:myNumber]) {
        [QMAlert showAlertWithMessage:@"Please input valid phone number" actionSuccess:NO inViewController:self];
        return NO;
    }
    return YES;
}

- (IBAction)requestSMS:(id)sender {
    NSString *email = self.emailTextField.text;
    NSString *phoneNumber = self.phoneNumberTextField.text;
    
    if (![self validateInputsWithEmail:email phoneNumber:phoneNumber])
    {
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    
    [[QMNetworkManager sharedManager] sendSMSRequestWithEmail:email phoneNumber:phoneNumber reason:@"from Forget Password form" withCompletion:^(BOOL success, NSInteger statusCode, NSString * _Nonnull error, NSDictionary * _Nonnull response) {
        
        if (!success) {
            
            [SVProgressHUD showErrorWithStatus:error];
        }
        else {
            
            [SVProgressHUD showSuccessWithStatus:@"SMS is sent to your phone"];
        }

    }];
}

- (IBAction)forgotPassword:(id)sender {
    NSString *email = self.emailTextField.text;
    NSString *phoneNumber = self.phoneNumberTextField.text;
    
    if (![self validateInputsWithEmail:email phoneNumber:phoneNumber])
    {
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];

    [[QMNetworkManager sharedManager] requestForgetPasswordWithEmail:self.emailTextField.text phoneNumber:self.phoneNumberTextField.text activationCode:self.TACTextField.text withCompletion:^(BOOL success, NSString * _Nonnull error) {
        
        if (!success) {
            [SVProgressHUD showErrorWithStatus:error];
        }
        else {
            [SVProgressHUD showSuccessWithStatus:@"Email is sent"];
        }
    }];
}

@end
