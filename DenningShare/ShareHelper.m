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
    
    NSString *title = success ? NSLocalizedString(@"Success", nil) : NSLocalizedString(@"Error", nil);
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull __unused action) {
        
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
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[[NSTimeZone localTimeZone] secondsFromGMT]/3600];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    date = [formatter stringFromDate:[NSDate date]];
    return date;
}
@end
