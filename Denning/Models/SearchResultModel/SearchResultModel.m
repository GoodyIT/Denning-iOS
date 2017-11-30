//
//  SearchResultModel.m
//  MPAutoComplete
//
//  Created by DenningIT on 19/01/2017.
//  Copyright © 2017 Custom Apps. All rights reserved.
//

#import "SearchResultModel.h"
#import "NSDictionary+NotNull.h"

@implementation SearchResultModel
@synthesize description;
@synthesize form;

+ (SearchResultModel*) getSearchResultFromResponse: (NSDictionary*) response
{
    SearchResultModel* searchResult = [SearchResultModel new];
    
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
    
    searchResult.Json = [NSJSONSerialization JSONObjectWithData:[[response objectForKey:@"JSON"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    searchResult.JsonDesc = [NSJSONSerialization JSONObjectWithData:[[response objectForKey:@"JsonDesc"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
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
