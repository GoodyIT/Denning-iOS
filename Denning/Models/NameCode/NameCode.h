//
//  NameCode.h
//  Denning
//
//  Created by Denning IT on 2018-01-17.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NameCode : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* code;

+ (instancetype) nameCode:(NSString*) name code:(NSString*) code;

+ (instancetype) getNameCode:(ClientModel*) response;

+ (NSMutableArray*) getNameCodeArray:(NSArray*) response;

@end
