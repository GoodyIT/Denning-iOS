//
//  FirstItemModel.m
//  Denning
//
//  Created by Ho Thong Mee on 22/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FirstItemModel.h"

@implementation FirstItemModel

+(FirstItemModel*) getFirstItemFromResponse:(NSDictionary*)response
{
    FirstItemModel *model = [FirstItemModel new];
    
    model.background = [response valueForKeyNotNull:@"background"];
    model.footerAPI = [response valueForKeyNotNull:@"footerAPI"];
    model.footerDescription = [response valueForKeyNotNull:@"footerDescription"];
    model.footerValue = [response valueForKeyNotNull:@"footerValue"];
    model.footerValueColor = [response valueForKeyNotNull:@"footerValueColor"];
    model.icon = [response valueForKeyNotNull:@"icon"];
    model.formName = [response valueForKeyNotNull:@"formName"];
    model.itemId = [response valueForKeyNotNull:@"itemId"];
    model.mainAPI = [response valueForKeyNotNull:@"mainAPI"];
    model.mainValue = [response valueForKeyNotNull:@"mainValue"];
    model.mainValueColor = [response valueForKeyNotNull:@"mainValueColor"];
    model.title = [response valueForKeyNotNull:@"title"];
    model.titleColor = [response valueForKeyNotNull:@"titleColor"];
    
    return model;
}

+ (NSArray*) getFirstItemArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in response) {
        [result addObject:[FirstItemModel getFirstItemFromResponse:obj]];
    }
    
    return result;
}

@end
