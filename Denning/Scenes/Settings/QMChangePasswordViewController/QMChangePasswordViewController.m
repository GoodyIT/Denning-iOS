//
//  QMChangePasswordViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/20/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChangePasswordViewController.h"
#import "QMNavigationController.h"
#import "QMCore.h"
#import "QMTasks.h"

static const NSUInteger kQMPasswordMinChar = 8;

@interface QMChangePasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordOldField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmField;

@end

@implementation QMChangePasswordViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    
    // removing left bar button item that is responsible for split view
    // display mode managing. Not removing it will cause item update
    // for deallocated navigation item
    self.navigationItem.leftBarButtonItem = nil;
}

//MARK: - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    // subscribing for delegate
    self.passwordOldField.delegate = self;
    self.passwordNewField.delegate = self;
    self.passwordConfirmField.delegate = self;
}

- (IBAction)dismissScreen:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.passwordOldField becomeFirstResponder];
}

//MARK: - Actions


- (void)changePassword:(id)sender {
    [self.view endEditing:YES];
    
    NSString *password1 = self.passwordNewField.text;
    NSString *password2 = self.passwordConfirmField.text;
    
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
            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
            [[QMCore instance].pushNotificationManager subscribeForPushNotifications];
        }
        
        [SVProgressHUD showErrorWithStatus:error];
    }];
}

- (IBAction)changeButtonPressed:(UIBarButtonItem *)__unused sender {
    
    if (![self.passwordOldField.text isEqualToString:[DataManager sharedManager].user.password]) {
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_WRONG_OLD_PASSWORD", nil) duration:kQMDefaultNotificationDismissTime];
        
        return;
    }
    
    if (![self.passwordNewField.text isEqualToString:self.passwordConfirmField.text]) {
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_PASSWORD_DONT_MATCH", nil) duration:kQMDefaultNotificationDismissTime];
        
        return;
    }

    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    
    @weakify(self);
    [[QMNetworkManager sharedManager] changePasswordAfterLoginWithEmail:[DataManager sharedManager].user.email password:self.passwordNewField.text withCompletion:^(BOOL success, NSString * _Nonnull error, NSDictionary * _Nonnull response) {
        @strongify(self)
        [navigationController dismissNotificationPanel];
        if (success){
            [[DataManager sharedManager] setUserInfoFromChangePassword:response];
            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
            [[QMCore instance].pushNotificationManager subscribeForPushNotifications];
        } else {
             [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error duration:kQMDefaultNotificationDismissTime];
        }
    }];
}

//MARK: - Helpers

- (IBAction)passwordOldFieldChanged {
    
    [self updateChangeButtonState];
}

- (IBAction)passwordNewFieldChanged {
    
    [self updateChangeButtonState];
}

- (IBAction)passwordConfirmFieldChanged {
    
    [self updateChangeButtonState];
}

- (void)updateChangeButtonState {
    
    if (self.passwordNewField.text.length < kQMPasswordMinChar
        || self.passwordConfirmField.text.length < kQMPasswordMinChar) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

//MARK: - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.passwordOldField) {
        
        [self.passwordNewField becomeFirstResponder];
    }
    else if (textField == self.passwordNewField) {
        
        [self.passwordConfirmField becomeFirstResponder];
    }
    else if (self.navigationItem.rightBarButtonItem.enabled) {
        
        [self changeButtonPressed:nil];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)__unused textField {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)__unused textField {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    return YES;
}

//MARK: - UITableViewDataSource

- (NSString *)tableView:(UITableView *)__unused tableView titleForFooterInSection:(NSInteger)__unused section {
    
    return NSLocalizedString(@"QM_STR_PASSWORD_DESCRIPTION", nil);
}

@end
