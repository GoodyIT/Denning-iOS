//
//  ShareHelper.h
//  DenningShare
//
//  Created by Denning IT on 2017-12-15.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ShareHelper : NSObject

+ (void)showAlertWithMessage:(NSString *)message actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController withAction:(void(^)(void)) completion;

+ (void)showAlertWithMessage:(NSString *)message actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController;

+ (NSArray*) separateNameIntoTwo:(NSString*) title;

+ (NSString*) todayWithTime;
@end
