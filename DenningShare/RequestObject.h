//
//  RequestObject.h
//  DenningShare
//
//  Created by Denning IT on 2017-11-28.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FetchCompletionBlock)(NSArray *items);


@interface RequestObject : NSObject

@property (nonatomic, strong) NSString* incompleteString;
@property (nonatomic, strong) FetchCompletionBlock completionBlock;


@end
