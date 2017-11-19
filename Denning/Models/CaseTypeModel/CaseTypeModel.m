//
//  CaseTypeModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-19.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CaseTypeModel.h"

@implementation CaseTypeModel

+ (NSArray*) getCaseTypeArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        CaseTypeModel* model = [CaseTypeModel new];
        model.caseCode = [obj valueForKeyNotNull:@"code"];
        model.strBahasa = [obj valueForKeyNotNull:@"strBahasa"];
        model.strEnglish = [obj valueForKeyNotNull:@"strEnglish"];
        [result addObject:model];
    }
    
    return result;
}
@end
