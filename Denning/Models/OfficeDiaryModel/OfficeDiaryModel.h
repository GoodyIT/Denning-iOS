//
//  OfficeDiaryModel.h
//  Denning
//
//  Created by Ho Thong Mee on 16/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfficeDiaryModel : NSObject

@property (strong, nonatomic) NSString* appointmentDetails;
@property (strong, nonatomic) CodeDescription* attendedStatus;
@property (strong, nonatomic) NSString* caseName;
@property (strong, nonatomic) NSString* caseNo;
@property (strong, nonatomic) NSString* diaryCode;
@property (strong, nonatomic) NSString* endDate;
@property (strong, nonatomic) NSString* fileNo1;
@property (strong, nonatomic) NSString* place;
@property (strong, nonatomic) NSString* remarks;
@property (strong, nonatomic) CodeDescription* staffAssigned;
@property (strong, nonatomic) CodeDescription* staffAttended;
@property (strong, nonatomic) NSString* startDate;

+ (instancetype) getOfficeDiaryFromResponse:(NSDictionary*) response;
@end
