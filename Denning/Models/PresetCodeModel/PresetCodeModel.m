//
//  PresetCodeModel.m
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "PresetCodeModel.h"

@implementation PresetCodeModel

+ (instancetype) getPresetCode:(NSDictionary*) response
{
    PresetCodeModel* model = [PresetCodeModel new];
    if  (response == nil) {
        model.category = @"";
        model.codeValue = @"";
        model.descriptionValue = @"";
        model.state = @"";
    } else {
        model.category = [response valueForKeyNotNull:@"category"];
        model.codeValue = [response valueForKeyNotNull:@"codeValue"];
        model.descriptionValue = [response valueForKeyNotNull:@"descriptionvalue"];
        model.state = [response valueForKeyNotNull:@"state"];
    }
    
    return model;
}

@end
