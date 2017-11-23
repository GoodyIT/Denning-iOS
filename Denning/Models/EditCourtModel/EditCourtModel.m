 //
//  EditCourtModel.m
//  Denning
//
//  Created by DenningIT on 17/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "EditCourtModel.h"

@implementation EditCourtModel

+ (EditCourtModel*) getEditCourtFromResponse: (NSDictionary*) response
{
    EditCourtModel* model = [EditCourtModel new];
    model.attendedStatus = [CodeDescription getCodeDescriptionFromResponse: [response objectForKeyNotNull:@"attendedStatus"]];
    model.courtCode = [response valueForKeyNotNull:@"code"];
    model.caseNo = [response valueForKeyNotNull:@"caseNo"];
    model.caseName = [response valueForKeyNotNull:@"caseName"];
    model.coram = [CoramModel getCoramFromResponse:[response objectForKeyNotNull:@"coram"]];
    model.counselAssigned = [ClientModel getClientFromResponse:[response objectForKeyNotNull:@"counselAssigned"]];
    model.counselAttended = [response valueForKeyNotNull:@"counselAttended"];
    model.court = [CourtModel getCourtFromResponse: [response objectForKeyNotNull:@"court"]];
    model.courtDecision = [response valueForKeyNotNull:@"courtDecision"];
    model.enclosureDetails = [response valueForKeyNotNull:@"enclosureDetails"];
    model.enclosureNo = [response valueForKeyNotNull:@"enclosureNo"];
    model.fileNo1 = [response valueForKeyNotNull:@"fileNo1"];
    model.hearingStartDate = [response valueForKeyNotNull:@"hearingStartDate"];
    model.hearingEndDate = [response valueForKeyNotNull:@"hearingEndDate"];
    model.hearingType = [response valueForKeyNotNull:@"hearingType"];
    model.nextStartDate = [response valueForKeyNotNull:@"nextStartDate"];
    model.nextEndDate = [response valueForKeyNotNull:@"nextEndDate"];
    model.nextDateType = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"nextDateType"]];
    model.opponentCounsel = [response valueForKeyNotNull:@"opponentCounsel"];
    model.previousDate = [response valueForKeyNotNull:@"previousDate"];
    model.remarks = [response valueForKeyNotNull:@"remarks"];
    
    return model;
}

+ (NSArray*) getEditCourtArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[EditCourtModel getEditCourtFromResponse:obj]];
    }
    
    return result;
}

@end
