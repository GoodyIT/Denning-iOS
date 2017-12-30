//
//  NewDeviceLoginViewController.m
//  Denning
//
//  Created by DenningIT on 06/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "NewDeviceLoginViewController.h"
#import "BranchViewController.h"

@interface NewDeviceLoginViewController()
@property (weak, nonatomic) IBOutlet UITextField *TACTextField;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@end

@implementation NewDeviceLoginViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self prepareUI];
    [self addTapGesture];
}

- (void) prepareUI
{
    self.phoneNumberLabel.text = [DataManager sharedManager].user.phoneNumber;
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [DIHelpers drawWhiteBorderToTextField:self.TACTextField];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (IBAction)confirmTAC:(id)sender  {
    if (self.TACTextField.text.length < 1){
        [QMAlert showAlertWithMessage:@"Please input the TAC" actionSuccess:NO inViewController:self];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    @weakify(self);
    [[QMNetworkManager sharedManager] sendSMSForNewDeviceWithEmail:[DataManager sharedManager].user.email activationCode:self.TACTextField.text withCompletion:^(BOOL success, NSInteger statusCode, NSString * _Nonnull error, NSDictionary * _Nonnull response) {
        [SVProgressHUD dismiss];
        @strongify(self);
        if (!success) {
            [QMAlert showAlertWithMessage:@"Invalid code" actionSuccess:NO inViewController:self];
        }
        else {
            [[DataManager sharedManager] setUserInfoFromNewDeviceLogin:response];
            
            if (statusCode == 200) {
                [self manageUserType];
            } else {
                [self performSegueWithIdentifier:kChangePasswordSegue sender:nil];
            }
        }
    }];
}

- (void) registerURLAndGotoMain: (FirmURLModel*) firmURLModel {
    [[DataManager sharedManager] setServerAPI:firmURLModel.firmServerURL withFirmName:firmURLModel.name withFirmCity:firmURLModel.city];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
//        [[QMCore instance].pushNotificationManager subscribeForPushNotifications];
    });
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

- (IBAction)resendSMSTAC:(id)sender {
    self.TACTextField.text = @"";
    
   [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];

    [[QMNetworkManager sharedManager] sendSMSRequestWithEmail:[DataManager sharedManager].user.email phoneNumber:[DataManager sharedManager].user.phoneNumber reason:@"from new device login" withCompletion:^(BOOL success, NSInteger statusCode, NSString * _Nonnull error, NSDictionary * _Nonnull response) {

        if (!success) {
            if ([[QBChat instance] isConnected] || [[QBChat instance] isConnecting]) {
                [[QMCore.instance logout] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused logoutTask) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:error];
                    });
                    return nil;
                }];
            }
        }
        else {
            [[DataManager sharedManager] setUserInfoFromNewDeviceLogin:response];
            [SVProgressHUD showWithStatus:@"SMS is sent to your phone"];
        }
    }];
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self confirmTAC:nil];
    return YES;
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
