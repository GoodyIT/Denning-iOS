//
//  MyWelcomeViewController.m
//  Denning
//
//  Created by Denning IT on 2017-11-28.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MyWelcomeViewController.h"

@interface MyWelcomeViewController ()

@end

@implementation MyWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
    return;

    // Do any additional setup after loading the view.
    NSDictionary* params = @{@"email":@"",
                             @"MAC":[QMNetworkManager sharedManager].MAC,
                             @"deviceName":[QMNetworkManager sharedManager].device
                             };
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMNetworkManager sharedManager] setPublicHTTPHeader];
    [[QMNetworkManager sharedManager] sendPostWithURL:kDIAgreementUrl params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
//        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else if ([[result valueForKeyNotNull:@"code"] isEqualToString:@"201"]) {
            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
        } else {
            [QMLicenseAgreement presentUserAgreementInViewController:self contents:[result valueForKeyNotNull:@"strItemDescription"] completion:^(BOOL success) {
                if (success) {
                    [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
                }
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
