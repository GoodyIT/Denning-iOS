//
//  MatterBranchModel.h
//  Denning
//
//  Created by Denning IT on 2017-11-22.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MatterBranchModel : NSObject

@property (nonatomic, strong) NSString* codeValue;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) NSString* defaultfirm;

+ (instancetype) getMatterBranchFromResponse:(NSDictionary*) response;

@end
