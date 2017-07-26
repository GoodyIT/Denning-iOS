//
//  TemplateModel.h
//  Denning
//
//  Created by Ho Thong Mee on 24/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateModel : NSObject

@property (strong, nonatomic) NSString* templateCode;
@property (strong, nonatomic) NSString* dtCreatedDate;
@property (strong, nonatomic) NSString* intVersionID;
@property (strong, nonatomic) NSString* strDescription;
@property (strong, nonatomic) NSString* strLangauge;
@property (strong, nonatomic) NSString* strSource;

+ (TemplateModel*) getTemplateFromResponse: (NSDictionary*) response;

+ (NSArray*) getTemplateArrayFromResponse:(NSArray*) response;

@end
