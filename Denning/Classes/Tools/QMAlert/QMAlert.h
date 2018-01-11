//
//  QMAlert.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/20/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMAlert : NSObject

+ (void)showAlertWithMessage:(NSString *_Nonnull)message withTitle:(NSString*_Nonnull)title actionSuccess:(BOOL)success inViewController:(UIViewController *_Nonnull)view_NonnullController;

+ (void)showAlertWithMessage:(NSString *)message withTitle:(NSString*)title actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController withCallback:(void (^)(void))completion;

+ (void) showConfirmDialog:(NSString *)message withTitle:(NSString*)title inViewController:(UIViewController *)viewController forBarButton:(UIBarButtonItem*)button completion:(void (^)(UIAlertAction * _Nonnull))completion;

+ (void)showAlertWithMessage:(NSString *_Nonnull)message actionSuccess:(BOOL)success inViewController:(UIViewController *_Nonnull)viewController;

+ (void)showInformationWithMessage:(NSString *_Nonnull)message inViewController:(UIViewController *_Nonnull)viewController;

+(void)showConfirmDialog:(NSString*_Nonnull) message inViewController:(UIViewController *_Nonnull)viewController completion:(void(^)(UIAlertAction * _Nonnull action))completion;

@end
