//
//  CodeTransactionDesc.m
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CodeTransactionDesc.h"

@implementation CodeTransactionDesc

+ (instancetype) getCodeTransactionDesc:(NSDictionary*) response
{
    CodeTransactionDesc* model = [CodeTransactionDesc new];
    
    model.codeValue = [response valueForKeyNotNull:@"code"];
    model.strTransactionDescription = [response valueForKeyNotNull:@"strTransactionDescription"];
    
    return model;
}

+(NSArray*) getCodeTransactionDescArray:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in response) {
        [result addObject:[CodeTransactionDesc getCodeTransactionDesc:obj]];
    }
    
    return result;
}

@end
