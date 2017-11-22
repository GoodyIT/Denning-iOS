//
//  CourtModel.m
//  Denning
//
//  Created by DenningIT on 29/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CourtModel.h"

@implementation CourtModel

+(CourtModel*) init {
    CourtModel* courtModel = [CourtModel new];
    
    courtModel.caseName = @"";
    courtModel.partyType = @"";
    courtModel.court = @"";
    courtModel.place = @"";
    courtModel.caseNumber = @"";
    courtModel.judge = @"";
    courtModel.SAR = @"";
    courtModel.typeE = @"";
    
    return courtModel;
}

+ (CourtModel*) getCourtFromResponse: (NSDictionary*) response
{
    CourtModel* courtModel = [CourtModel init];
    if (response == nil) {
        return courtModel;
    }
    courtModel.caseName = [response valueForKeyNotNull:@"CaseName"];
    courtModel.partyType = [response valueForKeyNotNull:@"PartyType"];
    courtModel.court = [response valueForKeyNotNull:@"Court"];
    courtModel.place = [response valueForKeyNotNull:@"Place"];
    courtModel.caseNumber = [response  valueForKeyNotNull:@"CaseNo"];
    courtModel.judge = [response valueForKeyNotNull:@"Judge"];
    courtModel.SAR = [response valueForKeyNotNull:@"SAR"];
    courtModel.typeE = [response valueForKeyNotNull:@"typeE"];
    
    return courtModel;
}
@end
