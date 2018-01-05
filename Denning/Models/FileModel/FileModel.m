//
//  FileModel.m
//  Denning
//
//  Created by DenningIT on 28/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileModel.h"
#import "NSDictionary+NotNull.h"

@implementation FileModel

+ (FileModel*) getFileFromResponse: (NSDictionary*) response
{
    FileModel *fileModel = [FileModel new];
    
    fileModel.URL = [response valueForKeyNotNull:@"URL"];
    fileModel.date = [response valueForKeyNotNull:@"date"];
    fileModel.ext = [response valueForKeyNotNull:@"ext"];
    fileModel.name = [response valueForKeyNotNull:@"name"];
    fileModel.size = [response valueForKeyNotNull:@"size"];
    fileModel.type = [response valueForKeyNotNull:@"type"];
    
    return fileModel;
}

+ (NSArray*) getFileArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray* result = [NSMutableArray new];
    
    for (id model in response) {
        [result addObject:[FileModel getFileFromResponse:model]];
    }
    
    return [result copy];
}

@end
