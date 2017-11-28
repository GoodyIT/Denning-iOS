//
//  QMLicenseAgreementViewController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 10/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLicenseAgreementViewController.h"

@interface QMLicenseAgreementViewController ()
{
    NSDictionary* params;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptButton;

@end

@implementation QMLicenseAgreementViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([DataManager sharedManager].userAgreementAccepted) {
        self.navigationItem.rightBarButtonItem = nil;
    }

    _textView.text = _contents;
}

- (IBAction)done:(id)__unused sender {
    
    [self dismissViewControllerSuccess:NO];
}

- (void)dismissViewControllerSuccess:(BOOL)success {
    
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        
        @strongify(self);
        if (self.licenceCompletionBlock) {
            
            self.licenceCompletionBlock(success);
            self.licenceCompletionBlock = nil;
        }
    }];
}

- (IBAction)acceptLicense:(id)__unused sender {
    NSDictionary* params = @{@"email":@"",
                             @"MAC":[QMNetworkManager sharedManager].MAC,
                             @"deviceName":[QMNetworkManager sharedManager].device
                             };
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMNetworkManager sharedManager] setPublicHTTPHeader];
    [[QMNetworkManager sharedManager] sendPutWithURL:kDIAgreementUrl params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            [DataManager sharedManager].userAgreementAccepted = YES;
            [self dismissViewControllerSuccess:YES];
        }
    }];
    
}

@end
