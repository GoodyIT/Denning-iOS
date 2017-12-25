//
//  SecondItemModel.h
//  Denning
//
//  Created by Ho Thong Mee on 22/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecondItemModel : NSObject

@property (strong, nonatomic) NSString* OR;
@property (strong, nonatomic) NSString* RM;
@property (strong, nonatomic) NSString* api;
@property (strong, nonatomic) NSString* formName;
@property (strong, nonatomic) NSString* deposited;
@property (strong, nonatomic) NSString* itemId;
@property (strong, nonatomic) NSString* label;
@property (strong, nonatomic) NSString* nextLevelForm;


+ (SecondItemModel*) getSecondItemFromResponse:(NSDictionary*) response;

+ (NSArray*) getSecondItemArrayFromResponse:(NSArray*) response;
@end
