//
//  QMLogInViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLogInViewController.h"
#import "QMCore.h"
//#import "UINavigationController+QMNotification.h"
#import "QMChangePasswordViewController.h"
#import "NewDeviceLoginViewController.h"
#import "BranchViewController.h"
#import "QMAlert.h"

@interface QMLogInViewController ()
{
    __block BOOL isLoading;
}

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) BFTask *task;

@end

@implementation QMLogInViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (IBAction)gotoHome:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [DIHelpers drawWhiteBorderToTextField:self.emailField];
    [DIHelpers drawWhiteBorderToTextField:self.passwordField];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addTapGesture];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.emailField.text = [DataManager sharedManager].user.email;
    });
 
//    [self.emailField becomeFirstResponder];
}

- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    tap.cancelsTouchesInView = NO;
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

#pragma mark - Actions

- (IBAction)done:(id) sender {
    
    [self.view endEditing:YES];
    
    if (self.task != nil) {
        // task in progress
        return;
    }
    
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (email.length == 0 || password.length == 0) {
        
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil)];
    }
    else if ([QMNetworkManager sharedManager].invalidTry >= 1){
        NSDate* currentTime = [[NSDate alloc] init];
        float duration = [currentTime timeIntervalSinceDate:[QMNetworkManager sharedManager].startTrackTimeForLogin];
        if (fabsf(duration) < 60){
            [SVProgressHUD showErrorWithStatus:@"Locked for 1 minutes. invalid username and password more than 10 times..."];
        } else {
            [self loginWithEmail:email password:password];
        }
    } else {
        [self loginWithEmail:email password:password];
    }
}

- (void) registerURLAndGotoMain: (FirmURLModel*) firmURLModel {
   [[DataManager sharedManager] setServerAPI:firmURLModel.firmServerURL firmURLModel:firmURLModel];
    [self staffLogin:firmURLModel];
}

- (void) staffLogin:(FirmURLModel*)urlModel {
    if (isLoading) return;
    isLoading = YES;
    
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:DENNING_SIGNIN_URL];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    @weakify(self)
    [[QMNetworkManager sharedManager] staffSignIn:url password:[DataManager sharedManager].user.password withCompletion:^(NSDictionary * _Nonnull responseObject, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            if ([[responseObject valueForKeyNotNull:@"statusCode"] isEqual:@(200)]) {
                [[DataManager sharedManager] setOnlySessionID:[responseObject valueForKeyNotNull:@"sessionID"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
                });
            } else {
                [QMAlert showAlertWithMessage:@"You have no access privilege to this firm." actionSuccess:NO inViewController:self];
            }
            
        } else {
            [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:self];
        }
    }];
}

- (void) manageFirmURL: (NSArray*) firmURLArray {
    if (firmURLArray.count == 1) {
        [self registerURLAndGotoMain:firmURLArray[0]];
    } else {
        [self performSegueWithIdentifier:kBranchSegue sender:firmURLArray];
    }
}

- (void) manageUserType {
    // Initialize the option for shared folder
    [DataManager sharedManager].documentView = @"nothing";
    
    if ([DataManager sharedManager].denningArray.count > 0) {
        [self manageFirmURL:[DataManager sharedManager].denningArray];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
        });
    }
}

- (void) manageSuccessResult: (NSInteger) statusCode response:(NSDictionary*) response {
    [SVProgressHUD dismiss];
    [DataManager sharedManager].isSessionExpired = NO;
    [[DataManager sharedManager] setUserPassword:self.passwordField.text];
    [[DataManager sharedManager] setUserInfoFromLogin:response];
    if (statusCode == 250) { // New Device login
        [DataManager sharedManager].statusCode = [NSNumber numberWithInteger:statusCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:kNewDeviceSegue sender:nil];
        });
    } else if (statusCode == 280) { // Change Password
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:kChangePasswordSegue sender:nil];
        });
    } else {
        [self manageUserType];
    }
}

- (void) manageErrorResult: (NSInteger) statusCode error: (NSError*) error {
    NSString* errorString = error.localizedDescription;
    if (statusCode == 401) {
        NSInteger value = [QMNetworkManager sharedManager].invalidTry;
        [QMNetworkManager sharedManager].invalidTry = value + 1;
        
        if (value >= 10){
            errorString = @"Locked for 1 minutes. invalid username and password more than 10 times...";
            [QMNetworkManager sharedManager].startTrackTimeForLogin = [[NSDate alloc] init];
        } else {
            errorString = @"Invalid username or password";
        }
    }
    [QMAlert showAlertWithMessage:errorString actionSuccess:NO inViewController:self];
}

- (void) loginToQB:(NSInteger) statusCode response:(NSDictionary*)responseObject{
    QBUUser *user = [QBUUser user];
    user.email = self.emailField.text;
    user.password = kQBPassword;
    
    @weakify(self);
    self.task = [[[QMCore instance].authService loginWithUser:user] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        @strongify(self);
        if (!task.isFaulted || ((NSError*)task.error).code == 401) {
            if (((NSError*)task.error).code != 401) {
                [[DataManager sharedManager] setQBLoginState:YES];
                [QMCore instance].currentProfile.accountType = QMAccountTypeEmail;
                [[QMCore instance].currentProfile synchronizeWithUserData:task.result];
                [[QMCore instance].pushNotificationManager subscribeForPushNotifications];
            } else {
                [[DataManager sharedManager] setQBLoginState:NO];
            }
           
            [self manageSuccessResult:statusCode response:responseObject];
        } else{
            [SVProgressHUD dismiss];
            [QMAlert showAlertWithMessage:task.error.localizedDescription actionSuccess:NO inViewController:self];
        }
        return nil;
    }];
}

- (void) loginWithEmail: (NSString*) email password:(NSString*) password
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    // Save the user password for the shared folder use
    
    @weakify(self);
    [[QMNetworkManager sharedManager] userSignInWithEmail:email password:password withCompletion:^(BOOL success, NSError * _Nonnull error, NSInteger statusCode, NSDictionary* responseObject) {
        
        @strongify(self)
        if (error == nil){
            [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
            if ([[QBChat instance] isConnected] || [[QBChat instance] isConnecting]) {
                [[QMCore.instance logout] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused logoutTask) {
                    [self loginToQB:statusCode response:responseObject];
                    return nil;
                }];
            } else {
                [self loginToQB:statusCode response:responseObject];
            }
        } else {
            [SVProgressHUD dismiss];
            [self manageErrorResult:statusCode error:error];
        }
    }];
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self done:nil];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *) segue sender:(id) sender {
    
    if ([segue.identifier isEqualToString:kBranchSegue]){
        UINavigationController* navVC = segue.destinationViewController;
        BranchViewController *branchVC = navVC.viewControllers.firstObject;
        branchVC.firmArray = sender;
    }
    
    if ([segue.identifier isEqualToString:kChangePasswordSegue]){
        
    }
}
@end
