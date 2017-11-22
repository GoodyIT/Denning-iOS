//
//  AddStrModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-22.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CodeStrModel.h"

@implementation CodeStrModel

+ (NSArray*) getAddStrArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        CodeStrModel* model = [CodeStrModel new];
        model.codeValue = [obj valueForKeyNotNull:@"code"];
        model.strCity = [obj valueForKeyNotNull:@"strCity"];
        [result addObject:model];
    }
    
    return result;
}

@end
