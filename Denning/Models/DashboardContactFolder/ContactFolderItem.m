//
//  ContactFolderItem.m
//  Denning
//
//  Created by Denning IT on 2017-12-01.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ContactFolderItem.h"

@implementation ContactFolderItem

+ (NSArray*) getContactFolderItemArray:(NSArray*) response
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in response) {
        ContactFolderItem* model = [ContactFolderItem new];
        model.codeValue = [obj valueForKeyNotNull:@"code"];
        model.dtLastModified = [obj valueForKeyNotNull:@"dtLastModified"];
        model.strContactID = [obj valueForKeyNotNull:@"strContactID"];
        model.strContactName = [obj valueForKeyNotNull:@"strContactName"];
        model.strItemCount = [obj valueForKeyNotNull:@"strItemCount"];
        model.url = [obj valueForKeyNotNull:@"url"];
        
        [result addObject:model];
    }
    
    return result;
}

@end
