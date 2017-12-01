//
//  ContactFolderItem.h
//  Denning
//
//  Created by Denning IT on 2017-12-01.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactFolderItem : NSObject

@property (nonatomic, strong) NSString* codeValue;

@property (nonatomic, strong) NSString* dtLastModified;
@property (nonatomic, strong) NSString* strContactID;
@property (nonatomic, strong) NSString* strContactName;
@property (nonatomic, strong) NSString* strItemCount;
@property (nonatomic, strong) NSString* url;

+ (NSArray*) getContactFolderItemArray:(NSArray*) response;

@end
