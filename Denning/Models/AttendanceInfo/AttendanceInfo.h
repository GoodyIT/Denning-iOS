//
//  AttendnaceInfo.h
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttendanceInfo : NSObject

@property (strong, nonatomic) NSString* attendanceCode;
@property (strong, nonatomic) NSString* strIdNo;
@property (strong, nonatomic) NSString* strInitials;
@property (strong, nonatomic) NSString* strName;
@property (strong, nonatomic) NSString* strPositionTitle;

+(AttendanceInfo*) getAttendanceInfoFromResonse:(NSDictionary*) response;

+(NSArray*) getAttendanceInfoArrayFromResponse:(NSArray*) response;

@end
