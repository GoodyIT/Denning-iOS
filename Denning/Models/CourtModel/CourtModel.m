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
    courtModel.caseNo = @"";
    courtModel.judge = @"";
    courtModel.SAR = @"";
    courtModel.typeCase = @"";
    
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
    courtModel.caseNo = [response  valueForKeyNotNull:@"CaseNo"];
    courtModel.judge = [response valueForKeyNotNull:@"Judge"];
    courtModel.SAR = [response valueForKeyNotNull:@"SAR"];
    courtModel.typeCase = [response valueForKeyNotNull:@"TypeCase"];
    
    return courtModel;
}
@end
