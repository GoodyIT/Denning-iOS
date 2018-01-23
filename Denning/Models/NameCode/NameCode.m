//
//  NameCode.m
//  Denning
//
//  Created by Denning IT on 2018-01-17.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import "NameCode.h"

@implementation NameCode

+ (instancetype) nameCode:(NSString*) name code:(NSString*) code
{
    NameCode* model = [NameCode new];
    
    model.name = name;
    model.code = code;
    
    return model;
}

+ (instancetype) getNameCode:(ClientModel*) response
{
    NameCode* model = [NameCode new];
    
    model.name = response.name;
    model.code = response.clientCode;
    
    return model;
}

+ (NSMutableArray*) getNameCodeArray:(NSArray*) response
{
    NSMutableArray* array = [NSMutableArray new];
    for (id obj in response) {
        [array addObject:[NameCode getNameCode:obj]];
    }
    
    return array;
}

@end
