//
//  ThreeItemModel.h
//  Denning
//
//  Created by Ho Thong Mee on 26/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GraphModel;
@interface ThreeItemModel : NSObject

@property (strong, nonatomic) NSString* iStyle;
@property (strong, nonatomic) NSArray<GraphModel*>* graphs;
@property (strong, nonatomic) NSArray* main;
@property (strong, nonatomic) NSArray<ItemModel*>* items;

+ (ThreeItemModel*) getThreeItemFromResponse: (NSDictionary*) response;

@end
