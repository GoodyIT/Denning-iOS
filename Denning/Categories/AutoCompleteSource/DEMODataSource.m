//
//  DEMODataSource.m
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 5/28/14.
//  Copyright (c) 2014 Mainloop. All rights reserved.
//

#import "DEMODataSource.h"
#import "DEMOCustomAutoCompleteObject.h"
#import "AFNetworking.h"
#import "AFHTTPSessionOperation.h"
#import "QMNetworkManager.h"

@interface DEMODataSource ()
@property(strong,nonatomic) NSOperationQueue *fetchQueue;

@property (strong, nonatomic) NSArray *countryObjects;

@end


@implementation DEMODataSource
@synthesize manager;


#pragma mark - MLPAutoCompleteTextField DataSource

- (NSArray*) parseResponse: (id) response
{
    NSMutableArray* keywords = [NSMutableArray new];
    for (id obj in response) {
        [keywords addObject:[obj objectForKey:@"keyword"]];
    }
    
    return keywords;
}

//example of asynchronous fetch:
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    
    self.manager = [QMNetworkManager sharedManager].manager;
    
    if ([[DataManager sharedManager].user.userType isEqualToString:@"denning"]){
        self.manager = [[QMNetworkManager sharedManager] setPublicHTTPHeader];
        _requestURL = [[DataManager sharedManager].user.serverAPI stringByAppendingString: GENERAL_KEYWORD_SEARCH_URL];
    } else {
        self.manager = [[QMNetworkManager sharedManager] setPrivateHTTPHeader];
        _requestURL = PUBLIC_KEYWORD_SEARCH_URL;
    }

    NSString* url = [_requestURL stringByAppendingString:[string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    NSOperation *operation = [AFHTTPSessionOperation operationWithManager:manager
                                                               HTTPMethod:@"GET"
                                                                URLString:url
                                                               parameters:nil
                                                           uploadProgress:nil
                                                         downloadProgress:nil
                                                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//                                                                      NSLog(@"%@", responseObject);
                                                                      
                                                                      handler([self parseResponse:responseObject]);                     } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                                              NSLog(@"%@", error);
                                                                  }];
    [[NSOperationQueue mainQueue] addOperation:operation];
   
}

@end
