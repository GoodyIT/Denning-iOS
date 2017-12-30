//
//  QMAlert.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/20/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMAlert.h"

@implementation QMAlert

+ (void)showAlertWithMessage:(NSString *)message actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController {
    
    NSString *title = success ? NSLocalizedString(@"QM_STR_SUCCESS", nil) : NSLocalizedString(@"QM_STR_ERROR", nil);
    
    [self showAlertWithMessage:message withTitle:title actionSuccess:success inViewController:viewController];
}

+ (void)showAlertWithMessage:(NSString *)message withTitle:(NSString*)title actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull __unused action) {
        
    }]];
    [alertController.view layoutIfNeeded];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showInformationWithMessage:(NSString *)message inViewController:(UIViewController *)viewController
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Information"
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull __unused action) {
        
    }]];
    [alertController.view layoutIfNeeded];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+ (void) showConfirmDialog:(NSString *)message withTitle:(NSString*)title inViewController:(UIViewController *)viewController completion:(void (^)(UIAlertAction * _Nonnull))completion
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completion(action);
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [alertController.view layoutIfNeeded];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+(void)showConfirmDialog:(NSString*) message inViewController:(UIViewController *)viewController completion:(void(^)(UIAlertAction * _Nonnull action))completion
{
    [self showConfirmDialog:message withTitle:@"information" inViewController:viewController completion:completion];
}

@end
