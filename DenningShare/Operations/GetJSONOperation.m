//
//  GetJSONOperation.m
//  AutoCompletion
//


#import "GetJSONOperation.h"
#import "RequestOperation.h"
#import "CustomOperation.h"
#import "JSONManager.h"
#import "DIGlobal.h"

typedef void (^FetchCompletionBlock)(NSArray *items);


@implementation GetJSONOperation

- (instancetype)initWithDownloadURL:(NSURL*)url withCompletionBlock:(FetchCompletionBlock)completion
{
    if (self = [super init]) {
        RequestOperation *downloadOperation = [[RequestOperation alloc] initWithUrl:url completion:^(NSURL *url, NSURLResponse *response, NSData *data, NSError *error) {
            NSArray *items = [JSONManager getItemsFromApiResponseDataObject:data];
            if (completion != nil) {
                completion(items);
            }
        }];

        [[NSOperationQueue mainQueue] addOperation:downloadOperation];
        
    }
    return self;
}



- (instancetype)initWithCustomURL:(NSURL*)url withCompletionBlock:(FetchMyCompletionBlock)completion
{
    return [self initWithCustomURL:url withCompletionBlock:completion params:nil];
}

- (instancetype)initWithCustomURL:(NSURL*)url withCompletionBlock:(FetchMyCompletionBlock)completion params:(NSDictionary*) params
{
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:kGroupShareIdentifier];
    return [self initWithCustomURL:url sessionID:[defaults valueForKey:@"sessionID"] withCompletionBlock:completion  params:params];
}

- (instancetype)initWithCustomURL:(NSURL*)url sessionID:(NSString*)sessionID withCompletionBlock:(FetchMyCompletionBlock)completion params:(NSDictionary*) params{
    if (self = [super init]) {
        CustomOperation *downloadOperation = [[CustomOperation alloc] initWithUrl:url sessionID:sessionID completion:^(NSURL *url, NSURLResponse *response, NSData *data, NSError *error){
            if (error == nil) {
                NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
                
                if (completion != nil) {
                    completion(JSON, ((NSHTTPURLResponse *)response).statusCode);
                }
            }
        }  params:params ];
        
        [[NSOperationQueue mainQueue] addOperation:downloadOperation];
        
    }
    return self;
}

@end
