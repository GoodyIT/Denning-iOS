//
//  AddMenu.h
//  Denning
//
//  Created by Denning IT on 2018-10-20.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddMenu : NSObject

@property (strong, nonatomic) NSString* ios_icon;
@property (strong, nonatomic) NSArray<AddMenu*>* items;
@property (strong, nonatomic) NSString* openForm;
@property (strong, nonatomic) NSString* title;


+ (NSMutableArray<AddMenu*>*) getAddMenuArray:(NSArray*) response;


@end

NS_ASSUME_NONNULL_END
