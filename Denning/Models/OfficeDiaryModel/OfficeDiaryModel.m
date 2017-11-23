//
//  OfficeDiaryModel.m
//  Denning
//
//  Created by Ho Thong Mee on 16/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "OfficeDiaryModel.h"

@implementation OfficeDiaryModel

+ (instancetype) getOfficeDiaryFromResponse:(NSDictionary*) response
{
    OfficeDiaryModel *model = [OfficeDiaryModel new];
    
    model.appointmentDetails = [response valueForKeyNotNull:@"appointmentDetails"];
    model.attendedStatus = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"attendedStatus"]];
    model.caseName = [response valueForKeyNotNull:@"caseName"];
    model.caseNo = [response valueForKeyNotNull:@"caseNo"];
    model.diaryCode = [response valueForKeyNotNull:@"code"];
    model.endDate = [response valueForKeyNotNull:@"endDate"];
    model.fileNo1 = [response valueForKeyNotNull:@"fileNo1"];
    model.place = [response valueForKeyNotNull:@"place"];
    model.remarks = [response valueForKeyNotNull:@"remarks"];
    model.staffAssigned = [ClientModel getClientFromResponse:[response objectForKeyNotNull:@"staffAssigned"]];
    model.staffAttended = [response valueForKeyNotNull:@"staffAttended"];
    model.startDate = [response valueForKeyNotNull:@"startDate"];
    
    return model;
}

@end
