//
//  PresetCodeModel.h
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PresetCodeModel : NSObject

@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSString* codeValue;
@property (strong, nonatomic) NSString* descriptionValue;
@property (strong, nonatomic) NSString* state;

+ (instancetype) getPresetCode:(NSDictionary*) response;

@end
