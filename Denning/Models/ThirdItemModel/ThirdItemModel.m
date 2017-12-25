//
//  ThirdItemModel.m
//  Denning
//
//  Created by Ho Thong Mee on 27/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ThirdItemModel.h"

@implementation ThirdItemModel

+ (ThirdItemModel*) getThirdItemFromResponse: (NSDictionary*) response
{
    ThirdItemModel* item = [ThirdItemModel new];
    item.itemID = [response valueForKeyNotNull:@"id"];
    item.api = [response valueForKeyNotNull:@"api"];
    item.label = [response valueForKeyNotNull:@"label"];
    item.value = [response valueForKeyNotNull:@"value"];
    item.formName = [response valueForKeyNotNull:@"formName"];
    item.nextLevelForm = [response valueForKeyNotNull:@"nextLevelForm"];
    
    return item;
}

+ (NSArray*) getThirdItemArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[ThirdItemModel getThirdItemFromResponse:obj]];
    }
    
    return result;
}

@end
