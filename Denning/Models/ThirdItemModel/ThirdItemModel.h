//
//  ThirdItemModel.h
//  Denning
//
//  Created by Ho Thong Mee on 27/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThirdItemModel : NSObject

@property (strong, nonatomic) NSString* api;
@property (strong, nonatomic) NSString* label;
@property (strong, nonatomic) NSString* itemID;
@property (strong, nonatomic) NSString* value;
@property (strong, nonatomic) NSString* nextLevelForm;
@property (strong, nonatomic) NSString* formName;

+ (ThirdItemModel*) getThirdItemFromResponse: (NSDictionary*) response;

+ (NSArray*) getThirdItemArrayFromResponse: (NSDictionary*) response;

@end
