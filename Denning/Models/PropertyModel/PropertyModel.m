//
//  PropertyModel.m
//  Denning
//
//  Created by DenningIT on 09/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "PropertyModel.h"

@implementation PropertyModel
@synthesize fullTitle;
@synthesize lotptType;
@synthesize lotptValue;
@synthesize address;
@synthesize area;
@synthesize relatedMatter;

+ (PropertyModel*) getPropertyFromResponse: (NSDictionary*) response
{
    PropertyModel* propertyModel = [PropertyModel new];
    propertyModel.key = [response valueForKeyNotNull:@"code"];
    propertyModel.fullTitle = [response valueForKeyNotNull:@"fullTitle"];
    NSDictionary* lotptObject = [response objectForKeyNotNull:@"lotPT"];
    
    if (lotptObject == nil) {
        propertyModel.lotptType = @"";
        propertyModel.lotptValue = @"";
    } else {
        propertyModel.lotptType = [lotptObject valueForKeyNotNull:@"type"];
        propertyModel.lotptValue = [lotptObject objectForKey:@"value"];
    }
    
    NSDictionary* areaObject = [response objectForKey:@"area"];
    propertyModel.area = [NSString stringWithFormat:@"%@(%@)", [areaObject valueForKeyNotNull:@"type"], [areaObject valueForKeyNotNull:@"value"]];
    propertyModel.address = [response valueForKeyNotNull:@"address"];
    propertyModel.relatedMatter = [SearchResultModel getSearchResultArrayFromResponse:[response objectForKey:@"relatedMatter"]];
    propertyModel.matterDescription = @"";
    for(SearchResultModel* model in propertyModel.relatedMatter) {
        propertyModel.matterDescription = [NSString stringWithFormat:@"%@, %@", propertyModel.matterDescription, model.key];
    }

    return propertyModel;
}

+(NSArray*) getPropertyArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray* propertyArray = [NSMutableArray new];
    for (id object in response) {
        PropertyModel* propertyModel = [PropertyModel getPropertyFromResponse:object];
        [propertyArray addObject:propertyModel];
    }
    return propertyArray;
}
@end
