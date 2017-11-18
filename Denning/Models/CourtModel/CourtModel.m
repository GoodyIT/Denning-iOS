//
//  CourtModel.m
//  Denning
//
//  Created by DenningIT on 29/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CourtModel.h"

@implementation CourtModel

+ (CourtModel*) getCourtFromResponse: (NSDictionary*) response
{
    CourtModel* courtModel = [CourtModel new];
    
    courtModel.caseName = [response valueForKeyNotNull:@"CaseName"];
    courtModel.partyType = [response valueForKeyNotNull:@"PartyType"];
    courtModel.court = [response valueForKeyNotNull:@"Court"];
    courtModel.place = [response valueForKeyNotNull:@"Place"];
    courtModel.caseNumber = [response  valueForKeyNotNull:@"CaseNo"];
    courtModel.judge = [response objectForKey:@"Judge"];
    courtModel.SAR = [response objectForKey:@"SAR"];
    
    return courtModel;
}
@end
