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

+ (void)showAlertWithMessage:(NSString *)message actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController;


@end
