//
//  DIHelpers.m
//  Denning
//
//  Created by DenningIT on 25/01/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DIHelpers.h"
#import "MainTabBarController.h"
#import "HomeViewController.h"

@import SafariServices;

@implementation DIHelpers

+ (NSString*) getWANIP
{
    NSString* WANIP = [[SystemServices sharedServices] externalIPAddress];
    
    if (WANIP == nil) {
        WANIP = @"";
    }
    
//    NSString* WANIP = @"10.17.9.2";
    
    return WANIP;
}

+ (NSString*) getLANIP
{
    NSString* LANIP = [[SystemServices sharedServices] currentIPAddress];
//    NSString* LANIP = @"192.168.2.29";
    
    return LANIP;
}

+ (NSString*) getOSName
{
    NSString* osName = [NSString stringWithFormat:@"%@ %@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
    
    return osName;
}

+ (NSString*) getDevice
{
    NSString* device = [UIDevice currentDevice].model;
    
    return device;
}

+ (NSString*) getDeviceName
{
    NSString* deviceName = [[SystemServices sharedServices] deviceName];
//    NSString* deviceName = [UIDevice currentDevice].model;
    return deviceName;
}

+ (NSString*) getMAC
{
//    NSString* MAC = [[SystemServices sharedServices] cellMACAddress];
    
    NSString* MAC = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    return MAC;
}

+ (NSAttributedString*) getLastRefreshingTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor flatBlackColor]
                                                                forKey:NSForegroundColorAttributeName];
    return [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
}

+ (NSString*) getDateInShortFormWithoutTime: (NSString*) date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    
    NSDate *creationDate = [formatter dateFromString:date];
    
    return [NSDateFormatter localizedStringFromDate:creationDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

+ (NSString*) getDateInShortForm: (NSString*) date
{
    if (date.length == 0) {
        return @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    
    NSDate *creationDate = [formatter dateFromString:date];
    [newFormatter setTimeZone:timeZone];
    [newFormatter setDateFormat:@"d MMM yyyy"];
    
    return [newFormatter stringFromDate:creationDate];
}

+ (NSString*) getDateInLongForm: (NSString*) date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *creationDate = [formatter dateFromString:date];
    
    return [NSDateFormatter localizedStringFromDate:creationDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}

+ (NSString*) toMySQLDateFormatWithoutTime: (NSString*)date
{
    if (date.length == 0) {
        return @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"d MMM yyyy"];
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [newFormatter setTimeZone:timeZone];
    [newFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *creationDate = [formatter dateFromString:date];
    
    return [newFormatter stringFromDate:creationDate];
}

+ (NSString*) convertDateToMySQLFormatWithTime: (NSString*)date
{
    if (date.length == 0) {
        return @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"d MMM yyyy HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [newFormatter setTimeZone:timeZone];
    [newFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *creationDate = [formatter dateFromString:date];
    
    return [newFormatter stringFromDate:creationDate];
}

+ (NSString*) convertDateToMySQLFormat: (NSString*)date
{
    if (date.length == 0) {
        return @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"d MMM yyyy"];
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [newFormatter setTimeZone:timeZone];
    [newFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *creationDate = [formatter dateFromString:date];
    
    return [newFormatter stringFromDate:creationDate];
}

+ (NSString*) convertDateToCustomFormat: (NSString*) date
{
    if (date.length == 0) {
        return date;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [newFormatter setTimeZone:timeZone];
    [newFormatter setDateFormat:@"d MMM yyyy"];
    
    NSDate *creationDate = [formatter dateFromString:date];
    
    return [newFormatter stringFromDate:creationDate];

}

+ (NSArray*) getDateTimeSeprately:(NSString*) input {
    if (input.length == 0) {
        return @[@"", @""];
    }
    NSString* time, *date;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [timeFormatter setTimeZone:timeZone];
    [timeFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"d MMM yyyy"];
    
    NSDate *creationDate = [formatter dateFromString:input];
    
    time = [timeFormatter stringFromDate:creationDate];
    date = [dateFormatter stringFromDate:creationDate];
    
    return @[date, time];
}

+ (NSString*) getTimeFromDate: (NSString*) date
{
    NSString* time;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [newFormatter setTimeZone:timeZone];
    [newFormatter setDateFormat:@"HH:mm ss"];
    
    NSDate *creationDate = [formatter dateFromString:date];
    
    time = [newFormatter stringFromDate:creationDate];
    
    return time;
}

+ (NSString*) getOnlyDateFromDateTime: (NSString*)dateTime
{
   return [self getDateInShortForm:dateTime];
}

+ (NSString*) currentYearFromDate:(NSDate*) date {
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy"];
    return [formatter1 stringFromDate:date];
}

+ (NSString*) currentYear
{
    return [DIHelpers currentYearFromDate:[NSDate date]];
}

+ (NSString*) currentMonthFromDate:(NSDate*) date {
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"MM"];
    return [formatter1 stringFromDate:date];
}

+ (NSString*) currentMonth
{
    return [DIHelpers currentMonthFromDate:[NSDate date]];
}

+ (NSString*) trim:(NSString*) str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


+ (BOOL) isWordFile:(NSString*) fileExt
{
    NSArray* wordArray = @[@".docx", @".doc", @".rtf"];
    if([wordArray containsObject:[fileExt lowercaseString]]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) isImageFile: (NSString*) fileExt {
    NSArray* imageArray = @[@".png", @".tif", @".bmp", @".jpg", @".jpeg", @".gif"];
    if ([imageArray containsObject:[fileExt lowercaseString]]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) isExcelFile: (NSString*) fileExt {
    NSArray* excelArray = @[@".xls", @"xlsx", @"csv"];
    
    if ([excelArray containsObject: [fileExt lowercaseString]]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) isPDFFile: (NSString*) fileExt {
    NSArray* pdfArray = @[@".pdf"];
    
    if ([pdfArray containsObject: [fileExt lowercaseString]]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) isTextFile: (NSString*) fileExt {
    NSArray* textArray = @[@".txt"];
    
    if ([textArray containsObject: [fileExt lowercaseString]]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) isWebFile: (NSString*) fileExt
{
    NSArray* webArray = @[@".url"];
    
    if ([webArray containsObject: [fileExt lowercaseString]]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void) drawWhiteBorderToButton: (UIButton*) button {
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor grayColor].CGColor;
    border.frame = CGRectMake(0, button.frame.size.height - borderWidth, button.frame.size.width, button.frame.size.height);
    border.borderWidth = borderWidth;
    [button.layer addSublayer:border];
    button.layer.masksToBounds = YES;
}

+ (void) drawBorderBottom: (UIView*) view {
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor grayColor].CGColor;
    border.frame = CGRectMake(0, view.frame.size.height - borderWidth, view.frame.size.width, view.frame.size.height);
    border.borderWidth = borderWidth;
    [view.layer addSublayer:border];
    view.layer.masksToBounds = YES;
}

+ (void) drawWhiteBorderToTextField: (UITextField*) textField {
    [DIHelpers drawBorderBottom:textField];
    
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)] && textField.placeholder.length != 0) {
        UIColor *color = [UIColor lightGrayColor];
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
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

+ (NSString*) getDayFromDate: (NSString*) date
{
    if (date.length == 0) {
        return date;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc] init];
    [newFormatter setTimeZone:timeZone];
    [newFormatter setDateFormat:@"EEEE"];

    return [newFormatter stringFromDate:[formatter dateFromString:date]];
}

+ (NSArray*) separateFileNameAndNoFromTitle:(NSString*) title {
    NSString* removedTitle;
    
    NSRange range = NSMakeRange(9, title.length-9);
    removedTitle = [title substringWithRange:range];
    
    NSMutableArray *items = [[removedTitle componentsSeparatedByString:@"("] mutableCopy];
    
    if (items.count == 2) {
        items[1] = [items[1] substringToIndex:((NSString*)items[1]).length-1];
    } else {
        [items addObject:@""];
    }
    
    return items;
}

+ (NSArray*) removeFileNoAndSeparateFromMatterTitle: (NSString*) title
{
    NSString* removedTitle;
    
    NSRange range = NSMakeRange(9, title.length-9);
    removedTitle = [title substringWithRange:range];
    
    NSMutableArray *items = [[removedTitle componentsSeparatedByString:@"("] mutableCopy];
    
    if (items.count == 2) {
        items[1] = [@"(" stringByAppendingString:items[1]];
    } else {
        [items addObject:@""];
    }
   
    return items;
}

+ (NSString*) today {
    NSString* date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    date = [formatter stringFromDate:[NSDate date]];
    return date;
}

+ (NSString*) randomTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"HHmmss"];
    
    return [formatter stringFromDate:[NSDate date]];
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

+ (NSString*) sevenDaysLater {
    return [self sevenDaysLaterFromDate:[DIHelpers today]];
}

+ (NSString*) sevenDaysLaterFromDate: (NSString*) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:[GLDateUtils dateByAddingDays:6 toDate:[formatter dateFromString:date]]];
}

+ (NSString*) sevenDaysBefore {
    NSString* date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    date = [formatter stringFromDate:[GLDateUtils dateByAddingDays:-6 toDate:[NSDate date]]];
    return date;
}

+ (NSString*) currentSunday {
    NSDate *currentDate  = [NSDate date];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDateComponents *components = [gregorianCalendar components:(NSCalendarUnitYear| NSCalendarUnitMonth
                                                                  | NSCalendarUnitDay| NSCalendarUnitWeekday|NSCalendarUnitWeekOfMonth)  fromDate:currentDate];
    
    NSLog(@"Current week day number %ld",(long)[components weekday]);
    NSLog(@"Current week number %ld",(long)[components weekOfMonth]);
    NSLog(@"Current month's day %ld",(long)[components day]);
    NSLog(@"Current month %ld",(long)[components month]);
    NSLog(@"Current year %ld",(long)[components year]);
    
    NSDateComponents *dt=[[NSDateComponents alloc]init];
    
    [dt setWeekOfMonth:[components weekOfMonth]];
    [dt setWeekday:1];
    [dt setMonth:[components month]];
    [dt setYear:[components year]];
    
    NSDate *Sunday=[gregorianCalendar dateFromComponents:dt];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:Sunday];
}

+ (NSString*) addThousandsSeparatorWithDecimal:(id)value
{
    return [DIHelpers formatDecimal:[DIHelpers addThousandsSeparator:value]];
}

+ (NSString*) addThousandsSeparator: (id) value
{
    if (((NSString*)value).length == 0) {
        return value;
    }
    NSScanner *scanner = [NSScanner scannerWithString:[value stringByReplacingOccurrencesOfString:@"," withString:@""]];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    if (((NSString*)value).length == 0 && !isNumeric) {
        return value;
    }
    NSNumber *number = [NSDecimalNumber decimalNumberWithString:value];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [numberFormatter stringFromNumber:number];
}

+ (NSString*) capitalizedString: (id) value
{
    NSArray* myWords = [(NSString*)value componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* string = @"";
    for (NSString* word in myWords) {
        if (word.length == 0) {
            continue;
        }
        string = [NSString stringWithFormat:@"%@ %@%@", string, [[word substringToIndex:1] capitalizedString], [word substringFromIndex:1]];
    }
    
    return string;
}

+ (NSString*) formatDecimal:(NSString*) text {
    text = [text stringByReplacingOccurrencesOfString:@"." withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString* formattedString = [NSString stringWithFormat:@"%.2lf", [text longLongValue] * 0.01];
    NSNumber *number = [NSDecimalNumber decimalNumberWithString:formattedString];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedNumberString = [numberFormatter stringFromNumber:number];
    NSArray* obj = [formattedNumberString componentsSeparatedByString:@"."];
    if ([obj count] > 1 && ((NSString*)obj[1]).length == 1) {
        formattedNumberString = [formattedNumberString stringByAppendingString:@"0"];
    } else if ([obj count] == 1) {
        formattedNumberString = [formattedNumberString stringByAppendingString:@".00"];
    }
    return formattedNumberString;
}

+ (void) configureButton:(MIBadgeButton *) button withBadge:(NSString *) badgeString withColor:(UIColor*) color {

    // optional to change the default position of the badge
    CGSize size = button.frame.size;
    CGSize textSize = [badgeString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
    [button setBadgeEdgeInsets:UIEdgeInsetsMake(size.height / 2 + 18, 0, 0, size.width/2 + textSize.width / 2)];
    
    [button setBadgeString:badgeString];
    [button setBadgeBackgroundColor:color];
}

+ (NSUInteger) detectItemType: (NSString*) form
{
    if ([form isEqualToString:@"200customer"]) // Contact
    {
        return DIContactCell;
    } else if ([form isEqualToString:@"500file"]){ // Related Matter
        return DIRelatedMatterCell;
    } else if ([form isEqualToString:@"800property"]){ // Property
        return DIPropertyCell;
    } else if ([form isEqualToString:@"400bankbranch"]){ // Bank
        return DIBankCell;
    } else if ([form isEqualToString:@"310landoffice"] || [form isEqualToString:@"310landregdist"]){ // Government Office
        return DIGovernmentLandOfficesCell;
    } else if ([form isEqualToString:@"320PTG"]){ // Government Office
        return DIGovernmentPTGOfficesCell;
    } else if ([form isEqualToString:@"300lawyer"]){ // Legal firm
        return DILegalFirmCell;
    } else if ([form isEqualToString:@"950docfile"] || [form isEqualToString:@"900book"]){ // Document
        return DIDocumentCell;
    }
    
    return 0;
}

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        
        topController = topController.presentedViewController;
    }
    
    return topController;
}

+ (void)openURL:(NSURL *)url {
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        if ([SFSafariViewController class] != nil
            // SFSafariViewController supporting only http and https schemes
            && ([url.scheme.lowercaseString isEqualToString:@"http"]
                || [url.scheme.lowercaseString isEqualToString:@"https"])) {
                
                SFSafariViewController *controller =
                [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:false];
                [[self topMostController] presentViewController:controller animated:true completion:nil];
            }
        else {
            
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}


+ (BFTask*) logoutWithCompletion{
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        NSDictionary* params = @{@"email":[DataManager sharedManager].user.email};
        [[QMNetworkManager sharedManager] setPublicHTTPHeader];
        [[QMNetworkManager sharedManager] sendPutWithURL:LOGOUT_URL params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
            
            if (error != nil) {
                [source setError:error];
            } else {
                [source setResult:result];
                [[DataManager sharedManager] clearData];
            }
        }];
    });
}

+ (void)logout:(UIViewController*) viewController {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:NSLocalizedString(@"QM_STR_LOGOUT_CONFIRMATION", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LOGOUT", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          
                                                          [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil) ];
                                                          
                                                          BFTask* logoutTask = [QMCore.instance logout];
                                                          
                                                          BFTask* secondLogout = [self logoutWithCompletion];
                                                          NSArray* tasks = @[logoutTask, secondLogout];
                                                          
                                                          [[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                                                              
                                                              if (!t.isFaulted) {
                                                                  [SVProgressHUD dismiss];
                                                                  // Clear the push badge
                                                                  [DataManager sharedManager].badgeValue = nil;
                                                                  
                                                                  if ([viewController isKindOfClass:[MainTabBarController class]]) {
                                                                      [(MainTabBarController*)viewController removeTabbarBasedOnUserType];
                                                                      HomeViewController* home = [(MainTabBarController*)viewController viewControllers].firstObject;

                                                                      [home viewWillAppear:YES];
                                                                  } else {
                                                                      [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                                  }
                                                                  
                                                              } else {
                                                                  [SVProgressHUD showErrorWithStatus:t.error.localizedDescription];
                                                              }
                                                              return nil;
                                                          }];
                                                      }]];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+ (NSString *)mimeTypeForData:(NSData *)data {
    
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            break;
        case 0x89:
            return @"image/png";
            break;
        case 0x47:
            return @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0xD0:
            return @"application/vnd";
            break;
        case 0x46:
            return @"text/plain";
            break;
        case 'P':
            return @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            break;
        default:
            return @"application/octet-stream";
    }
    return nil;
}

+ (BOOL) isImageFileFromContentType: (NSString*) contentType {
    BOOL isImageFileFromContentType = NO;
    
    if ([contentType localizedCaseInsensitiveContainsString:@"image"]) {
        isImageFileFromContentType = YES;
    }
    
    return isImageFileFromContentType;
}

+ (BOOL) isVideoFileFromContentType: (NSString*) contentType
{
    BOOL isVideoFileFromContentType = NO;
    
    if ([contentType localizedCaseInsensitiveContainsString:@"video"]) {
        isVideoFileFromContentType = YES;
    }
    
    return isVideoFileFromContentType;
}

+ (BOOL) isAudioFileFromContentType: (NSString*) contentType
{
    BOOL isAudioFileFromContentType = NO;
    
    if ([contentType localizedCaseInsensitiveContainsString:@"audio"]) {
        isAudioFileFromContentType = YES;
    }
    
    return isAudioFileFromContentType;
}

+ (BOOL) isWordFileFromContentType:(NSString*) contentType
{
    BOOL isWordFileFromContentType = NO;
    if ([contentType localizedCaseInsensitiveContainsString:@"word"])
    {
        isWordFileFromContentType = YES;
    }
    
    return isWordFileFromContentType;
}

+ (BOOL) isPdfFileFromContentType:(NSString*) contentType
{
    BOOL isPdfFileFromContentType = NO;
    
    if ([contentType localizedStandardContainsString:@"pdf"]) {
        isPdfFileFromContentType = YES;
    }
    
    return isPdfFileFromContentType;
}

+ (NSString*) getUserPosition:(NSString*) email
{
    NSString* position = @"";
    NSArray* userArray = [[[DataManager sharedManager].staffContactsArray arrayByAddingObjectsFromArray:[DataManager sharedManager].clientContactsArray] arrayByAddingObjectsFromArray:[DataManager sharedManager].denningContactArray];
    
    for (ChatFirmModel* chatFirmModel in userArray) {
        for (QBUUser* user in chatFirmModel.users) {
            if ([user.email isEqualToString:email]) {
                position = user.twitterDigitsID;
                break;
            }
        }
    }
    
    return position;
}

+ (NSString*) getTag:(QBChatDialog*) dialog {
    NSString* tag = [dialog.data valueForKeyNotNull:@"tag"];
    return tag.length == 0 ? kChatColleaguesTag : tag;
}

+ (NSString*) getCurrentUserRole:(QBUUser*) user fromChatDialog:(QBChatDialog*) chatDialog
{
    NSString* role = kRoleStaffTag;
    NSArray* adminRoles = [chatDialog.data objectForKey:kRoleAdminTag];
    NSArray* readerRoles = [chatDialog.data objectForKey:kRoleReaderTag];
    NSArray* normalRoles = [chatDialog.data objectForKey:kRoleStaffTag];
    
    NSInteger userID = user.ID;
    if ([[DataManager sharedManager] checkDenningUser:user.email]) {
        role = kRoleDenningTag;
    } else if (adminRoles != nil && adminRoles.count > 0 && [adminRoles containsObject:@(userID)]) {
        role = kRoleAdminTag;
    } else if (readerRoles != nil && readerRoles.count > 0 && [readerRoles containsObject:@(userID)]) {
        role = kRoleReaderTag;
    } else if (normalRoles != nil && normalRoles.count > 0 && [normalRoles containsObject:@(userID)]) {
        role = kRoleStaffTag;
    } else {
        role = kRoleClientTag;
    }
    
    return role;
}

+ (void) showRestrictAlert {
//    [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_EXPIRED", nil) withTitle:@"Access Restriced" actionSuccess:NO inViewController:[self topMostController]];
}

+ (BOOL) canChangeGroupInfoforDialog:(QBChatDialog*) dialog {
    if (![self isAllowToSendForDialog:dialog]) {
        return NO;
    }
    
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    }
    
    if  (!isPossible) {
        [self showRestrictAlert];
    }
    
    return isPossible;
}

+ (BOOL) canChangeGroupNameforDialog:(QBChatDialog*) dialog {
    if (![self isAllowToSendForDialog:dialog]) {
        return NO;
    }
    
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    }
    
    if  (!isPossible) {
        [self showRestrictAlert];
    }
    
    return isPossible;
}

+ (BOOL) canChangeGroupTagforDialog:(QBChatDialog*) dialog {
    if (![self isAllowToSendForDialog:dialog]) {
        return NO;
    }
    
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    }
    
    if  (!isPossible) {
        [self showRestrictAlert];
    }
    
    return isPossible;
}

+ (BOOL) canChangeGroupRoleforDialog:(QBChatDialog*) dialog toUser:(QBUUser*) toUser{
    if (![self isAllowToSendForDialog:dialog]) {
        return NO;
    }
    
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* roleofToUser = [self getCurrentUserRole:toUser fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    
    if ([user.email isEqualToString:toUser.email]) {
        [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_ROLE_SELF_CHANGE", nil) actionSuccess:NO inViewController:[self topMostController]];
        return NO;
    }
    
    if ([roleofToUser isEqualToString:kRoleClientTag]) {
        [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_ROLE_CLIENT_CHANGE", nil) actionSuccess:NO inViewController:[self topMostController]];
        return NO;
    }
    
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            if ([roleofToUser isEqualToString:kRoleDenningTag]) {
                [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_ROLE_DENNING_CHANGE", nil) actionSuccess:NO inViewController:[self topMostController]];
                return NO;
            }
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            if ([roleofToUser isEqualToString:kRoleDenningTag]) {
                [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_ROLE_DENNING_CHANGE", nil) actionSuccess:NO inViewController:[self topMostController]];
                return NO;
            }
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    }
    
    if  (!isPossible) {
        [self showRestrictAlert];
    }
    
    return isPossible;
}

+ (BOOL) canMuteforDialog:(QBChatDialog*) dialog {
    if (![self isAllowToSendForDialog:dialog]) {
        return NO;
    }
    
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    }
    
    return isPossible;
}

+ (BOOL) canAddMemberforDialog:(QBChatDialog*) dialog {
    if (![self isAllowToSendForDialog:dialog]) {
        return NO;
    }
    
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    }
    
    if  (!isPossible) {
        [self showRestrictAlert];
    }
    
    return isPossible;
}

+ (BOOL) canRemoveMemberforDialog:(QBChatDialog*) dialog {
    if (![self isAllowToSendForDialog:dialog]) {
        return NO;
    }
    
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    }
    
    if  (!isPossible) {
        [self showRestrictAlert];
    }
    
    return isPossible;
}

+ (BOOL) canLeaveChatforDialog:(QBChatDialog*) dialog {
    if (![self isAllowToSendForDialog:dialog]) {
        return NO;
    }
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    }
    
    return isPossible;
}

+ (BOOL) canViewContactProfileforDialog:(QBChatDialog*) dialog toUser:(QBUUser*) toUser {
    if (![self isAllowToSendForDialog:dialog]) {
        return NO;
    }
    
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* roleofToUser = [self getCurrentUserRole:toUser fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            if ([roleofToUser isEqualToString:kRoleDenningTag]) {
                return NO;
            }
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            if ([roleofToUser isEqualToString:kRoleDenningTag]) {
                return NO;
            }
            isPossible = YES;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            if ([roleofToUser isEqualToString:kRoleDenningTag]) {
                return NO;
            }
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            if ([roleofToUser isEqualToString:kRoleDenningTag]) {
                return NO;
            }
            isPossible = YES;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    }
    
    if  (!isPossible) {
        [self showRestrictAlert];
    }
    
    return isPossible;
}

+ (BOOL) canShowAllMembersStatusforDialog:(QBChatDialog*) dialog {
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = NO;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = NO;
        }
    }
    
    if  (!isPossible) {
        [self showRestrictAlert];
    }
    
    return isPossible;
}

+ (BOOL) canSendMessageforDialog:(QBChatDialog*) dialog {
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = YES;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = YES;
        }
    }
    
    if  (!isPossible) {
        [self showRestrictAlert];
    }
    
    return isPossible;
}

+ (BOOL) canCallVideoforDialog:(QBChatDialog*) dialog {
    BOOL isPossible = NO;
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:dialog];
    NSString* tag = [self getTag:dialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = YES;
        }
    } else {
        if (isDenningUser) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleAdminTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleStaffTag]) {
            isPossible = YES;
        } else if ([role isEqualToString:kRoleReaderTag]) {
            isPossible = NO;
        } else { // Client
            isPossible = YES;
        }
    }
    
    if  (!isPossible) {
        [self showRestrictAlert];
    }
    
    return isPossible;
}

+ (BOOL) isExpiredChat {
    if ([DataManager sharedManager].isExpire) {
        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_EXPIRED", nil) withTitle:@"Access Restricted" actionSuccess:NO  inViewController:[self topMostController]];
        return NO;
    }
    
    return YES;
}

+ (BOOL) isAllowToSendForDialog:(QBChatDialog*) chatDialog {
    NSString* role = [DIHelpers getCurrentUserRole:[QBSession currentSession].currentUser fromChatDialog:chatDialog];
    if ([role isEqualToString:kRoleReaderTag]) {
        // Reader can only get message;
        return NO;
    }
    
    if (![role isEqualToString:kRoleClientTag]) {
        if (![[DIHelpers getTag:chatDialog] isEqualToString:kChatDenningTag]) {
            return [self isExpiredChat];
        }
    }
    
    return YES;
}

+ (NSArray*) getOnlieStatus:(NSArray*) onlineUsers inTotalUser:(NSArray*) totalUsers forChatDialog:(QBChatDialog*) chatDialog
{
    NSMutableArray* info = [NSMutableArray new];
    NSInteger cntOfOnlineUsers, cntOfTotalUsers;
    NSArray* onlineUsersByExcludingDenning = [QMCore.instance.contactManager usersByExcludingDenningUsersWithIDS:onlineUsers];
    NSArray* totalUsersByExcludingDenning = [QMCore.instance.contactManager usersByExcludingDenningUsersWithIDS:onlineUsers];
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [self getCurrentUserRole:user fromChatDialog:chatDialog];
    NSString* tag = [self getTag:chatDialog];
    BOOL isDenningUser = [[DataManager sharedManager] checkDenningUser:user.email];
    
    if ([tag isEqualToString:kChatDenningTag]) {
        if (isDenningUser) {
            cntOfOnlineUsers = onlineUsers.count;
            cntOfTotalUsers = totalUsers.count;
        } else if ([role isEqualToString:kRoleAdminTag] || [role isEqualToString:kRoleStaffTag]) {
            cntOfOnlineUsers = onlineUsersByExcludingDenning.count;
            cntOfTotalUsers = totalUsersByExcludingDenning.count;
        } else {
            return nil;
        }
    } else {
        if (isDenningUser) {
            cntOfOnlineUsers = onlineUsers.count;
            cntOfTotalUsers = totalUsers.count;
        } else if ([role isEqualToString:kRoleAdminTag] || [role isEqualToString:kRoleStaffTag]) {
            cntOfOnlineUsers = onlineUsersByExcludingDenning.count;
            cntOfTotalUsers = totalUsersByExcludingDenning.count;
        } else {
            return nil;
        }
    }
    
    return [info copy];
}

+ (BOOL) hasAdminRole:(QBChatDialog*) chatDialog
{
    QBUUser* user = [QBSession currentSession].currentUser;
    NSString* role = [DIHelpers getCurrentUserRole:user fromChatDialog:chatDialog];
    if ([role isEqualToString:kRoleAdminTag]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL) isSupportChat:(QBChatDialog*) chatDialog {
    BOOL isCorrect = NO;
    NSString* tag = [chatDialog.data valueForKey:@"tag"];
    if (tag != nil && [tag isEqualToString:@"Denning"]) {
        isCorrect = YES;
    }
    
    return isCorrect;
}

+ (NSString*) getGroupPosition:(QBChatDialog*) chatDialog {
    return [chatDialog.data valueForKeyNotNull:@"position"];
}

+ (UIImage *)resizedImageFromImage:(UIImage *)image {
    
    CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
    CGFloat scaleCoefficient = largestSide / 560.0f;
    CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

+ (NSMutableArray*) filterMeout:(NSMutableArray*) contacts {
    NSMutableArray* dest = [NSMutableArray new];
    for (ChatFirmModel *chatFirmModel in contacts) {
        ChatFirmModel* newModel = [ChatFirmModel new];
        newModel.firmName = chatFirmModel.firmName;
        newModel.firmCode = chatFirmModel.firmCode;
        NSMutableArray* userArray = [NSMutableArray new];
        for (QBUUser* chatUserModel in chatFirmModel.users) {
            if (![chatUserModel.email isEqualToString:[QBSession currentSession].currentUser.email]) {
                [userArray addObject:chatUserModel];
            }
        }
        
        newModel.users = [userArray copy];
        [dest addObject:newModel];
    }
    
    return dest;
}

@end
