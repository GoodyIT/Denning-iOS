//
//  NSFetchOperation.h
//  AutoCompletion
//

#import "Operation.h"


typedef void (^JSONFetchCompletionBlock)(NSArray *items, NSString* statusCode);

@interface FetchOperation : Operation

- (id)initWithCompletionBlock:(JSONFetchCompletionBlock)completionBlock incompleteString:(NSString*)string;


@end
