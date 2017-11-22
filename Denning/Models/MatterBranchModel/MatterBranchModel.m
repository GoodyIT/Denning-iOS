//
//  MatterBranchModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-22.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MatterBranchModel.h"

@implementation MatterBranchModel

+ (instancetype) getMatterBranchFromResponse:(NSDictionary*) response
{
    MatterBranchModel *model = [MatterBranchModel new];
    
    model.codeValue = [response valueForKeyNotNull:@"code"];
    model.city = [response valueForKeyNotNull:@"city"];
    model.defaultfirm = [response valueForKeyNotNull:@"defaultfirm"];
    
    return model;
}

@end
