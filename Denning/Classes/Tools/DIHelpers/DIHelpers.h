//
//  DIHelpers.h
//  Denning
//
//  Created by DenningIT on 25/01/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MIBadgeButton;
@interface DIHelpers : NSObject

+ (NSString*) getWANIP;

+ (NSString*) getLANIP;

+ (NSString*) getOSName;

+ (NSString*) getDevice;

+ (NSString*) getDeviceName;

+ (NSString*) getMAC;

+ (NSAttributedString*) getLastRefreshingTime;

+ (NSString*) getDateInLongForm: (NSString*) date;

+ (NSString*) getDateInShortFormWithoutTime: (NSString*) date;

+ (NSString*) getDateInShortForm: (NSString*) date;

+ (NSString*) getTimeFromDate: (NSString*) date;

+ (NSString*) getOnlyDateFromDateTime: (NSString*)dateTime;

+ (NSString*) currentYear;

+ (NSString*) currentYearFromDate:(NSDate*) date;

+ (NSString*) currentMonth;

+ (NSString*) currentMonthFromDate:(NSDate*) date;

+ (NSString*) trim:(NSString*) str;

+ (BOOL) isWordFile:(NSString*) fileExt;

+ (BOOL) isImageFile: (NSString*) fileExt;

+ (BOOL) isExcelFile: (NSString*) fileExt;

+ (BOOL) isPDFFile: (NSString*) fileExt;

+ (BOOL) isTextFile: (NSString*) fileExt;

+ (BOOL) isWebFile: (NSString*) fileExt;

+ (void) drawBorderBottom: (UIView*) view;

+ (void) drawWhiteBorderToButton: (UIButton*) button;

+ (void) drawWhiteBorderToTextField: (UITextField*) textField;

+ (NSArray*) separateNameIntoTwo:(NSString*) title;

+ (NSArray*) separateFileNameAndNoFromTitle:(NSString*) title;

+ (NSArray*) removeFileNoAndSeparateFromMatterTitle: (NSString*) title;

+ (NSString*) toMySQLDateFormatWithoutTime: (NSString*)date;

+ (NSString*) convertDateToMySQLFormat: (NSString*)date;

+ (NSString*) convertDateToMySQLFormatWithTime: (NSString*)date;

+ (NSString*) convertDateToCustomFormat: (NSString*) date;

+ (NSString*) getDayFromDate: (NSString*) date;

+ (NSArray*) getDateTimeSeprately:(NSString*) input;

+ (NSString*) today;

+ (NSString*) randomTime;

+ (NSString*) todayWithTime;

+ (NSString*) sevenDaysLater;

+ (NSString*) sevenDaysLaterFromDate: (NSString*) date;

+ (NSString*) sevenDaysBefore;

+ (NSString*) currentSunday;

+ (NSString*) addThousandsSeparator: (id) value;

+ (NSString*) addThousandsSeparatorWithDecimal:(id)value;

+ (NSString*) capitalizedString: (id) value;

+ (NSString*) formatDecimal:(NSString*) text;

+ (void) configureButton:(MIBadgeButton *) button withBadge:(NSString *) badgeString withColor:(UIColor*) color;

+ (NSUInteger) detectItemType: (NSString*) form;

+ (UIViewController*) topMostController;

+ (void)openURL:(NSURL *)url;
@end
