//
//  CustomOperation.h
//  DenningShare
//
//  Created by Denning IT on 2017-11-30.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CustomCompletionBlock)(NSURL *url, NSURLResponse *response, NSData *data, NSError *error);

@interface CustomOperation : NSOperation

- (id) initWithUrl:(NSURL*)url completion:(CustomCompletionBlock)completion;

@end
