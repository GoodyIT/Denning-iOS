//
//  AttendanceModel.h
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AttendanceItem;
@class AttendanceInfo;

@interface AttendanceModel : NSObject

@property (strong, nonatomic) NSString* btnLeft;
@property (strong, nonatomic) NSString* btnRight;
@property (strong, nonatomic) AttendanceInfo* clsStaff;
@property (strong, nonatomic) NSString* dtDate;
@property (strong, nonatomic) NSArray* theListing;
@property (strong, nonatomic) NSString* totalWorkingHours;

+(AttendanceModel*) getAttendanceModelFromResponse:(NSDictionary*) response;

@end
