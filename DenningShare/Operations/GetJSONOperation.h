//
//  GetJSONOperation.h
//  AutoCompletion
//


#import "MLPAutoCompleteTextField.h"
#import <Foundation/Foundation.h>

typedef void (^FetchCompletionBlock)(NSArray *items);

@interface GetJSONOperation : NSOperation

- (instancetype)initWithDownloadURL:(NSURL*)url withCompletionBlock:(FetchCompletionBlock)completion;

@end
