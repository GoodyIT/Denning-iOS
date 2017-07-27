//
//  SearchResultModel.m
//  MPAutoComplete
//
//  Created by DenningIT on 19/01/2017.
//  Copyright © 2017 Custom Apps. All rights reserved.
//

#import "SearchResultModel.h"

@implementation SearchResultModel
@synthesize description;
@synthesize form;

+ (SearchResultModel*) getSearchResultFromResponse: (NSDictionary*) response
{
    SearchResultModel* searchResult = [SearchResultModel new];
    
//    NSString *strJson=@"{\"name\":{\"dob\":88,\"age\":61},\"family\" : [{\"location\":\"us\",\"mobile\":\"mobile\"}]}";
    if ([[response objectForKey:@"JSON"] isKindOfClass:[NSString class]]) {
        NSData *data = [[response objectForKey:@"JSON"] dataUsingEncoding:NSUTF8StringEncoding];
        id jsonOutput = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@",jsonOutput);
    }
    
    searchResult.searchDescription = [response objectForKey:@"Desc"];
    searchResult.form = [response objectForKey:@"Form"];
    searchResult.header = [response objectForKey:@"Header"];
    
    if ([searchResult.header isKindOfClass:[NSNull class]]) {
        searchResult.header  =@"";
    }
    
    searchResult.indexData = [response objectForKey:@"IndexData"];
    searchResult.score = [response objectForKey:@"Score"];
    searchResult.title = [response objectForKey:@"Title"];
    searchResult.searchCode = [response objectForKey:@"code"];
    searchResult.sortDate = [response valueForKeyNotNull:@"SortDate"];
    
    NSData *jsonData= [[response objectForKey:@"JsonDesc"] dataUsingEncoding:NSUTF8StringEncoding];
    searchResult.JsonDesc = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    searchResult.key = [response objectForKey:@"key"];
    searchResult.row_number = [response objectForKey:@"row_number"];
    
    return searchResult;
}

+ (NSArray*) getSearchResultArrayFromResponse: (NSArray*) response
{
    NSMutableArray *searchResultArray = [[NSMutableArray alloc] init];
    
    if ([response isKindOfClass:[NSArray class]]) {
        for (NSDictionary* dictionary in response) {
            [searchResultArray addObject:[SearchResultModel getSearchResultFromResponse:dictionary]];
        }
    }
    
    return [searchResultArray copy];
}
@end
