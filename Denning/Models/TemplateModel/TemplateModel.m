//
//  TemplateModel.m
//  Denning
//
//  Created by Ho Thong Mee on 24/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TemplateModel.h"

@implementation TemplateModel

+ (TemplateModel*) getTemplateFromResponse: (NSDictionary*) response
{
    TemplateModel* model = [TemplateModel new];
    
    model.templateCode = [response valueForKeyNotNull:@"code"];
    model.dtCreatedDate = [response valueForKeyNotNull:@"dtCreatedDate"];
    model.strSource = [response valueForKeyNotNull:@"strSource"];
    model.strLangauge = [response valueForKeyNotNull:@"strLangauge"];
    model.strDescription = [response valueForKeyNotNull:@"strDescription"];
    model.intVersionID = [response valueForKeyNotNull:@"intVersionID"];
    
    return model;
}

+ (NSArray*) getTemplateArrayFromResponse:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[TemplateModel getTemplateFromResponse:obj]];
    }
    
    return result;
}

@end
