//
//  DocumentModel.h
//  Denning
//
//  Created by DenningIT on 28/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentModel : NSObject

@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSArray<DocumentModel*>* folders;
@property (strong, nonatomic) NSArray* documents;

+ (DocumentModel*) getDocumentFromResponse: (NSDictionary*) response;

+ (NSArray*) getDocumentArrayFromResponse: (NSDictionary*) response;

@end
