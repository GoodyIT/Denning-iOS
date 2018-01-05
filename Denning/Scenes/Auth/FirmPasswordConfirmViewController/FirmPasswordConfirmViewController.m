//
//  FirmPasswordConfirmViewController.m
//  Denning
//
//  Created by Denning IT on 2018-01-04.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import "FirmPasswordConfirmViewController.h"
#import "FolderViewController.h"


@interface FirmPasswordConfirmViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firmPasswordTextField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation FirmPasswordConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [DIHelpers drawWhiteBorderToTextField:self.firmPasswordTextField];
}

- (void) prepareUI {
    _infoLabel.text = [NSString stringWithFormat:@"Please input the passcode you got from %@ (%@)", _firmName, _branch];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmPassword:(id)sender {
    [self clientFirstLogin];
}

- (void) clientFirstLogin {
    NSString* url = [[DataManager sharedManager].tempServerURL stringByAppendingString:DENNING_CLIENT_FIRST_SIGNIN];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    [[QMNetworkManager sharedManager] clientSignIn:url password:@"5566" withCompletion:^(BOOL success, NSDictionary * _Nonnull responseObject, NSError * _Nonnull error, DocumentModel * _Nonnull doumentModel) {
        [SVProgressHUD dismiss];
        if (error == nil) {
            [[DataManager sharedManager] setOnlySessionID:[responseObject valueForKeyNotNull:@"sessionID"]];
            if ([[DataManager sharedManager].documentView isEqualToString: @"upload"]) {
                [self performSegueWithIdentifier:kFileUploadSegue sender:nil];
            } else {
                [self performSegueWithIdentifier:kPersonalFolderSegue sender:doumentModel];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clientFirstLogin];
    return YES;
}

- (IBAction)resendCode:(id)sender {
    [QMAlert showInformationWithMessage:@"Please call Law Firm if you forgot the passcode." inViewController:self];
}


#pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 if ([segue.identifier isEqualToString:kPersonalFolderSegue]) {
 UINavigationController* nav = segue.destinationViewController;
 FolderViewController* folderVC = (FolderViewController*)nav.topViewController;
 folderVC.documentModel = sender;
 }
 }

@end
