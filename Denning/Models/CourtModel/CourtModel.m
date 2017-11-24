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
    courtModel.courtCode = [response valueForKeyNotNull:@"code"];
    courtModel.caseName = [response valueForKeyNotNull:@"caseName"];
    courtModel.partyType = [response valueForKeyNotNull:@"partyType"];
    courtModel.court = [response valueForKeyNotNull:@"court"];
    courtModel.place = [response valueForKeyNotNull:@"place"];
    courtModel.caseNumber = [response  valueForKeyNotNull:@"caseNo"];
    courtModel.judge = [response valueForKeyNotNull:@"judge"];
    courtModel.SAR = [response valueForKeyNotNull:@"SAR"];
    courtModel.typeE = [response valueForKeyNotNull:@"typeE"];
    
    return courtModel;
}
@end
