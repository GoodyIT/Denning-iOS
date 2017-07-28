//
//  SearchResultModel.h
//  MPAutoComplete
//
//  Created by DenningIT on 19/01/2017.
//  Copyright © 2017 Custom Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResultModel : NSObject

@property (strong, nonatomic) NSString * searchDescription;

@property (nonatomic, strong) NSString * form;

@property (strong, nonatomic) NSString * header;

@property (strong, nonatomic) NSString * indexData;

@property (strong, nonatomic) NSString * score;

@property (strong, nonatomic) NSString * title;

@property (strong, nonatomic) NSString * searchCode;

@property (strong, nonatomic) NSString* sortDate;

@property (strong, nonatomic) NSDictionary * Json;

@property (strong, nonatomic) NSDictionary * JsonDesc;

@property (strong, nonatomic) NSString * key;


@property (strong, nonatomic) NSString * row_number;

+ (SearchResultModel*) getSearchResultFromResponse: (NSDictionary*) response;

+ (NSArray*) getSearchResultArrayFromResponse: (NSArray*) response;

@end
