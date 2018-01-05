//
//  GetJSONOperation.h
//  AutoCompletion
//


#import "MLPAutoCompleteTextField.h"
#import <Foundation/Foundation.h>

typedef void (^FetchMyCompletionBlock)(NSArray *item, NSInteger statusCode);

@interface GetJSONOperation : NSOperation

- (instancetype)initWithDownloadURL:(NSURL*)url withCompletionBlock:(FetchCompletionBlock)completion;

- (instancetype)initWithCustomURL:(NSURL*)url withCompletionBlock:(FetchMyCompletionBlock)completion;

- (instancetype)initWithCustomURL:(NSURL*)url withCompletionBlock:(FetchMyCompletionBlock)completion params:(NSDictionary*) params;
@end
