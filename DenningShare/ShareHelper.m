//
//  ShareHelper.m
//  DenningShare
//
//  Created by Denning IT on 2017-12-15.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ShareHelper.h"


@implementation ShareHelper

+ (void)showAlertWithMessage:(NSString *)message actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController {
    [self showAlertWithMessage:message actionSuccess:success inViewController:viewController withAction:nil];
}

+ (void)showAlertWithMessage:(NSString *)message actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController withAction:(void(^)(void)) completion{
    NSString *title = success ? NSLocalizedString(@"Success", nil) : NSLocalizedString(@"Error", nil);
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull __unused action) {
        if (completion != nil) {
            completion();
        }
    }]];
    [alertController.view layoutIfNeeded];
    
    [viewController presentViewController:alertController animated:YES completion:nil];

}

+ (NSArray*) separateNameIntoTwo:(NSString*) title
{
    NSMutableArray *items = [[title componentsSeparatedByString:@"("] mutableCopy];
    if ([items count] > 1) {
        items[1] = [items[1] substringToIndex:((NSString*)items[1]).length-1];
    } else {
        [items addObject:@""];
    }
    
    
    return items;
}

+ (NSString*) todayWithTime {
    NSString* date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    date = [formatter stringFromDate:[NSDate date]];
    return date;
}
@end
