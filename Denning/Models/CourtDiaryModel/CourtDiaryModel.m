//
//  CourtDiaryModel.m
//  Denning
//
//  Created by Ho Thong Mee on 23/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CourtDiaryModel.h"

@implementation CourtDiaryModel

+ (CourtDiaryModel*) getCourtDiaryFromResponse: (NSDictionary*) response
{
    CourtDiaryModel* model = [CourtDiaryModel new];
    
    model.courtDiaryCode = [response valueForKeyNotNull:@"code"];
    model.place = [response valueForKeyNotNull:@"place"];
    model.typeCase = [response valueForKeyNotNull:@"typeE"];
    
    return model;
}

+ (NSArray*) getCourtDiaryArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[CourtDiaryModel getCourtDiaryFromResponse:obj]];
    }
    
    return result;

}
@end
