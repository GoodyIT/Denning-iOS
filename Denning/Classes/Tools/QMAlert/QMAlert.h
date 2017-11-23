//
//  QMAlert.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/20/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMAlert : NSObject

+ (void)showAlertWithMessage:(NSString *)message actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController;

+ (void)showInformationWithMessage:(NSString *)message inViewController:(UIViewController *)viewController;

+(void)showConfirmDialog:(NSString*) message inViewController:(UIViewController *)viewController completion:(void(^)(UIAlertAction * _Nonnull action))completion;

@end
