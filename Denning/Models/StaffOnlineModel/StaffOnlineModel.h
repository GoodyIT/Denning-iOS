//
//  StaffOnlineModel.h
//  Denning
//
//  Created by Ho Thong Mee on 17/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StaffOnlineModel : NSObject

@property (strong, nonatomic) NSString* API;
@property (strong, nonatomic) NSString* device;
@property (strong, nonatomic) NSString* inTime;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* totalHour;
@property (strong, nonatomic) NSString* outTime;
@property (strong, nonatomic) NSString* status;
+ (StaffOnlineModel*) getStaffOnlineFromResponse:(NSDictionary*) response;

+ (NSArray*) getStaffOnlineArrayFromResponse:(NSArray*) response;
@end
