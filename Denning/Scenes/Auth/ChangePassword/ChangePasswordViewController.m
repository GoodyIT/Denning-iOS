//
//  ChangePasswordViewController.m
//  Denning
//
//  Created by DenningIT on 07/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "BranchViewController.h"

@interface ChangePasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *newpasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self addTapGesture];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [DIHelpers drawWhiteBorderToTextField:self.newpasswordTextField];
    [DIHelpers drawWhiteBorderToTextField:self.confirmPasswordTextField];
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

- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (void) prepareUI
{
    
    UIBarButtonItem *confirmButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStylePlain target:self action:@selector(changePassword:)];
    
    [self.navigationItem setRightBarButtonItems:@[ confirmButtonItem] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) registerURLAndGotoMain: (FirmURLModel*) firmURLModel {
    [[DataManager sharedManager] setServerAPI:firmURLModel.firmServerURL firmURLModel:firmURLModel];
    [self staffLogin:firmURLModel];
}

- (void) manageFirmURL: (NSArray*) firmURLArray {
    if (firmURLArray.count == 1) {
        [self registerURLAndGotoMain:firmURLArray[0]];
    } else {
        [self performSegueWithIdentifier:kBranchSegue sender:firmURLArray];
    }
}

- (void) manageUserType {
    if ([DataManager sharedManager].denningArray.count > 0) {
        [self manageFirmURL:[DataManager sharedManager].denningArray];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
        });
    }
}

- (void) staffLogin:(FirmURLModel*)urlModel {
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:DENNING_SIGNIN_URL];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    @weakify(self)
    [[QMNetworkManager sharedManager] staffSignIn:url password:[DataManager sharedManager].user.password withCompletion:^(NSDictionary * _Nonnull responseObject, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        @strongify(self)
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

- (IBAction)changePassword:(id)sender {
    [self.view endEditing:YES];
    
    NSString *password1 = self.newpasswordTextField.text;
    NSString *password2 = self.confirmPasswordTextField.text;
    
    if (password1.length == 0 || password2.length == 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil)];
        return;
    } else if (![password1 isEqualToString:password2]){
        [SVProgressHUD showErrorWithStatus:@"Password should be matching"];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    @weakify(self);

    [[QMNetworkManager sharedManager] changePasswordAfterLoginWithEmail:[DataManager sharedManager].user.email password:password1 withCompletion:^(BOOL success, NSString * _Nonnull error, NSDictionary * _Nonnull response) {
        @strongify(self)
        [SVProgressHUD dismiss];
        if (success){
            [[DataManager sharedManager] setUserInfoFromChangePassword:response];
            [[DataManager sharedManager] setUserPassword:password1];
            [self manageUserType];
        }
        if ([[QBChat instance] isConnected] || [[QBChat instance] isConnecting]) {
            [[QMCore.instance logout] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused logoutTask) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:error];
                });
                return nil;
            }];
        }
    }];
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    [self changePassword:nil];
    return YES;
}

- (IBAction)skipChange:(id)sender {
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kBranchSegue]){
        UINavigationController* navVC = segue.destinationViewController;
        BranchViewController *branchVC = navVC.viewControllers.firstObject;
        branchVC.firmArray = sender;
    }
}

@end
