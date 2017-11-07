//
//  AttendanceItem.h
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttendanceItem : NSObject

@property (strong, nonatomic) NSString* theLocation;
@property (strong, nonatomic) NSString* theTime;
@property (strong, nonatomic) NSString* theType;

+(AttendanceItem*) getAttendanceItemFromResponse:(NSDictionary*) response;

+ (NSArray*) getAttendanceItemArrayFromResponse:(NSArray*) response;
@end
