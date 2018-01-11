//
//  EditCourtModel.h
//  Denning
//
//  Created by DenningIT on 17/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CourtDiaryModel;
@interface EditCourtModel : NSObject

@property (strong, nonatomic) CodeDescription* attendedStatus;
@property (strong, nonatomic) NSString* courtCode;
@property (strong, nonatomic) NSString* caseNo;
@property (strong, nonatomic) NSString* caseName;
@property (strong, nonatomic) CoramModel* coram;
@property (strong, nonatomic) ClientModel* counselAssigned;
@property (strong, nonatomic) NSString* counselAttended;
@property (strong, nonatomic) CourtDiaryModel* court;
@property (strong, nonatomic) NSString* courtDecision;
@property (strong, nonatomic) NSString* enclosureDetails;
@property (strong, nonatomic) NSString* enclosureNo;
@property (strong, nonatomic) NSString* fileNo1;
@property (strong, nonatomic) NSString* hearingStartDate;
@property (strong, nonatomic) NSString* hearingEndDate;
@property (strong, nonatomic) NSString* hearingType;
@property (strong, nonatomic) NSString* nextStartDate;
@property (strong, nonatomic) NSString* nextEndDate;
@property (strong, nonatomic) CodeDescription* nextDateType;
@property (strong, nonatomic) NSString* opponentCounsel;
@property (strong, nonatomic) NSString* previousDate;
@property (strong, nonatomic) NSString* remarks;


+ (EditCourtModel*) getEditCourtFromResponse: (NSDictionary*) response;

+ (NSArray*) getEditCourtArrayFromResponse: (NSDictionary*) response;
@end
