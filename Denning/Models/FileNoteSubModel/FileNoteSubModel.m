//
//  FileNoteSubModel.m
//  Denning
//
//  Created by Ho Thong Mee on 19/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileNoteSubModel.h"

@implementation FileNoteSubModel

+ (FileNoteSubModel*) getFileNoteSubFromResponse:(NSDictionary*) response
{
    FileNoteSubModel* model = [FileNoteSubModel new];
    
    model.subCode = [response valueForKeyNotNull:@"subCode"];
    model.strIdno = [response valueForKeyNotNull:@"strIdno"];
    model.strName = [response valueForKeyNotNull:@"strName"];
    model.strInitials = [response valueForKeyNotNull:@"strInitials"];
    
    return model;
}

@end
