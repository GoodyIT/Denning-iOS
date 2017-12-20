//
//  LeaveRecordModel.h
//  Denning
//
//  Created by Ho Thong Mee on 15/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaveRecordModel : NSObject

@property (strong, nonatomic) NSString* leaveCode;
@property (strong, nonatomic) NSString* dtEndDate;
@property (strong, nonatomic) NSString* dtStartDate;
@property (strong, nonatomic) NSString* intAL;
@property (strong, nonatomic) NSString* intPYL;
@property (strong, nonatomic) NSString* intTaken;
@property (strong, nonatomic) NSString* decLeaveLength;
@property (strong, nonatomic) CodeDescription *clsLeaveStatus;
@property (strong, nonatomic) AttendanceInfo * clsStaff;
@property (strong, nonatomic) CodeDescription* clsTypeOfLeave;

+(instancetype) getLeaveRecordFromResponse: (NSDictionary*) response;

+ (NSArray*) getLEaveRecordArrayFromResponse:(NSArray*) response;


@end
