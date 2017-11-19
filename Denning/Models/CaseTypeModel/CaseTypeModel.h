//
//  CaseTypeModel.h
//  Denning
//
//  Created by Denning IT on 2017-11-19.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaseTypeModel : NSObject

@property(strong, nonatomic) NSString* caseCode;
@property(strong, nonatomic) NSString* strEnglish;
@property(strong, nonatomic) NSString* strBahasa;

+ (NSArray*) getCaseTypeArrayFromResponse:(NSArray*) response;

@end
