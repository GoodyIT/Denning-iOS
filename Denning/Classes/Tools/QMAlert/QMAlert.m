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

+ (void)showAlertWithMessage:(NSString *)message withTitle:(NSString*)title actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController
{
    [self showAlertWithMessage:message withTitle:title actionSuccess:success inViewController:viewController withCallback:nil];
}

+ (void)showAlertWithMessage:(NSString *)message withTitle:(NSString*)title actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController withCallback:(void (^)(void))completion {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull __unused action) {
        if (completion != nil) {
            completion();
        }
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

+ (void) showConfirmDialog:(NSString *)message withTitle:(NSString*)title inViewController:(UIViewController *)viewController forBarButton:(UIBarButtonItem*)button completion:(void (^)(UIAlertAction * _Nonnull))completion
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
    
    if(alertController.popoverPresentationController) {
        if (button != nil) {
            alertController.popoverPresentationController.barButtonItem = button;
        } else {
            alertController.popoverPresentationController.sourceView = viewController.view;
            alertController.popoverPresentationController.sourceRect = CGRectMake(viewController.view.bounds.size.width/2,  viewController.view.bounds.size.height/2, 0, 0);
            alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
    }
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+(void)showConfirmDialog:(NSString*) message inViewController:(UIViewController *)viewController completion:(void(^)(UIAlertAction * _Nonnull action))completion
{
    [self showConfirmDialog:message withTitle:@"information" inViewController:viewController forBarButton:nil completion:completion];
}

@end
