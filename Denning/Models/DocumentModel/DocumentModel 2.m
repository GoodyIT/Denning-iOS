//
//  DocumentModel.m
//  Denning
//
//  Created by DenningIT on 28/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DocumentModel.h"

@implementation DocumentModel

+ (DocumentModel*) getDocumentFromResponse: (NSDictionary*) response
{
    DocumentModel *documentModel = [DocumentModel new];
    
    documentModel.date = [response valueForKeyNotNull:@"date"];
    documentModel.name = [response valueForKeyNotNull:@"name"];
    documentModel.folders = [FolderModel getFolderArrayFromResponse: [response objectForKeyNotNull:@"folders"]];
    documentModel.documents = [FileModel getFileArrayFromResponse: [response objectForKeyNotNull:@"documents"]];
    
    return documentModel;
}

+ (NSArray*) getDocumentArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray* result = [NSMutableArray new];
    
    for (id model in response) {
        [result addObject:[DocumentModel getDocumentFromResponse:model]];
    }
    
    return [result copy];
}

@end
